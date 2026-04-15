import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart' as get_cord_address;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:zocar/constant/constant.dart';
import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/controller/coupon_controller.dart';
import 'package:zocar/controller/home_controller.dart';
import 'package:zocar/helpers/pending_payment_dialog.dart';
import 'package:zocar/helpers/widget_binding.dart';
import 'package:zocar/themes/constant_colors.dart';

import '../../helpers/devlog.dart';
import 'date_time_picker_widget.dart';
import 'choose_vehicle_bottom_sheet.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Controllers
  final HomeController homeCtr = Get.put(HomeController());
  final CouponController couponCtr = Get.put(CouponController());

  // Map
  GoogleMapController? _mapController;
  Rx<Location> currentLocation = Location().obs;
  Map<PolylineId, Polyline> polyLines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> waypoints = [];

  // Trip date-time state passed into the bottom sheet
  DateTime dailyDateTime = DateTime.now();
  DateTime osStartDateTime = DateTime.now().add(const Duration(hours: 1));
  DateTime osEndDateTime = DateTime.now();
  bool isRoundTrip = false;

  // Key lets SearchPage reach into TripDateTimeSelector if ever needed
  final GlobalKey<TripDateTimeSelectorState> tripDateTimeKey = GlobalKey<TripDateTimeSelectorState>();

  ValueNotifier<bool> locationLoading = ValueNotifier(false);

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    devlog("SearchPage → initState");

    homeCtr.multiStopList.clear();
    homeCtr.multiStopListNew.clear();
    homeCtr.razorpay.clear();
    homeCtr.totalAmount.value = 0.0;
    homeCtr.selectedVehicle.value = "";

    getCurrentLocation();

    if (homeCtr.departureLatLong != const LatLng(0, 0) && homeCtr.destinationLatLong != const LatLng(0, 0)) {
      getDirections();
      homeCtr.confirmWidgetVisible.value = true;
    }

    widgetBinding((_) async {
      try {
        final value = await homeCtr.placeSelectAPI(context);
        if (value != null) {
          homeCtr.destinationController.text = value.result.formattedAddress.toString();
          setDestinationMarker(LatLng(
            value.result.geometry!.location.lat,
            value.result.geometry!.location.lng,
          ));
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ── Location ───────────────────────────────────────────────────────────────

  Future<void> getCurrentLocation() async {
    homeCtr.searchVisible.value = true;
    locationLoading.value = true;

    try {
      final LocationData location = await currentLocation.value.getLocation();
      final List<get_cord_address.Placemark> placeMarks = await get_cord_address.placemarkFromCoordinates(
        location.latitude ?? 0.0,
        location.longitude ?? 0.0,
      );

      final p = placeMarks.first;
      final address = _joinNonEmpty([
        p.subLocality,
        p.street,
        p.name,
        p.subAdministrativeArea,
        p.administrativeArea,
        p.country,
        p.postalCode,
      ]);

      if (mounted) {
        setState(() {
          homeCtr.departureController.text = address;
          setDepartureMarker(LatLng(location.latitude ?? 0.0, location.longitude ?? 0.0));
        });
      }
    } catch (e) {
      devlogError("getCurrentLocation error: $e");
    } finally {
      locationLoading.value = false;
    }
  }

  /// Joins non-empty address parts with ", ".
  String _joinNonEmpty(List<String?> parts) {
    return parts.where((p) => p != null && p.isNotEmpty).map((p) => "$p, ").join();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: ConstantColors.primary,
        statusBarIconBrightness: Brightness.light,
      ),
      child: PopScope(
        onPopInvokedWithResult: (_, __) async {
          homeCtr.destinationController.clear();
          homeCtr.destinationLatLong.value = const LatLng(0, 0);
          homeCtr.confirmWidgetVisible.value = false;
          homeCtr.markers.remove("Destination");
          homeCtr.update();
        },
        child: Scaffold(
          appBar: _buildAppBar(),
          body: Column(
            children: [
              _buildSearchPanel(),
              Expanded(child: _buildMapStack()),
            ],
          ),
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(kImgWhiteBg),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(ConstantColors.primary, BlendMode.modulate),
          ),
        ),
      ),
      centerTitle: true,
      title: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(kImgZocar, width: 100),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(top: 3, left: 8),
        child: ElevatedButton(
          onPressed: () {
            homeCtr.destinationController.clear();
            homeCtr.destinationLatLong.value = const LatLng(0, 0);
            homeCtr.confirmWidgetVisible.value = false;
            Get.back();
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: Colors.transparent,
            padding: const EdgeInsets.all(10),
            elevation: 0,
          ),
          child: const Padding(
            padding: EdgeInsets.all(4.0),
            child: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          ),
        ),
      ),
      actions: [
        ValueListenableBuilder<bool>(
          valueListenable: locationLoading,
          builder: (_, loading, __) => Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () async {
                await getCurrentLocation();
                setState(() {});
              },
              icon: loading
                  ? const CupertinoActivityIndicator(color: Colors.white)
                  : const Icon(Icons.my_location_rounded, color: Colors.white, size: 22),
            ),
          ),
        ),
      ],
    );
  }

  // ── Search panel ───────────────────────────────────────────────────────────

  Widget _buildSearchPanel() {
    return Visibility(
      visible: homeCtr.searchVisible.value,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
        child: Column(
          children: [
            // Departure
            Builder(builder: (ctx) {
              return Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        try {
                          final value = await homeCtr.placeSelectAPI(ctx);
                          if (value != null) {
                            homeCtr.departureController.text = value.result.formattedAddress.toString();
                            setDepartureMarker(LatLng(
                              value.result.geometry!.location.lat,
                              value.result.geometry!.location.lng,
                            ));
                          }
                        } catch (_) {}
                      },
                      child: _buildTextField(
                        title: "Departure".tr,
                        textController: homeCtr.departureController,
                        icon: "assets/images/departure_icon.png",
                        color: Colors.deepOrange,
                      ),
                    ),
                  ),
                ],
              );
            }),

            // Multi-stop list
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) newIndex -= 1;
                  final item = homeCtr.multiStopListNew.removeAt(oldIndex);
                  homeCtr.multiStopListNew.insert(newIndex, item);
                });
              },
              children: [
                for (int i = 0; i < homeCtr.multiStopListNew.length; i++)
                  Builder(
                    key: ValueKey(homeCtr.multiStopListNew[i]),
                    builder: (_) {
                      final stop = homeCtr.multiStopListNew[i];
                      return Column(
                        children: [
                          const Divider(),
                          InkWell(
                            onTap: () async {
                              try {
                                final value = await homeCtr.placeSelectAPI(context);
                                if (value != null) {
                                  stop.editingController.text = value.result.formattedAddress.toString();
                                  stop.latitude = value.result.geometry!.location.lat.toString();
                                  stop.longitude = value.result.geometry!.location.lng.toString();
                                  setStopMarker(
                                    LatLng(value.result.geometry!.location.lat, value.result.geometry!.location.lng),
                                    i,
                                  );
                                }
                              } catch (_) {}
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  String.fromCharCode(i + 65),
                                  style: TextStyle(fontSize: 16, color: ConstantColors.hintTextColor),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: _buildTextField(
                                    title: "Where do you want to stop ?".tr,
                                    textController: stop.editingController,
                                    icon: "assets/images/search_destination.png",
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                InkWell(
                                  onTap: () {
                                    waypoints.removeWhere((w) => w.latitude == double.parse(stop.latitude));
                                    homeCtr.removeStops(i);
                                    homeCtr.markers.remove("Stop $i");
                                    getDirections();
                                  },
                                  child: Icon(Icons.close, size: 25, color: ConstantColors.hintTextColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),

            // Destination
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final value = await homeCtr.placeSelectAPI(context);
                      if (value != null) {
                        homeCtr.destinationController.text = value.result.formattedAddress.toString();
                        setDestinationMarker(LatLng(
                          value.result.geometry!.location.lat,
                          value.result.geometry!.location.lng,
                        ));
                      }
                    },
                    child: _buildTextField(
                      title: "Where do you want to go ?".tr,
                      textController: homeCtr.destinationController,
                      icon: "assets/images/search_destination.png",
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(),

            // Add stop row
            Row(
              children: [
                const Spacer(),
                InkWell(
                  onTap: () => homeCtr.addStops(),
                  child: Row(
                    children: [
                      const Icon(Icons.add_circle, color: Colors.deepOrange),
                      const SizedBox(width: 5),
                      Text('Add stop'.tr, style: TextStyle(color: ConstantColors.hintTextColor, fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Map + confirm overlay ──────────────────────────────────────────────────

  Widget _buildMapStack() {
    return Stack(
      children: [
        GoogleMap(
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          padding: const EdgeInsets.only(top: 8.0),
          compassEnabled: false,
          initialCameraPosition: CameraPosition(target: homeCtr.center, zoom: 14.0),
          minMaxZoomPreference: const MinMaxZoomPreference(8.0, 20.0),
          buildingsEnabled: false,
          onMapCreated: (GoogleMapController ctrl) async {
            _mapController = ctrl;
            final loc = await currentLocation.value.getLocation();
            _mapController!.moveCamera(CameraUpdate.newLatLngZoom(
              LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0),
              14,
            ));
          },
          polylines: Set<Polyline>.of(polyLines.values),
          myLocationEnabled: true,
          markers: homeCtr.markers.values.toSet(),
        ),
        Visibility(
          visible: homeCtr.confirmWidgetVisible.value,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: _buildConfirmRow(),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmRow() {
    homeCtr.searchVisible.value = true;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: OutlinedButton.icon(
              onPressed: () {
                Get.back();
                homeCtr.destinationController.clear();
              },
              icon: const Icon(Icons.arrow_back, size: 18),
              label: Text("Back".tr),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: ElevatedButton.icon(
              onPressed: _onContinueTapped,
              label: Text("Continue".tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: ConstantColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onContinueTapped() async {
    ShowToastDialog.showLoader("Please wait");

    final durationValue = await homeCtr.getDurationDistance(
      homeCtr.departureLatLong.value,
      homeCtr.destinationLatLong.value,
      waypoints,
    );
    if (durationValue == null) {
      ShowToastDialog.closeLoader();
      return;
    }

    final pendingPayment = await homeCtr.getUserPendingPayment();
    if (pendingPayment == null) {
      ShowToastDialog.closeLoader();
      return;
    }

    _applyDistanceAndDuration(durationValue);

    if (pendingPayment['success'] == "success" && pendingPayment['data']['amount'] != 0) {
      ShowToastDialog.closeLoader();
      if (mounted) pendingPaymentDialog(context);
      return;
    }

    final vehCateVal = await homeCtr.getVehicleCategory();
    ShowToastDialog.closeLoader();

    if (vehCateVal != null && vehCateVal.success == "Success") {
      homeCtr.selectVehicle(null);
      if (mounted) {
        showChooseVehicleBottomSheet(
          context: context,
          vehicleCategoryModel: vehCateVal,
          dailyDateTime: dailyDateTime,
          osStartDateTime: osStartDateTime,
          osEndDateTime: osEndDateTime,
          isRoundTrip: isRoundTrip,
          tripDateTimeKey: tripDateTimeKey,
          type: pendingPayment['success'] == "success" ? "1" : "2",
        );
      }
    }
  }

  void _applyDistanceAndDuration(Map durationValue) {
    final meters = durationValue['rows'].first['elements'].first['distance']['value'];
    homeCtr.distance.value = Constant.distanceUnit == "KM" ? meters / 1000.0 : meters / 1609.34;
    homeCtr.duration.value = durationValue['rows'].first['elements'].first['duration']['text'];
  }

  // ── Marker helpers ─────────────────────────────────────────────────────────

  void setDepartureMarker(LatLng departure) {
    setState(() {
      homeCtr.markers.remove("Departure");
      homeCtr.markers['Departure'] = Marker(
        markerId: const MarkerId('Departure'),
        infoWindow: const InfoWindow(title: "Departure"),
        position: departure,
        icon: homeCtr.departureIcon!,
      );
      homeCtr.departureLatLong.value = departure;
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: departure, zoom: 14)),
      );
      if (homeCtr.departureLatLong != const LatLng(0, 0) && homeCtr.destinationLatLong != const LatLng(0, 0)) {
        getDirections();
        homeCtr.confirmWidgetVisible.value = true;
      }
    });
  }

  void setDestinationMarker(LatLng destination) {
    setState(() {
      homeCtr.markers['Destination'] = Marker(
        markerId: const MarkerId('Destination'),
        infoWindow: const InfoWindow(title: "Destination"),
        position: destination,
        icon: homeCtr.destinationIcon!,
      );
      homeCtr.destinationLatLong.value = destination;
      if (homeCtr.departureLatLong != const LatLng(0, 0) && homeCtr.destinationLatLong != const LatLng(0, 0)) {
        getDirections();
        homeCtr.confirmWidgetVisible.value = true;
      }
    });
  }

  void setStopMarker(LatLng destination, int index) {
    setState(() {
      homeCtr.markers['Stop $index'] = Marker(
        markerId: MarkerId('Stop $index'),
        infoWindow: InfoWindow(title: "Stop ${String.fromCharCode(index + 65)}"),
        position: destination,
        icon: homeCtr.stopIcon!,
      );
      waypoints.add(LatLng(destination.latitude, destination.longitude));
      if (homeCtr.departureLatLong != const LatLng(0, 0) && homeCtr.destinationLatLong != const LatLng(0, 0)) {
        getDirections();
        homeCtr.confirmWidgetVisible.value = true;
      }
    });
  }

  // ── Polyline helpers ───────────────────────────────────────────────────────

  Future<void> getDirections() async {
    final wayPointList = homeCtr.multiStopList
        .map((s) => PolylineWayPoint(location: s.editingController.text))
        .toList();

    final result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: Constant.kGoogleApiKey.toString(),
      request: PolylineRequest(
        origin: PointLatLng(homeCtr.departureLatLong.value.latitude, homeCtr.departureLatLong.value.longitude),
        destination: PointLatLng(homeCtr.destinationLatLong.value.latitude, homeCtr.destinationLatLong.value.longitude),
        mode: TravelMode.driving,
        wayPoints: wayPointList,
      ),
    );

    final coords = result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
    _addPolyLine(coords);
  }

  void _addPolyLine(List<LatLng> coords) {
    const id = PolylineId("poly");
    polyLines[id] = Polyline(
      polylineId: id,
      color: ConstantColors.primary,
      points: coords,
      width: 4,
      geodesic: true,
    );
    _updateCameraToFitRoute(coords.first, coords.last);
    setState(() {});
  }

  Future<void> _updateCameraToFitRoute(LatLng source, LatLng destination) async {
    if (_mapController == null) return;

    late LatLngBounds bounds;
    if (source.latitude > destination.latitude && source.longitude > destination.longitude) {
      bounds = LatLngBounds(southwest: destination, northeast: source);
    } else if (source.longitude > destination.longitude) {
      bounds = LatLngBounds(
        southwest: LatLng(source.latitude, destination.longitude),
        northeast: LatLng(destination.latitude, source.longitude),
      );
    } else if (source.latitude > destination.latitude) {
      bounds = LatLngBounds(
        southwest: LatLng(destination.latitude, source.longitude),
        northeast: LatLng(source.latitude, destination.longitude),
      );
    } else {
      bounds = LatLngBounds(southwest: source, northeast: destination);
    }

    await _animateCameraWithRetry(CameraUpdate.newLatLngBounds(bounds, 90));
  }

  Future<void> _animateCameraWithRetry(CameraUpdate update) async {
    _mapController!.animateCamera(update);
    final r1 = await _mapController!.getVisibleRegion();
    final r2 = await _mapController!.getVisibleRegion();
    if (r1.southwest.latitude == -90 || r2.southwest.latitude == -90) {
      await _animateCameraWithRetry(update);
    }
  }

  // ── Text field builder ─────────────────────────────────────────────────────

  Widget _buildTextField({
    required dynamic title,
    required TextEditingController textController,
    required String icon,
    required MaterialColor color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 2.0, bottom: 2.0),
      child: TextField(
        controller: textController,
        textInputAction: TextInputAction.done,
        style: TextStyle(color: ConstantColors.titleTextColor),
        decoration: InputDecoration(
          hintText: title,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Image.asset(icon, height: 23, width: 23),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
          ),
          hintStyle: const TextStyle(color: Colors.grey),
        ),
        enabled: false,
      ),
    );
  }
}