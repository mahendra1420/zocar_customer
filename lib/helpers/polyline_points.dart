import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:zocar/utils/preferences.dart';

import '../constant/constant.dart';



enum TravelMode { driving, bicycling, transit, walking }

polylinePrint(String msg) {
  if (kDebugMode) {
    debugPrint("POLYLINE PRINT -> $msg");
  }
}

class PolylinePoints {
  Future<PolylineResult> getRouteBetweenCoordinates({required PolylineRequest request}) async {
    try {
      polylinePrint("getRouteBetweenCoordinates CALLED WITH REQUEST : ${request.toJson()}");
      var result = await NetworkUtil().getRouteBetweenCoordinates(request: request);
      return result.isNotEmpty ? result[0] : PolylineResult(errorMessage: "No result found");
    } catch (e) {
      rethrow;
    }
  }

  List<PointLatLng> decodePolyline(String encodedString) {
    return PolylineDecoder.run(encodedString);
  }
}

class NetworkUtil {
  static const String STATUS_OK = "ok";

  Future<List<PolylineResult>> getRouteBetweenCoordinates({
    required PolylineRequest request,
  }) async {
    List<PolylineResult> results = [];

    final dio = Dio();
    final token = Preferences.getString(Preferences.accesstoken).toString();

    final googleApiHeader = await GoogleApiHeaders().getHeaders();

    // final headers = {
    //   "Authorization": "Bearer $token",
    //   "Content-Type": "application/json",
    //   'x-access-key': Apis.apiKey,
    // };

    final response = await dio.post(
      "https://maps.googleapis.com/maps/api/directions/json",
      queryParameters: request.toJson(),
      options: Options(
        validateStatus: (status) => status! <= 500,
        headers: googleApiHeader,
      ),
    );

    polylinePrint("DIRECTION API RESPONSE status: ${response.statusCode} : ${(response.data)} : token : ${token}");

    // await logDirectionApiCall(
    //   origin: request.origin.toString(),
    //   destination: request.destination.toString(),
    //   status: response.data['status'],
    // );


    if (response.statusCode == 200) {
      var parsedJson = response.data;
      polylinePrint("DIRECTION API RESPONSE : $parsedJson");
      if (parsedJson["status"]?.toLowerCase() == STATUS_OK && parsedJson["routes"] != null && parsedJson["routes"].isNotEmpty) {
        List<dynamic> routeList = parsedJson["routes"];
        for (var route in routeList) {
          results.add(PolylineResult(
            points: PolylineDecoder.run(route["overview_polyline"]["points"]),
            errorMessage: "",
            status: parsedJson["status"],
            totalDistanceValue: route['legs'].map((leg) => leg['distance']['value']).reduce((v1, v2) => v1 + v2),
            distanceTexts: <String>[...route['legs'].map((leg) => leg['distance']['text'])],
            distanceValues: <int>[...route['legs'].map((leg) => leg['distance']['value'])],
            overviewPolyline: route["overview_polyline"]["points"],
            totalDurationValue: route['legs'].map((leg) => leg['duration']['value']).reduce((v1, v2) => v1 + v2),
            durationTexts: <String>[...route['legs'].map((leg) => leg['duration']['text'])],
            durationValues: <int>[...route['legs'].map((leg) => leg['duration']['value'])],
            endAddress: route["legs"].last['end_address'],
            startAddress: route["legs"].first['start_address'],
          ));
        }
      } else {
        throw Exception("Unable to get route: Response ---> ${parsedJson["status"]} ");
      }
    }
    return results;
  }
}

class PolylineRequest {
  final PointLatLng origin;
  final PointLatLng destination;
  final TravelMode mode;
  final List<PolylineWayPoint> wayPoints;
  final bool avoidHighways;
  final bool avoidTolls;
  final bool avoidFerries;
  final bool optimizeWaypoints;

  final String? transitMode;

  final bool alternatives;
  final int? arrivalTime;
  final int? departureTime;
  final Uri? proxy;
  final Map<String, String>? headers;

  PolylineRequest({
    this.proxy,
    this.headers,
    required this.origin,
    required this.destination,
    required this.mode,
    this.wayPoints = const [],
    this.avoidHighways = false,
    this.avoidTolls = false,
    this.avoidFerries = false,
    this.optimizeWaypoints = false,
    this.alternatives = false,
    this.arrivalTime,
    this.departureTime,
    this.transitMode,
  });

