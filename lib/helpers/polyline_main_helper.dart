import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zocar/helpers/polyline_cache_helper.dart';
import 'package:zocar/helpers/polyline_points.dart';
import 'package:zocar/helpers/to_address_ext.dart';

import '../utils/preferences.dart';
import 'devlog.dart';
import 'location_service.dart';

const DISTANCE_THRESHOLD = 100.0;

typedef UpdatePolylineCallback = void Function(List<LatLng> points);
typedef UpdateMarkersCallback = void Function(Set<Marker> markers);

class PolylineHelper {

  PolylinePoints _polylinePoints = PolylinePoints();
  PolylineResult? _savedPolylineResult;
  List<LatLng> _savedPolylineCoordinates = [];
  List<LatLng> _remainingPolylineCoordinates = [];
  double? _lastDistance;

  void clearPolylineCache() {
    _savedPolylineResult = null;
    _savedPolylineCoordinates.clear();
    _remainingPolylineCoordinates.clear();
    _lastDistance = null;
  }

  Future<void> setupMarkersAndPolylines({
    required LocationModel? currentLocation,
    required List<LocationModel> stopLocations,
    required LocationModel? dropLocation,
    bool useCachedPolyline = true,
    required String cacheId,
    required bool isCalculateMarkerBearing,
    required VoidCallback initState,
    required UpdatePolylineCallback updatePolylineDisplay,
    required UpdateMarkersCallback updateMarkers,
  }) async {
    devlog("setupMarkersAndPolylines called");
    initState();

    List<LatLng> routePoints = [];


    try {
      /// WAY POINTS
      ///
      if (currentLocation != null) routePoints.add(currentLocation.latLng);
      for (int i = 0; i < stopLocations.length; i++) {
        routePoints.add(stopLocations[i].latLng);
      }
      if (dropLocation != null) routePoints.add(dropLocation.latLng);
      List<PolylineWayPoint> waypoints = [];
      for (int i = 1; i < routePoints.length - 1; i++) {
        waypoints.add(PolylineWayPoint(
          location: "${routePoints[i].latitude},${routePoints[i].longitude}",
        ));
      }

      /// POLYLINES
      ///
// todo : remove disable from here or make false in release
      final disablePolylineCurrenly = false;
      if (!disablePolylineCurrenly) {
        if (currentLocation != null && dropLocation != null) {
          final String id = cacheId.replaceAll(" ", "_").toLowerCase();

          printlog("PolylineCacheHelper : id : $id");

          if (useCachedPolyline) {
            final savedPolyline = await PolylineCacheHelper.getEncodedRoute(id);

            if (savedPolyline.isEmptyOrNull) {
              printlog("PolylineCacheHelper : saved polyline empty");
              _savedPolylineCoordinates.clear();
              await handlePolylineUpdate(
                currentLocation,
                dropLocation,
                wayPoints: waypoints,
                lastDistance: _lastDistance,
                savedPolylineResult: _savedPolylineResult,
                savedPolylineCoordinates: _savedPolylineCoordinates,
                setLastDistance: setLastDistance,
                onDrawFromNearestPoint: (p) => drawFromNearestPoint(p, updatePolylineDisplay),
                onDrawFromNewCoordinates: (p) => drawFromNewCoordinates(p, updatePolylineDisplay),
              );
              final encodedPolyline = await PolylineCacheHelper.encodePolyline(_savedPolylineCoordinates);
              await PolylineCacheHelper.saveEncodedRoute(id, encodedPolyline);
            } else {
              printlog("PolylineCacheHelper : saved polyline not emptyyy");
              final savedPolylineCoords = PolylineCacheHelper.decodePolyline(savedPolyline!);
              _savedPolylineCoordinates = List.from(savedPolylineCoords);
              _lastDistance = null;
              await handlePolylineUpdate(
                currentLocation,
                dropLocation,
                wayPoints: waypoints,
                lastDistance: _lastDistance,
                savedPolylineResult: _savedPolylineResult,
                savedPolylineCoordinates: _savedPolylineCoordinates,
                setLastDistance: setLastDistance,
                onDrawFromNearestPoint: (p) => drawFromNearestPoint(p, updatePolylineDisplay),
                onDrawFromNewCoordinates: (p) => drawFromNewCoordinates(p, updatePolylineDisplay),
              );
            }
          } else {
            await handlePolylineUpdate(
              currentLocation,
              dropLocation,
              wayPoints: waypoints,
              lastDistance: _lastDistance,
              savedPolylineResult: _savedPolylineResult,
              savedPolylineCoordinates: _savedPolylineCoordinates,
              setLastDistance: setLastDistance,
              onDrawFromNearestPoint: (p) => drawFromNearestPoint(p, updatePolylineDisplay),
              onDrawFromNewCoordinates: (p) => drawFromNewCoordinates(p, updatePolylineDisplay),
            );
          }
        }
      }
    } catch (e) {
      updatePolylineDisplay([]);
// _polylines.add(
//   Polyline(
//     polylineId: const PolylineId('route'),
//     points: routePoints,
//     color: Colors.blue,
//     width: 4,
//     patterns: [],
//   ),
// );
    }

    Set<Marker> _markers = {};

    if (currentLocation != null) {
      double markerBearing = 0.0;
      if (dropLocation != null) {
        LatLng nextPoint = dropLocation.latLng;

        if (_remainingPolylineCoordinates.length > 3) {
          nextPoint = _remainingPolylineCoordinates[3];
        } else {
          nextPoint = _remainingPolylineCoordinates.lastOrNull ?? currentLocation.latLng;
        }

// if (rideData?.isConfirmedOrOnRide == true) markerBearing = calculateBearing(currentLocation.latLng, nextPoint);
        if (isCalculateMarkerBearing) markerBearing = calculateBearing(currentLocation.latLng, nextPoint);
      }

      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: currentLocation.latLng,
          icon: currentLocation.mapIcon,
          rotation: markerBearing,
          infoWindow: InfoWindow(
            title: 'Current Location',
            snippet: currentLocation.fullAddress,
          ),
        ),
      );
    }

    for (int i = 0; i < stopLocations.length; i++) {
// if (stopLocations[i].dropStatus != "1") {
      _markers.add(
        Marker(
          markerId: MarkerId('stop_$i'),
          position: stopLocations[i].latLng,
          icon: stopLocations[i].mapIcon,
          infoWindow: InfoWindow(
            title: 'Stop #${i + 1}',
            snippet: stopLocations[i].fullAddress,
          ),
        ),
      );
      routePoints.add(stopLocations[i].latLng);
// }
    }

    if (dropLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('drop_location'),
          position: dropLocation.latLng,
          icon: dropLocation.mapIcon,
          infoWindow: InfoWindow(
            title: 'Drop Location',
            snippet: dropLocation.fullAddress,
          ),
        ),
      );
      routePoints.add(dropLocation.latLng);
    }

    updateMarkers(_markers);
  }

  void setLastDistance(double ld) {
    _lastDistance = ld;
  }

  void drawFromNearestPoint(List<LatLng> remainingRoute, UpdatePolylineCallback updatePolylineDisplay) {
    _remainingPolylineCoordinates = remainingRoute;

    updatePolylineDisplay(remainingRoute);
  }

  void drawFromNewCoordinates(List<LatLng> points, UpdatePolylineCallback updatePolylineDisplay) {
    _savedPolylineCoordinates.clear();

    _savedPolylineCoordinates.addAll(points);

    updatePolylineDisplay(points);
  }

