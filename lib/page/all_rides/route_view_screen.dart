import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:lottie/lottie.dart' as l;
import 'package:share_plus/share_plus.dart';
import 'package:zocar/constant/constant.dart';
import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/controller/main_page_controller.dart';
import 'package:zocar/controller/ride_details_controller.dart';
import 'package:zocar/helpers/devlog.dart';
import 'package:zocar/model/driver_location_update.dart';
import 'package:zocar/model/ride_model.dart';
import 'package:zocar/page/chats_screen/conversation_screen.dart';
import 'package:zocar/page/main_page.dart';
import 'package:zocar/themes/constant_colors.dart';
import 'package:zocar/themes/custom_alert_dialog.dart';
import 'package:zocar/themes/custom_dialog_box.dart';
import 'package:zocar/utils/global_functions.dart';
import 'package:zocar/utils/preferences.dart';
import 'package:zocar/widget/star_rating.dart';

import '../../helpers/location_service.dart';
import '../../helpers/polyline_main_helper.dart';
import '../../helpers/polyline_points.dart';

class RouteViewScreen extends StatefulWidget {
  const RouteViewScreen({super.key});

  @override
  State<RouteViewScreen> createState() => _RouteViewScreenState();
}

class _RouteViewScreenState extends State<RouteViewScreen> {
  final controllerRideDetails = Get.put(RideDetailsController());
  final controllerDashBoard = Get.put(MainPageController());

  dynamic argumentData = Get.arguments;
  GoogleMapController? _controller;

  PolylineHelper polylineHelper = PolylineHelper();

  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? taxiIcon;
  BitmapDescriptor? stopIcon;
  LatLng? departureLatLong;
  LatLng? destinationLatLong;

  String? type;
  RideData? rideData;
  String driverEstimateArrivalTime = '';

  final resonController = TextEditingController();

  PolylinePoints polylinePoints = PolylinePoints();

  Set<Marker> get markers => _markers;
  Set<Marker> _markers = {};

  Set<Polyline> get polylines => _polylines;
  Set<Polyline> _polylines = {};

  double zoomLevel = 17;
  StreamSubscription<DocumentSnapshot>? _driverLocationSubscription;

  List<LocationModel> get stops =>
      rideData?.stops
          ?.map(
            (e) => LocationModel(
              fullAddress: "",
              mapIcon: stopIcon,
              latLng: LatLng(double.tryParse(e.latitude ?? "0") ?? 0, double.tryParse(e.longitude ?? "0") ?? 0),
            ),
          )
          .toList() ??
      [];

  @override
  void initState() {
    super.initState();
    type = argumentData?['type'];
    rideData = argumentData?['data'];

    polylineHelper.clearPolylineCache();
    setIcons().then((value) {
      driverLocationUpdates();
    });
  }

  @override
  void dispose() {
    _driverLocationSubscription?.cancel();
    _driverLocationSubscription = null;
    _controller?.dispose();
    super.dispose();
  }