  Map<String, String> toJson() {
    final params = {
      "origin": '${origin.latitude},${origin.longitude}',
      "destination": '${destination.latitude},${destination.longitude}',
      "mode": mode.name.toString(),
      'key': Constant.kGoogleApiKey ?? "",
      "user_id": Preferences.getInt(Preferences.userId).toString(),
    };
    if (wayPoints.isNotEmpty) {
      List wayPointsArray = [];
      wayPoints.forEach((point) => wayPointsArray.add(point.location));
      String wayPointsString = wayPointsArray.join('|');
      if (optimizeWaypoints) {
        wayPointsString = 'optimize:true|$wayPointsString';
      }
      params.addAll({"waypoints": wayPointsString});
    }
    return params;
  }
}

class PolylineResult {
  /// the api status retuned from google api
  ///
  /// returns OK if the api call is successful
  String? status;

  /// list of decoded points
  List<PointLatLng> points;

  /// the error message returned from google, if none, the result will be empty
  String? errorMessage;

  /// list of decoded points
  List<PointLatLng> alternatives;

  List<String>? distanceTexts;
  List<int>? distanceValues;
  int? totalDistanceValue;
  List<String>? durationTexts;
  List<int>? durationValues;
  int? totalDurationValue;
  String? endAddress;
  String? startAddress;
  String? overviewPolyline;

  PolylineResult(
      {this.status,
      this.points = const [],
      this.errorMessage = "",
      this.alternatives = const [],
      this.distanceTexts,
      this.distanceValues,
      this.totalDistanceValue,
      this.durationTexts,
      this.durationValues,
      this.totalDurationValue,
      this.endAddress,
      this.startAddress,
      this.overviewPolyline});
}

/// Decode the google encoded string using Encoded Polyline Algorithm Format
/// for more info about the algorithm check https://developers.google.com/maps/documentation/utilities/polylinealgorithm
///
class PolylineDecoder {
  static List<PointLatLng> run(String encoded) {
    List<PointLatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    BigInt big0 = BigInt.from(0);
    BigInt big0x1f = BigInt.from(0x1f);
    BigInt big0x20 = BigInt.from(0x20);

    while (index < len) {
      int shift = 0;
      BigInt b, result;
      result = big0;
      do {
        b = BigInt.from(encoded.codeUnitAt(index++) - 63);
        result |= (b & big0x1f) << shift;
        shift += 5;
      } while (b >= big0x20);
      BigInt rShifted = result >> 1;
      int dLat;
      if (result.isOdd)
        dLat = (~rShifted).toInt();
      else
        dLat = rShifted.toInt();
      lat += dLat;

      shift = 0;
      result = big0;
      do {
        b = BigInt.from(encoded.codeUnitAt(index++) - 63);
        result |= (b & big0x1f) << shift;
        shift += 5;
      } while (b >= big0x20);
      rShifted = result >> 1;
      int dLng;
      if (result.isOdd)
        dLng = (~rShifted).toInt();
      else
        dLng = rShifted.toInt();
      lng += dLng;

      points.add(PointLatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble()));
    }

    return points;
  }
}

/// A pair of latitude and longitude coordinates, stored as degrees.
class PointLatLng {
  /// Creates a geographical location specified in degrees [latitude] and
  /// [longitude].
  ///
  const PointLatLng(double latitude, double longitude)
      : this.latitude = latitude,
        this.longitude = longitude;

  /// The latitude in degrees.
  final double latitude;

  /// The longitude in degrees
  final double longitude;

  @override
  String toString() {
    return "lat: $latitude / longitude: $longitude";
  }
}

class PolylineWayPoint {
  /// the location of the waypoint,
  /// You can specify waypoints using the following values:
  /// --- Latitude/longitude coordinates (lat/lng): an explicit value pair. (-34.92788%2C138.60008 comma, no space),
  /// --- Place ID: The unique value specific to a location. This value is only available only if
  ///     the request includes an API key or Google Maps Platform Premium Plan client ID (ChIJGwVKWe5w44kRcr4b9E25-Go
  /// --- Address string (Charlestown, Boston,MA)
  /// ---
  String location;

  /// is a boolean which indicates that the waypoint is a stop on the route,
  /// which has the effect of splitting the route into two routes
  bool stopOver;

  PolylineWayPoint({required this.location, this.stopOver = true});

  @override
  String toString() {
    if (stopOver) {
      return location;
    } else {
      return "via:$location";
    }
  }
}
