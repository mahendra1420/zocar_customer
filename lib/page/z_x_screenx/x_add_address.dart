// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart' as get_cord_address;
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
// import 'package:http/http.dart' as http;
// import '../../constant/show_toast_dialog.dart';
// import '../../controller/home_controller.dart';
// import '../../service/api.dart';
// import '../../themes/button_them.dart';
// import '../../themes/constant_colors.dart';
//
// class AddAddress extends StatefulWidget {
//   const AddAddress({super.key});
//
//   @override
//   State<AddAddress> createState() => _AddAddressState();
// }
//
// class _AddAddressState extends State<AddAddress> {
//   final controller = Get.put(HomeController());
//   Rx<Location> currentLocation = Location().obs;
//   Rx<LatLng> departureLatLong = const LatLng(0.0, 0.0).obs;
//   GoogleMapController? _controller;
//   Map<PolylineId, Polyline> polyLines = {};
//   var latitude = "";
//   var longitude = "";
//
//
//   getCurrentLocation(bool isDepartureSet) async {
//     controller.searchVisible.value = true;
//     devlog("MyHomeScreen ==> Yes I am here in getCurrentLocation");
//     if (isDepartureSet) {
//       devlog("MyHomeScreen ==> Yes I am here in isDepartureSet iF");
//       LocationData location = await currentLocation.value.getLocation();
//       List<get_cord_address.Placemark> placeMarks =
//           await get_cord_address.placemarkFromCoordinates(
//               location.latitude ?? 0.0, location.longitude ?? 0.0);
//
//       final address = (placeMarks.first.subLocality!.isEmpty
//               ? ''
//               : "${placeMarks.first.subLocality}, ") +
//           (placeMarks.first.street!.isEmpty
//               ? ''
//               : "${placeMarks.first.street}, ") +
//           (placeMarks.first.name!.isEmpty ? '' : "${placeMarks.first.name}, ") +
//           (placeMarks.first.subAdministrativeArea!.isEmpty
//               ? ''
//               : "${placeMarks.first.subAdministrativeArea}, ") +
//           (placeMarks.first.administrativeArea!.isEmpty
//               ? ''
//               : "${placeMarks.first.administrativeArea}, ") +
//           (placeMarks.first.country!.isEmpty
//               ? ''
//               : "${placeMarks.first.country}, ") +
//           (placeMarks.first.postalCode!.isEmpty
//               ? ''
//               : "${placeMarks.first.postalCode}, ");
//       controller.departureController.text = address;
//       setState(() {
//         setDepartureMarker(
//             LatLng(location.latitude ?? 0.0, location.longitude ?? 0.0));
//       });
//     } else {
//       devlog("MyHomeScreen ==> Yes I am here in isDepartureSet Else");
//     }
//   }
//
//   setDepartureMarker(LatLng departure) {
//     setState(() {
//       controller.markers.remove("Departure");
//       controller.markers['Departure'] = Marker(
//         markerId: const MarkerId('Departure'),
//         infoWindow: const InfoWindow(title: "Departure"),
//         position: departure,
//         icon: controller.departureIcon!,
//       );
//       departureLatLong.value = departure;
//       latitude = departure.latitude.toString();
//       longitude = departure.longitude.toString();
//       _controller!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
//           target: LatLng(departure.latitude, departure.longitude), zoom: 14)));
//       if (departureLatLong != LatLng(0, 0)) {
//         controller.saveAddress.value = true;
//         // conformationBottomSheet(context);
//       }
//     });
//   }
//   String selectedID = "";
//   @override
//   Widget build(BuildContext context) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (controller.imageListHeader.isNotEmpty) {}
//     });
//     return WillPopScope(
//       onWillPop: () async {
//         controller.confirmWidgetVisible.value = false;
//         return true;
//       },
//       child: Scaffold(
//         backgroundColor: ConstantColors.background,
//         appBar: AppBar(
//           elevation: 0,
//           backgroundColor: ConstantColors.primary,
//           title: Text(
//             "Save Favorite Address",
//             style: TextStyle(
//                 color: ConstantColors.background,
//                 fontSize: 16.0,
//                 fontWeight: FontWeight.w400),
//           ),
//           leading: Padding(
//             padding: const EdgeInsets.only(top: 3),
//             child: ElevatedButton(
//               onPressed: () {
//                 controller.confirmWidgetVisible.value = false;
//                 Get.back();
//               },
//               style: ElevatedButton.styleFrom(
//                 shape: const CircleBorder(),
//                 backgroundColor: ConstantColors.primary,
//                 padding: const EdgeInsets.all(10),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(4.0),
//                 child: Icon(
//                   Icons.arrow_back_ios_rounded,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//           actions: [
//             IconButton(
//               onPressed: () {
//                 getCurrentLocation(true);
//               },
//               autofocus: false,
//               icon: const Icon(
//                 Icons.my_location_outlined,
//                 color: Colors.white,
//                 size: 18,
//               ),
//             ),
//           ],
//         ),
//         body: Column(
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Visibility(
//                   visible: controller.searchVisible.value,
//                   child: Padding(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
//                     child: Container(
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(0),
//                           color: Colors.white),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 8.0, horizontal: 10),
//                         child: Column(
//                           children: [
//                             Builder(builder: (context) {
//                               return Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 00),
//                                 child: Row(
//                                   children: [
//                                     Expanded(
//                                       child: InkWell(
//                                         onTap: () async {
//                                           await controller
//                                               .placeSelectAPI(context)
//                                               .then((value) {
//                                             if (value != null) {
//                                               controller.departureController
//                                                       .text =
//                                                   value.result.formattedAddress
//                                                       .toString();
//                                               setDepartureMarker(LatLng(
//                                                   value.result.geometry!
//                                                       .location.lat,
//                                                   value.result.geometry!
//                                                       .location.lng));
//                                             }
//                                           });
//                                         },
//                                         child: buildTextField(
//                                             title: "Departure".tr,
//                                             textController:
//                                                 controller.departureController,
//                                             icon:
//                                                 "assets/images/departure_icon.png",
//                                             color: Colors.deepOrange),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             }),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Expanded(
//               child: Stack(
//                 children: [
//                   GoogleMap(
//                     zoomControlsEnabled: false,
//                     myLocationButtonEnabled: false,
//                     padding: const EdgeInsets.only(
//                       top: 8.0,
//                     ),
//                     compassEnabled: false,
//                     initialCameraPosition: CameraPosition(
//                       target: controller.center,
//                       zoom: 14.0,
//                     ),
//                     minMaxZoomPreference: const MinMaxZoomPreference(8.0, 20.0),
//                     buildingsEnabled: false,
//                     onMapCreated:
//                         (GoogleMapController mapcontrollerdata) async {
//                       _controller = mapcontrollerdata;
//                       LocationData location =
//                           await currentLocation.value.getLocation();
//                       _controller!.moveCamera(CameraUpdate.newLatLngZoom(
//                           LatLng(location.latitude ?? 0.0,
//                               location.longitude ?? 0.0),
//                           14));
//                     },
//                     polylines: Set<Polyline>.of(polyLines.values),
//                     myLocationEnabled: true,
//                     markers: controller.markers.values.toSet(),
//                   ),
//                 ],
//               ),
//             ),
//             Visibility(
//               visible: controller.saveAddress.value,
//               child: Align(
//                 alignment: Alignment.bottomCenter,
//                 child: confirmWidget(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget buildTextField(
//       {required title,
//       required TextEditingController textController,
//       required String icon,
//       required MaterialColor color}) {
//     return Padding(
//       padding:
//           const EdgeInsets.only(left: 8.0, right: 8.0, top: 2.0, bottom: 2.0),
//       child: TextField(
//         controller: textController,
//         textInputAction: TextInputAction.done,
//         style: TextStyle(color: ConstantColors.titleTextColor),
//         decoration: InputDecoration(
//           hintText: title,
//           // Add a prefix icon (location icon in this case)
//           prefixIcon: Padding(
//             padding: EdgeInsets.all(12.0), // Add padding if needed
//             child: Image.asset(
//               icon,
//               height: 23,
//               width: 23,
//             ),
//           ),
//           // Custom border when the field is not focused
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8), // Set corner radius
//             borderSide: const BorderSide(
//               color: Colors.grey, // Gray border color
//               width: 1.0, // Border width
//             ),
//           ),
//           // Custom border when the field is focused
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             // Same corner radius for focus
//             borderSide: const BorderSide(
//               color: Colors.grey, // Gray border color when focused
//               width: 1.0,
//             ),
//           ),
//           // Custom border when the field is disabled
//           disabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             // Same corner radius for disabled state
//             borderSide: const BorderSide(
//               color: Colors.grey, // Gray border color for disabled state
//               width: 1.0,
//             ),
//           ),
//           // Set the hint text styling
//           hintStyle: const TextStyle(color: Colors.grey),
//         ),
//         enabled: false, // Disable the field
//       ),
//     );
//   }
//
//   confirmWidget() {
//     controller.searchVisible.value = true;
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
//       // vertical: 65.0),
//       child: Row(
//         children: [
//           Expanded(
//             child: ButtonThem.buildButton(context,
//                 btnHeight: 40,
//                 title: "Confirm Address".tr,
//                 btnColor: ConstantColors.primary,
//                 txtColor: Colors.white, onPress: () {
//               showBottomSheet(context);
//             }),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void showBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
//       ),
//       builder: (context) {
//         String selected = ""; // Keep this inside StatefulBuilder for updates
//          // Keep this inside StatefulBuilder for updates
//         return Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Save as favourite",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 controller.departureController.text != ""
//                     ? controller.departureController.text.toString()
//                     : "Add Address or get current location.",
//                 style: TextStyle(color: Colors.grey),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 "Save location as",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   _locationButton(Icons.home, "home", selected, setState),
//                   const SizedBox(width: 8),
//                   _locationButton(Icons.work, "work", selected, setState),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text("Cancel"),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         devlog("MyRequestLog controller  ==> ${controller.departureController.text.toString()}");
//                         devlog("MyRequestLog longitude  ==> ${longitude}");
//                         devlog("MyRequestLog latitude  ==> ${latitude}");
//                         devlog("MyRequestLog selectedID  ==> ${selectedID}");
//                         SaveAddress();
//                         Navigator.pop(context);
//                       },
//                       child: const Text("Save"),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _locationButton(
//       IconData icon, String label, String selected, Function setState) {
//     return Expanded(
//       child: OutlinedButton.icon(
//         style: OutlinedButton.styleFrom(
//           backgroundColor: selectedID == label ? Colors.blue : Colors.white,
//           foregroundColor: selectedID == label ? Colors.white : Colors.black,
//           side:
//               BorderSide(color: selectedID == label ? Colors.blue : Colors.grey),
//         ),
//         onPressed: () {
//           setState(() {
//             selected = label;
//             selectedID = label;
//           });
//         },
//         icon: Icon(icon),
//         label: Text(label),
//       ),
//     );
//   }
//
//   Future<dynamic> SaveAddress() async {
//     try {
//       Map<String, String> bodyParams = {};
//       bodyParams = {
//         'longitude': longitude,
//         'latitude': latitude,
//         'address': controller.departureController.text.toString(),
//         'address_type': selectedID,
//       };
//       devlog("MyRequestLog Response ==> ${bodyParams.toString()}");
//       final response = await LoggingClient(http.Client()).post(Uri.parse(API.saveAddressDetails) , body: bodyParams ,  headers: API.headerSecond);
//       devlog("MyRequestLog Response ==> ${response.body.toString()}");
//       Map<String, dynamic> responseBody = json.safeDecode(response.body);
//       if (response.statusCode == 200 && responseBody['success'] == "success") {
//         devlog("MyRequestLog success ==> ${responseBody["success"]}");
//         devlog("MyRequestLog message ==> ${responseBody["message"]}");
//         Get.back();
//       } else if (response.statusCode == 200 && responseBody['success'] == "Failed") {
//         ShowToastDialog.showToast('Something went wrong. Please try again later');
//       } else {
//         ShowToastDialog.showToast('Something went wrong. Please try again later');
//         throw Exception('Something went wrong.!');
//       }
//     } on TimeoutException catch (e) {
//       devlog("MyRequestLog TimeoutException ==> ${e.message.toString()}");
//       ShowToastDialog.showToast(e.message.toString());
//     } on SocketException catch (e) {
//       devlog("MyRequestLog SocketException ==> ${e.message.toString()}");
//       ShowToastDialog.showToast(e.message.toString());
//     } on Error catch (e) {
//       devlog("MyRequestLog Error ==> ${e.toString()}");
//       ShowToastDialog.showToast(e.toString());
//     } catch (e) {
//       devlog("MyRequestLog catch ==> ${e.toString()}");
//       ShowToastDialog.closeLoader();
//       ShowToastDialog.showToast(e.toString());
//     }
//     return null;
//   }
//
// }