// Function to calculate bearing between two points
  double calculateBearing(LatLng start, LatLng end) {
    double startLat = start.latitude * (math.pi / 180);
    double startLng = start.longitude * (math.pi / 180);
    double endLat = end.latitude * (math.pi / 180);
    double endLng = end.longitude * (math.pi / 180);

    double dLng = endLng - startLng;

    double y = math.sin(dLng) * math.cos(endLat);
    double x = math.cos(startLat) * math.sin(endLat) - math.sin(startLat) * math.cos(endLat) * math.cos(dLng);

    double bearing = math.atan2(y, x);
    bearing = (bearing * 180 / math.pi + 360) % 360; // Convert to degrees

    return bearing;
  }

  double calculateMinDistanceToRoute(List<LatLng> _savedPolylineCoordinates, LocationModel currentLocation) {
    if (_savedPolylineCoordinates.isEmpty) return double.infinity;

    double minDistance = double.infinity;

    for (LatLng point in _savedPolylineCoordinates) {
      double distance = calculateDistance(currentLocation.latLng, point);
      if (distance < minDistance) {
        minDistance = distance;
      }
    }

    return minDistance;
  }

  double calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // Earth's radius in meters

    double lat1Rad = point1.latitude * (math.pi / 180);
    double lat2Rad = point2.latitude * (math.pi / 180);
    double deltaLatRad = (point2.latitude - point1.latitude) * (math.pi / 180);
    double deltaLngRad = (point2.longitude - point1.longitude) * (math.pi / 180);

    double a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) + math.cos(lat1Rad) * math.cos(lat2Rad) * math.sin(deltaLngRad / 2) * math.sin(deltaLngRad / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  LatLng findNearestPointOnRoute(List<LatLng> _savedPolylineCoordinates, LatLng currentLocation) {
    if (_savedPolylineCoordinates.isEmpty) return currentLocation;

    LatLng nearestPoint = _savedPolylineCoordinates.first;
    double minDistance = double.infinity;

    for (LatLng point in _savedPolylineCoordinates) {
      double distance = calculateDistance(currentLocation, point);
      if (distance < minDistance) {
        minDistance = distance;
        nearestPoint = point;
      }
    }

    return nearestPoint;
  }

  Future<void> fitMapToMarkers(GoogleMapController? mapController, Set<Marker> markers, {double? padding}) async {
    devlog("fitMapToMarkers called");
    if (markers.isEmpty) return;

    List<LatLng> positions = markers.map((marker) => marker.position).toList();

    if (positions.length == 1) {
      try {
        await mapController?.animateCamera(CameraUpdate.newLatLngZoom(positions.first, 15), duration: Duration(milliseconds: 300));
      } catch (e) {
        devlogError("mapanimatecameraa error : $e");
      }
      return;
    }

    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;

    for (LatLng position in positions) {
      minLat = math.min(minLat, position.latitude);
      maxLat = math.max(maxLat, position.latitude);
      minLng = math.min(minLng, position.longitude);
      maxLng = math.max(maxLng, position.longitude);
    }

    try {
      mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          padding ?? 50.0, // padding
        ),
      );
    } catch (e) {
      devlogError("mapanimatecameraa error : $e");
    }
  }

  printlog(String msg) {
    if (kDebugMode) {
      print("printlog customer -> " + msg);
    }
  }

  Future<void> handlePolylineUpdate(LocationModel startPoint,
      LocationModel endPoint, {
        required double? lastDistance,
        required List<PolylineWayPoint> wayPoints,
        required List<LatLng> savedPolylineCoordinates,
        required PolylineResult? savedPolylineResult,
        required void Function(double lastDistance) setLastDistance,
        required UpdatePolylineCallback onDrawFromNearestPoint,
        required UpdatePolylineCallback onDrawFromNewCoordinates,
      }) async {
    if (savedPolylineCoordinates.isNotEmpty) {
      printlog("saved polyline not empty");
      double minDistance = calculateMinDistanceToRoute(savedPolylineCoordinates, startPoint);

      if (minDistance == lastDistance) {
        printlog("Remains existing polyline - distance: ${minDistance.toStringAsFixed(2)}m");
        return;
      }

// lastDistance = minDistance;
      setLastDistance(minDistance);

      if (minDistance <= DISTANCE_THRESHOLD) {
        drawPolylineFromNearestPoint(startPoint, savedPolylineCoordinates, onDrawFromNearestPoint: onDrawFromNearestPoint);
        printlog("Using existing polyline - distance: ${minDistance.toStringAsFixed(2)}m");
        return;
      } else {
        printlog("Driver too far from route (${minDistance.toStringAsFixed(2)}m) - fetching new polyline");
      }
    }

    await fetchNewPolylineCoordinates(startPoint, endPoint, wayPoints: wayPoints, savedPolylineResult: savedPolylineResult, onDrawFromNewCoordinates: onDrawFromNewCoordinates);
  }

  void drawPolylineFromNearestPoint(LocationModel currentLocation, List<LatLng> savedPolylineCoordinates, {required UpdatePolylineCallback onDrawFromNearestPoint}) {
    LatLng nearestPoint = findNearestPointOnRoute(savedPolylineCoordinates, currentLocation.latLng);
    int nearestIndex = savedPolylineCoordinates.indexOf(nearestPoint);

    List<LatLng> remainingRoute = [];
    remainingRoute.add(currentLocation.latLng);

    if (nearestIndex != -1) {
      remainingRoute.addAll(savedPolylineCoordinates.sublist(nearestIndex));
    }

    onDrawFromNearestPoint(remainingRoute);
  }

  bool gettingData = false;

  Future<void> fetchNewPolylineCoordinates(LocationModel startPoint,
      LocationModel endPoint, {
        required List<PolylineWayPoint> wayPoints,
        required PolylineResult? savedPolylineResult,
        required UpdatePolylineCallback onDrawFromNewCoordinates,
      }) async {
    PolylineResult? result = savedPolylineResult;
    printlog("polyline api called log : $savedPolylineResult");

    if (gettingData) return;
    gettingData = true;
    try {
      result = await _polylinePoints.getRouteBetweenCoordinates(
          request: PolylineRequest(
            origin: PointLatLng(
              startPoint.latLng.latitude,
              startPoint.latLng.longitude,
            ),
            destination: PointLatLng(
              endPoint.latLng.latitude,
              endPoint.latLng.longitude,
            ),
            optimizeWaypoints: true,
            mode: TravelMode.driving,
            wayPoints: wayPoints,
            headers: {
              "Authorization": "Bearer ${Preferences.getString(Preferences.accesstoken).toString()}",
              "Accept": "*/*",
              "Content-Type": "application/json",
            },
          ));

      gettingData = false;
      savedPolylineResult = result;
      printlog("polyline api called log2 : $savedPolylineResult");
    } catch (e) {
      gettingData = false;
      printlog("polyline api error: $e");
      return;
    }

    // List<LatLng> newPolylineCoordinates = [];

    if (result.points.isNotEmpty) {
      // newPolylineCoordinates.clear();
      //
      // for (var point in result.points) {
      //   newPolylineCoordinates.add(LatLng(point.latitude, point.longitude));
      // }

      printlog("_updatePolylineDisplay before");
      onDrawFromNewCoordinates(result.points.map((e) => LatLng(e.latitude, e.longitude)).toList());
    }
  }
}