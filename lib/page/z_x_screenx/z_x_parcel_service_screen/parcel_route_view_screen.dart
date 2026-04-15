// import 'package:zocar/constant/constant.dart';
// import 'package:zocar/constant/show_toast_dialog.dart';
// import 'package:zocar/controller/main_page_controller.dart';
// import 'package:zocar/controller/parcel_details_controller.dart';
// import 'package:zocar/model/driver_location_update.dart';
// import 'package:zocar/model/parcel_model.dart';
// import 'package:zocar/themes/button_them.dart';
// import 'package:zocar/themes/constant_colors.dart';
// import 'package:zocar/themes/custom_alert_dialog.dart';
// import 'package:zocar/themes/custom_dialog_box.dart';
// import 'package:zocar/utils/Preferences.dart';
// import 'package:zocar/widget/StarRating.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
// import 'package:share_plus/share_plus.dart';
//
// class ParcelRouteViewScreen extends StatefulWidget {
//   const ParcelRouteViewScreen({super.key});
//
//   @override
//   State<ParcelRouteViewScreen> createState() => _ParcelRouteViewScreenState();
// }
//
// class _ParcelRouteViewScreenState extends State<ParcelRouteViewScreen> {
//   dynamic argumentData = Get.arguments;
//
//   GoogleMapController? _controller;
//
//   Map<PolylineId, Polyline> polyLines = {};
//
//   PolylinePoints polylinePoints = PolylinePoints();
//
//   BitmapDescriptor? departureIcon;
//   BitmapDescriptor? destinationIcon;
//   BitmapDescriptor? taxiIcon;
//   BitmapDescriptor? stopIcon;
//
//   late LatLng departureLatLong;
//   late LatLng destinationLatLong;
//
//   final Map<String, Marker> _markers = {};
//
//   String? type;
//   ParcelData? parcelData;
//   String driverEstimateArrivalTime = '';
//
//   @override
//   void initState() {
//     getArgumentData();
//     setIcons();
//
//     super.initState();
//   }
//
//   final controllerRideDetails = Get.put(ParcelDetailsController());
//   final controllerDashBoard = Get.put(MainPageController());
//
//   getArgumentData() {
//     if (argumentData != null) {
//       type = argumentData['type'];
//       parcelData = argumentData['data'];
//
//       departureLatLong = LatLng(double.parse(parcelData!.latSource.toString()), double.parse(parcelData!.lngSource.toString()));
//       destinationLatLong = LatLng(double.parse(parcelData!.latDestination.toString()), double.parse(parcelData!.lngDestination.toString()));
//
//       if (parcelData!.status == "onride" || parcelData!.status == 'confirmed') {
//         Constant.driverLocationUpdateCollection.doc(parcelData!.idConducteur).snapshots().listen((event) async {
//           DriverLocationUpdate driverLocationUpdate = DriverLocationUpdate.fromJson(event.data() as Map<String, dynamic>);
//
//           Dio dio = Dio();
//           dynamic response = await dio.get(
//               "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=${parcelData!.latSource},${parcelData!.lngSource}&destinations=${double.parse(driverLocationUpdate.driverLatitude.toString())},${double.parse(driverLocationUpdate.driverLongitude.toString())}&key=${Constant.kGoogleApiKey}");
//
//           driverEstimateArrivalTime = response.data['rows'][0]['elements'][0]['duration']['text'].toString();
//
//           setState(() {
//             departureLatLong = LatLng(double.parse(driverLocationUpdate.driverLatitude.toString()), double.parse(driverLocationUpdate.driverLongitude.toString()));
//             _markers[parcelData!.id.toString()] = Marker(
//                 markerId: MarkerId(parcelData!.id.toString()),
//                 infoWindow: InfoWindow(title: parcelData!.prenomConducteur.toString()),
//                 position: departureLatLong,
//                 icon: taxiIcon!,
//                 rotation: double.parse(driverLocationUpdate.rotation.toString()));
//             getDirections(dLat: double.parse(driverLocationUpdate.driverLatitude.toString()), dLng: double.parse(driverLocationUpdate.driverLongitude.toString()));
//           });
//         });
//       } else {
//         getDirections(dLat: 0.0, dLng: 0.0);
//       }
//     }
//   }
//
//   setIcons() async {
//     BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(10, 10)), "assets/icons/pickup.png").then((value) {
//       departureIcon = value;
//     });
//
//     BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(10, 10)), "assets/icons/dropoff.png").then((value) {
//       destinationIcon = value;
//     });
//
//     BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(10, 10)), "assets/icons/ic_taxi.png").then((value) {
//       taxiIcon = value;
//     });
//
//     BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(10, 10)), "assets/icons/location.png").then((value) {
//       stopIcon = value;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Stack(
//           alignment: Alignment.bottomCenter,
//           children: [
//             GoogleMap(
//               zoomControlsEnabled: true,
//               myLocationButtonEnabled: false,
//               myLocationEnabled: false,
//               initialCameraPosition: const CameraPosition(
//                 target: LatLng(48.8561, 2.2930),
//                 zoom: 14.0,
//               ),
//               onMapCreated: (GoogleMapController controller) {
//                 _controller = controller;
//                 _controller!.moveCamera(CameraUpdate.newLatLngZoom(departureLatLong, 12));
//               },
//               polylines: Set<Polyline>.of(polyLines.values),
//               markers: _markers.values.toSet(),
//             ),
//             Positioned(
//               top: 10,
//               left: 5,
//               child: Padding(
//                 padding: const EdgeInsets.only(top: 3),
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Get.back();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     shape: const CircleBorder(),
//                     backgroundColor: Colors.white,
//                     padding: const EdgeInsets.all(4),
//                   ),
//                   child: const Padding(
//                     padding: EdgeInsets.all(4.0),
//                     child: Icon(Icons.arrow_back_ios_outlined, color: Colors.black),
//                   ),
//                 ),
//               ),
//             ),
//             Column(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 if (parcelData!.status.toString() != "new" || parcelData!.status.toString() != "canceled" && parcelData!.idConducteur.toString() != "null")
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 15.0,
//                       vertical: 10,
//                     ),
//                     child: Container(
//                       decoration: const BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.all(Radius.circular(15.0)),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
//                         child: Column(
//                           children: [
//                             Visibility(
//                               visible: Constant.rideOtp.toString().toLowerCase() == 'yes'.toLowerCase() && parcelData!.status == 'confirmed' ? true : false,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Divider(
//                                     color: Colors.grey.withOpacity(0.20),
//                                     thickness: 1,
//                                   ),
//                                   Text(
//                                     'OTP : ${parcelData!.otp}',
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w800,
//                                       color: Colors.black54,
//                                     ),
//                                   ),
//                                   Divider(
//                                     color: Colors.grey.withOpacity(0.20),
//                                     thickness: 1,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             if ((parcelData!.status.toString() != "new" || parcelData!.status.toString() != "canceled") && parcelData!.idConducteur.toString() != "null")
//                               Row(
//                                 children: [
//                                   ClipRRect(
//                                     borderRadius: BorderRadius.circular(10),
//                                     child: CachedNetworkImage(
//                                       imageUrl: parcelData!.driverPhoto.toString(),
//                                       height: 80,
//                                       width: 80,
//                                       fit: BoxFit.cover,
//                                       placeholder: (context, url) => Constant.loader(),
//                                       errorWidget: (context, url, error) => const Icon(Icons.error),
//                                     ),
//                                   ),
//                                   Expanded(
//                                     child: Padding(
//                                       padding: const EdgeInsets.only(left: 8.0),
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           Text("${parcelData!.driverName}",
//                                               overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
//                                           StarRating(
//                                               size: 18, rating: parcelData!.moyenne != "null" ? double.parse(parcelData!.moyenne.toString()) : 0.0, color: ConstantColors.yellow),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                   Column(
//                                     crossAxisAlignment: CrossAxisAlignment.end,
//                                     children: [
//                                       Row(
//                                         children: [
//                                           parcelData!.status != "completed"
//                                               ? Padding(
//                                                   padding: const EdgeInsets.only(left: 10),
//                                                   child: InkWell(
//                                                       onTap: () async {
//                                                         ShowToastDialog.showLoader("Please wait".tr);
//                                                         final Location currentLocation = Location();
//                                                         LocationData location = await currentLocation.getLocation();
//
//                                                         await Share.share(
//                                                             subject: 'ZoCar', '\n' 'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}');
//
//                                                         /* await FlutterShareMe()
//                                                             .shareToWhatsApp(
//                                                                 msg:*/
//                                                       },
//                                                       child: Container(
//                                                           height: 36,
//                                                           width: 36,
//                                                           decoration: BoxDecoration(
//                                                             shape: BoxShape.circle,
//                                                             color: ConstantColors.blueColor,
//                                                           ),
//                                                           child: const Icon(
//                                                             Icons.share_rounded,
//                                                             size: 26,
//                                                             color: Colors.white,
//                                                           ))),
//                                                 )
//                                               : const Offstage(),
//                                           Padding(
//                                             padding: const EdgeInsets.only(left: 10),
//                                             child: InkWell(
//                                                 onTap: () {
//                                                   Constant.makePhoneCall(parcelData!.driverPhone.toString());
//                                                 },
//                                                 child: Image.asset(
//                                                   'assets/icons/call_icon.png',
//                                                   height: 36,
//                                                   width: 36,
//                                                 )),
//                                           ),
//                                         ],
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.only(top: 5.0),
//                                         child: Text(parcelData!.parcelDate.toString(), style: const TextStyle(color: Colors.black26, fontWeight: FontWeight.w600)),
//                                       ),
//                                     ],
//                                   )
//                                 ],
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   child: Visibility(
//                     visible: parcelData!.status == "rejected" || parcelData!.status == "canceled" || parcelData!.status == "onride" ? false : true,
//                     child: Padding(
//                       padding: const EdgeInsets.only(bottom: 5, left: 10),
//                       child: ButtonThem.buildBorderButton(
//                         context,
//                         title: 'Cancel Ride'.tr,
//                         btnHeight: 45,
//                         btnWidthRatio: 0.9,
//                         btnColor: Colors.white,
//                         txtColor: ConstantColors.primary,
//                         btnBorderColor: ConstantColors.primary,
//                         onPress: () async {
//                           buildShowBottomSheet(
//                             context,
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   final resonController = TextEditingController();
//
//   buildShowBottomSheet(
//     BuildContext context,
//   ) {
//     return showModalBottomSheet(
//         shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15))),
//         context: context,
//         isDismissible: true,
//         isScrollControlled: true,
//         builder: (context) {
//           return StatefulBuilder(builder: (context, setState) {
//             return Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
//               child: Padding(
//                 padding: MediaQuery.of(context).viewInsets,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 10),
//                       child: Text(
//                         "Cancel Trip".tr,
//                         style: const TextStyle(fontSize: 18, color: Colors.black),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(top: 10),
//                       child: Text(
//                         "Write a reason for trip cancellation".tr,
//                         style: TextStyle(color: Colors.black.withOpacity(0.50)),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(top: 8),
//                       child: TextField(
//                         controller: resonController,
//                         keyboardType: TextInputType.text,
//                         textInputAction: TextInputAction.done,
//                         decoration: const InputDecoration(
//                           focusedBorder: OutlineInputBorder(
//                             borderSide: BorderSide(color: Colors.grey, width: 1.0),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderSide: BorderSide(color: Colors.grey, width: 1.0),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(top: 20),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Padding(
//                               padding: const EdgeInsets.only(bottom: 5),
//                               child: ButtonThem.buildButton(
//                                 context,
//                                 title: 'Cancel Trip'.tr,
//                                 btnHeight: 45,
//                                 btnWidthRatio: 0.8,
//                                 btnColor: ConstantColors.primary,
//                                 txtColor: Colors.white,
//                                 onPress: () async {
//                                   if (resonController.text.isNotEmpty) {
//                                     Get.back();
//                                     showDialog(
//                                       barrierColor: Colors.black26,
//                                       context: context,
//                                       builder: (context) {
//                                         return CustomAlertDialog(
//                                           title: "Do you want to cancel this booking?".tr,
//                                           onPressNegative: () {
//                                             Get.back();
//                                           },
//                                           onPressPositive: () {
//                                             if (parcelData!.status.toString() == "new") {
//                                               Map<String, String> bodyParams = {
//                                                 'parcel_id': parcelData!.id.toString(),
//                                                 'reason': resonController.text.toString(),
//                                               };
//                                               controllerRideDetails.rejectParcel(bodyParams).then((value) {
//                                                 Get.back();
//                                                 if (value != null) {
//                                                   showDialog(
//                                                       context: context,
//                                                       builder: (BuildContext context) {
//                                                         return CustomDialogBox(
//                                                           title: "Cancel Successfully",
//                                                           descriptions: "Parcel Successfully cancel.",
//                                                           onPress: () {
//                                                             Get.back();
//                                                             controllerDashBoard.onSelectItem(6);
//                                                           },
//                                                           img: Image.asset('assets/images/green_checked.png'),
//                                                         );
//                                                       });
//                                                 }
//                                               });
//                                             } else {
//                                               Map<String, String> bodyParams = {
//                                                 'id_parcel': parcelData!.id.toString(),
//                                                 'id_user': parcelData!.idConducteur.toString(),
//                                                 'name': "${parcelData!.senderName}",
//                                                 'from_id': Preferences.getInt(Preferences.userId).toString(),
//                                                 'user_cat': controllerRideDetails.userModel!.data!.userCat.toString(),
//                                                 'reason': resonController.text.toString(),
//                                               };
//                                               controllerRideDetails.canceledParcel(bodyParams).then((value) {
//                                                 Get.back();
//                                                 if (value != null) {
//                                                   showDialog(
//                                                       context: context,
//                                                       builder: (BuildContext context) {
//                                                         return CustomDialogBox(
//                                                           title: "Cancel Successfully",
//                                                           descriptions: "Parcel Successfully cancel.",
//                                                           onPress: () {
//                                                             Get.back();
//                                                             controllerDashBoard.onSelectItem(6);
//                                                           },
//                                                           img: Image.asset('assets/images/green_checked.png'),
//                                                         );
//                                                       });
//                                                 }
//                                               });
//                                             }
//                                           },
//                                         );
//                                       },
//                                     );
//                                   } else {
//                                     ShowToastDialog.showToast("Please enter a reason".tr);
//                                   }
//                                 },
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                             child: Padding(
//                               padding: const EdgeInsets.only(bottom: 5, left: 10),
//                               child: ButtonThem.buildBorderButton(
//                                 context,
//                                 title: 'Close'.tr,
//                                 btnHeight: 45,
//                                 btnWidthRatio: 0.8,
//                                 btnColor: Colors.white,
//                                 txtColor: ConstantColors.primary,
//                                 btnBorderColor: ConstantColors.primary,
//                                 onPress: () async {
//                                   Get.back();
//                                 },
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             );
//           });
//         });
//   }
//
//   getDirections({required double dLat, required double dLng}) async {
//     List<LatLng> polylineCoordinates = [];
//     PolylineResult result;
//
//     if (parcelData!.status == "confirmed") {
//       result = await polylinePoints.getRouteBetweenCoordinates(
//         googleApiKey: Constant.kGoogleApiKey.toString(),
//         request: PolylineRequest(
//           origin: PointLatLng(double.parse(parcelData!.latSource.toString()), double.parse(parcelData!.lngSource.toString())),
//           destination: PointLatLng(dLat, dLng),
//           mode: TravelMode.driving,
//           optimizeWaypoints: true,
//         ),
//       );
//     } else if (parcelData!.status == "on ride") {
//       result = await polylinePoints.getRouteBetweenCoordinates(
//         googleApiKey: Constant.kGoogleApiKey.toString(),
//         request: PolylineRequest(
//           origin: PointLatLng(dLat, dLng),
//           destination: PointLatLng(destinationLatLong.latitude, destinationLatLong.longitude),
//           mode: TravelMode.driving,
//           optimizeWaypoints: true,
//         ),
//       );
//     } else {
//       result = await polylinePoints.getRouteBetweenCoordinates(
//         googleApiKey: Constant.kGoogleApiKey.toString(),
//         request: PolylineRequest(
//           origin: PointLatLng(departureLatLong.latitude, departureLatLong.longitude),
//           destination: PointLatLng(destinationLatLong.latitude, destinationLatLong.longitude),
//           mode: TravelMode.driving,
//           optimizeWaypoints: true,
//         ),
//       );
//     }
//
//     _markers['Departure'] = Marker(
//       markerId: const MarkerId('Departure'),
//       infoWindow: const InfoWindow(title: "Departure"),
//       position: LatLng(double.parse(parcelData!.latSource.toString()), double.parse(parcelData!.lngSource.toString())),
//       icon: departureIcon!,
//     );
//
//     _markers['Destination'] = Marker(
//       markerId: const MarkerId('Destination'),
//       infoWindow: const InfoWindow(title: "Destination"),
//       position: destinationLatLong,
//       icon: destinationIcon!,
//     );
//
//     if (result.points.isNotEmpty) {
//       for (var point in result.points) {
//         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//       }
//     }
//
//     addPolyLine(polylineCoordinates);
//   }
//
//   addPolyLine(List<LatLng> polylineCoordinates) {
//     PolylineId id = const PolylineId("poly");
//     Polyline polyline = Polyline(
//       polylineId: id,
//       color: ConstantColors.primary,
//       points: polylineCoordinates,
//       width: 4,
//       geodesic: true,
//     );
//     polyLines[id] = polyline;
//     updateCameraLocation(polylineCoordinates.first, polylineCoordinates.last, _controller);
//
//     setState(() {});
//   }
//
//   Future<void> updateCameraLocation(
//     LatLng source,
//     LatLng destination,
//     GoogleMapController? mapController,
//   ) async {
//     if (mapController == null) return;
//
//     LatLngBounds bounds;
//
//     if (source.latitude > destination.latitude && source.longitude > destination.longitude) {
//       bounds = LatLngBounds(southwest: destination, northeast: source);
//     } else if (source.longitude > destination.longitude) {
//       bounds = LatLngBounds(southwest: LatLng(source.latitude, destination.longitude), northeast: LatLng(destination.latitude, source.longitude));
//     } else if (source.latitude > destination.latitude) {
//       bounds = LatLngBounds(southwest: LatLng(destination.latitude, source.longitude), northeast: LatLng(source.latitude, destination.longitude));
//     } else {
//       bounds = LatLngBounds(southwest: source, northeast: destination);
//     }
//
//     CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 10);
//
//     return checkCameraLocation(cameraUpdate, mapController);
//   }
//
//   Future<void> checkCameraLocation(CameraUpdate cameraUpdate, GoogleMapController mapController) async {
//     mapController.animateCamera(cameraUpdate);
//     LatLngBounds l1 = await mapController.getVisibleRegion();
//     LatLngBounds l2 = await mapController.getVisibleRegion();
//
//     if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
//       return checkCameraLocation(cameraUpdate, mapController);
//     }
//   }
// }