  setIcons() async {
    departureIcon = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(10, 10)), "assets/icons/pickup.png");
    destinationIcon = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(10, 10)), "assets/icons/dropoff.png");
    taxiIcon = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(10, 10)), "assets/icons/ic_taxi.png");
    stopIcon = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(10, 10)), "assets/icons/location.png");
  }

  void driverLocationUpdates() async {
    if (rideData != null) {
      if (rideData!.latitudeDepart.toString().isNotEmpty) {
        departureLatLong = LatLng(double.parse(rideData!.latitudeDepart.toString()), double.parse(rideData!.longitudeDepart.toString()));
      }
      if (rideData!.latitudeArrivee.toString().isNotEmpty) {
        destinationLatLong = LatLng(double.parse(rideData!.latitudeArrivee.toString()), double.parse(rideData!.longitudeArrivee.toString()));
      }

      if (rideData!.statut == "confirmed" || rideData!.statut == "on ride") {
        _startDriverLocationListener();
      } else {
        _stopDriverListener();
        await setMarkersAndPolyline(
          currentLocation: LocationModel(fullAddress: "", latLng: departureLatLong!, mapIcon: departureIcon),
          stopLocations: stops,
          dropLocation: (destinationLatLong == null) ? null : LocationModel(fullAddress: "", latLng: destinationLatLong ?? LatLng(0, 0), mapIcon: destinationIcon),
        );
        await polylineHelper.fitMapToMarkers(_controller, markers);
      }
    }
  }

   setMarkersAndPolyline({required LocationModel? currentLocation, required List<LocationModel> stopLocations, required LocationModel? dropLocation}) async {
    await  polylineHelper.setupMarkersAndPolylines(
      currentLocation: currentLocation,
      stopLocations: stopLocations,
      dropLocation: dropLocation,
      cacheId: "${rideData?.id?.toString()}_${rideData?.statut?.toString()}",
      isCalculateMarkerBearing: rideData?.isConfirmedOrOnRide == true,
      initState: () {
        _markers.clear();
      },
      updatePolylineDisplay: (points) {
        devlog(">> Polyline Points Length: ${points.length}");

        _polylines = {
          Polyline(
            polylineId: const PolylineId('Trip-Polyline'),
            endCap: Cap.roundCap,
            startCap: Cap.roundCap,
            width: 3,
            jointType: JointType.bevel,
            geodesic: true,
            color: Colors.black,
            points: points,
          )
        };
        setState(() {});
      },
      updateMarkers: (markers) {
        devlog(">> Markers Length: ${markers.length}");
        _markers = markers;
        setState(() {});
      },
    );
  }

  void _startDriverLocationListener() {
    if (_driverLocationSubscription != null) return; // already listening

    if (rideData == null || rideData!.idConducteur == null) return;

    _driverLocationSubscription = Constant.driverLocationUpdateCollection.doc(rideData!.idConducteur).snapshots().listen((event) async {
      if (!event.exists) return;

      final data = event.data() as Map<String, dynamic>;
      final driverLocationModel = DriverLocationModel.fromJson(data);

      final driverLatLng = LatLng(driverLocationModel.driverLatitude, driverLocationModel.driverLongitude);

      if (rideData!.statut == 'confirmed') {
        await setMarkersAndPolyline(
          currentLocation: LocationModel(fullAddress: "", latLng: driverLatLng, mapIcon: taxiIcon),
          stopLocations: [],
          dropLocation: LocationModel(fullAddress: "", latLng: departureLatLong!, mapIcon: destinationIcon),
        );
      } else if (rideData!.statut == 'on ride') {
        await setMarkersAndPolyline(
          currentLocation: LocationModel(fullAddress: "", latLng: driverLatLng, mapIcon: taxiIcon),
          stopLocations: stops,
          dropLocation: LocationModel(fullAddress: "", latLng: destinationLatLong!, mapIcon: destinationIcon),
        );
      }

      try {
        await _controller?.animateCamera(
          CameraUpdate.newLatLngZoom(driverLatLng, zoomLevel),
        );
      } catch (_) {}
    });
  }

  void _stopDriverListener() {
    _driverLocationSubscription?.cancel();
    _driverLocationSubscription = null;
  }


  void clearSavedData({bool clearMarkers = false, bool listen = true}) {
    polylineHelper.printlog("cleared");
    polylineHelper.clearPolylineCache();
    if (clearMarkers) _markers.clear();
    if (listen) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            GoogleMap(
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              myLocationEnabled: false,
              initialCameraPosition: const CameraPosition(
                target: LatLng(48.8561, 2.2930),
                zoom: 14.0,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
                _controller!.moveCamera(CameraUpdate.newLatLngZoom(departureLatLong!, 12));
              },
              polylines: Set<Polyline>.from(polylines),
              markers: Set<Marker>.from(markers),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    _stopDriverListener();
                    Get.back();
                  },
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (rideData?.statut == 'confirmed' && driverEstimateArrivalTime.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [ConstantColors.primary.withOpacity(0.1), ConstantColors.primary.withOpacity(0.05)],
                            ),
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: ConstantColors.primary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.access_time, size: 20, color: ConstantColors.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text('Driver Estimate Arrival Time'.tr,
                                    style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500)),
                              ),
                              Text(driverEstimateArrivalTime,
                                  style: TextStyle(fontSize: 16, color: ConstantColors.yellow, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      if (Constant.rideOtp.toString().toLowerCase() == 'yes'.toLowerCase() &&
                          rideData?.statut == 'confirmed' &&
                          rideData?.rideType != 'driver' &&
                          (rideData?.otp ?? "").toString().isNotEmpty)
                        Container(
                          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lock, size: 20, color: Colors.green[700]),
                              const SizedBox(width: 8),
                              Text('OTP: ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[600])),
                              Text(rideData?.otp.toString() ?? "", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[700], letterSpacing: 2)),
                            ],
                          ),
                        ),
                      if (rideData?.statut == 'confirmed' && ((rideData?.numberplate ?? "").toString().isNotEmpty))
                        Container(
                          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.yellow.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.confirmation_number_outlined, size: 20, color: Colors.deepOrange[700]),
                              const SizedBox(width: 8),
                              Text('Car Number: ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[600])),
                              Text(rideData?.numberplate.toString() ?? "",
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepOrange[700], letterSpacing: 1.5)),
                            ],
                          ),
                        ),
                      Padding(
                        padding: EdgeInsetsGeometry.only(bottom: 10, top: 8),
                        child: (rideData!.statut == "new") || (rideData!.driverPhone.toString().isEmpty)
                            ? _buildWaitingForDriver()
                            : _buildDriverInfo(),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                        child: Row(
                          children: [
                            if (rideData!.statut == "on ride")
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: buildModernButton(
                                    context: context,
                                    label: 'safe_message'.tr,
                                    icon: null,
                                    bgColor: Colors.orange[600]!,
                                    onPressed: () async {
                                      LocationData location = await Location().getLocation();
                                      Map<String, dynamic> bodyParams = {
                                        'lat': location.latitude,
                                        'lng': location.longitude,
                                        'user_id': Preferences.getInt(Preferences.userId).toString(),
                                        'user_name': "${controllerRideDetails.userModel!.data!.prenom} ${controllerRideDetails.userModel!.data!.nom}",
                                        'user_cat': controllerRideDetails.userModel!.data!.userCat,
                                        'id_driver': rideData!.idConducteur,
                                        'feel_safe': 0,
                                        'trip_id': rideData!.id,
                                      };
                                      controllerRideDetails.feelNotSafe(bodyParams).then((value) {
                                        if (value != null && value['success'] == "success") {
                                          ShowToastDialog.showToast("Report submitted".tr);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                            if (rideData!.isNew)
                              Expanded(
                                flex: 3,
                                child: buildModernButton(
                                  context: context,
                                  label: 'Cancel Ride'.tr,
                                  icon: null,
                                  bgColor: Colors.white,
                                  textColor: Colors.red[700]!,
                                  borderColor: Colors.red[200]!,
                                  onPressed: () => buildShowBottomSheet(context),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingForDriver() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.orange.withOpacity(0.1), Colors.orange.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 40, width: 40, child: l.Lottie.asset('assets/lottie/vehicleSearch.json', width: 40, height: 40)),
          const SizedBox(width: 12),
          Text("Waiting for Driver...".tr, style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.w600, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildDriverInfo() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.grey.withOpacity(0.05), Colors.grey.withOpacity(0.02)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ConstantColors.primary, width: 2),
              boxShadow: [BoxShadow(color: ConstantColors.primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: rideData!.photoPath.toString(),
                height: 60,
                width: 60,
                fit: BoxFit.cover,
                placeholder: (context, url) => Constant.loader(),
                errorWidget: (context, url, error) => const Icon(Icons.person_2_outlined),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${rideData!.prenomConducteur} ${rideData!.nomConducteur}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                StarRating(
                    size: 16, rating: rideData!.moyenne != "null" ? double.parse(rideData!.moyenne.toString()) : 0.0, color: ConstantColors.yellow),
                const SizedBox(height: 4),
                Text(rideData!.dateRetour.toString(), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              if (rideData!.statut == "confirmed")
                _buildActionIcon(
                  icon: Icons.chat_bubble_outline,
                  color: Colors.blue,
                  onTap: () {
                    Get.to(ConversationScreen(), arguments: {
                      'receiverId': int.parse(rideData!.idConducteur.toString()),
                      'orderId': int.parse(rideData!.id.toString()),
                      'receiverName': "${rideData!.prenomConducteur} ${rideData!.nomConducteur}",
                      'receiverPhoto': rideData!.photoPath
                    });
                  },
                ),
              if (rideData!.isShowContact)
                _buildActionIcon(
                  icon: Icons.share_rounded,
                  color: ConstantColors.blueColor,
                  onTap: () async {
                    ShowToastDialog.showLoader("Please wait".tr);
                    final Location currentLocation = Location();
                    LocationData location = await currentLocation.getLocation();
                    ShowToastDialog.closeLoader();
                    await Share.share('https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}',
                        subject: 'ZoCar');
                  },
                ),
              if (rideData!.isShowContact)
              _buildActionIcon(
                icon: Icons.call,
                color: Colors.green,
                onTap: () => Constant.makePhoneCall(rideData!.driverPhone.toString()),
              ),
              if (rideData!.statut == "on ride")
                Container(
                  decoration: BoxDecoration(
                    color: ConstantColors.primary,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: ConstantColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () async {
                        LocationData location = await Location().getLocation();
                        Map<String, dynamic> bodyParams = {'lat': location.latitude, 'lng': location.longitude, 'ride_id': rideData!.id};
                        controllerRideDetails.sos(bodyParams).then((value) {
                          if (value != null && value['success'] == "success") ShowToastDialog.showToast(value['message']);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Text('sos'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  buildShowBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(24), topLeft: Radius.circular(24))),
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      useSafeArea: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.cancel_outlined, color: Colors.red[700], size: 24),
                      ),
                      const SizedBox(width: 12),
                      Text("Cancel Trip".tr, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text("Write a reason for trip cancellation".tr, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  const SizedBox(height: 16),
                  TextField(
                    controller: resonController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Enter your reason here...".tr,
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: ConstantColors.primary, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: buildModernButton(
                          context: context,
                          label: 'Close'.tr,
                          icon: Icons.close,
                          bgColor: Colors.white,
                          textColor: Colors.grey[700]!,
                          borderColor: Colors.grey[300]!,
                          onPressed: () => Get.back(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: buildModernButton(
                          context: context,
                          label: 'Confirm'.tr,
                          icon: Icons.check,
                          bgColor: Colors.red[600]!,
                          onPressed: () async {
                            if (resonController.text.isNotEmpty) {
                              Get.back();
                              showDialog(
                                barrierColor: Colors.black26,
                                context: context,
                                builder: (context) => CustomAlertDialog(
                                  title: "Do you want to cancel this booking?".tr,
                                  onPressNegative: () => Get.back(),
                                  // negativeButtonText: 'No'.tr,
                                  // positiveButtonText: 'Yes'.tr,
                                  onPressPositive: () {
                                    Map<String, String> bodyParams = {
                                      'id_ride': rideData!.id.toString(),
                                      'id_user': rideData!.idConducteur.toString(),
                                      'name': "${rideData!.prenom} ${rideData!.nom}",
                                      'from_id': Preferences.getInt(Preferences.userId).toString(),
                                      'user_cat': controllerRideDetails.userModel!.data!.userCat.toString(),
                                      'reason': resonController.text.toString(),
                                    };
                                    controllerRideDetails.canceledRide(bodyParams).then((value) {
                                      Get.back();
                                      if (value != null) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) => CustomDialogBox(
                                            title: "Cancel Successfully",
                                            descriptions: "Ride Successfully cancel.",
                                            onPress: () {
                                              Get.back();
                                              controllerDashBoard.onSelectItem(drawerItems.indexWhere((element) => element.isAllRides));
                                            },
                                            img: Image.asset('assets/images/green_checked.png'),
                                          ),
                                        );
                                      }
                                    });
                                  },
                                ),
                              );
                            } else {
                              ShowToastDialog.showToast("Please enter a reason".tr);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        });
      },
    );
  }

}
