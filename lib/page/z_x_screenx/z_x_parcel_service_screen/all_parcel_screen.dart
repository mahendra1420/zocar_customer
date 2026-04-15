// import 'package:zocar/constant/constant.dart';
// import 'package:zocar/controller/parcel_service_controller.dart';
// import 'package:zocar/model/parcel_model.dart';
// import 'package:zocar/page/complaint/add_complaint_screen.dart';
// import 'package:zocar/page/parcel_service_screen/parcel_details_screen.dart';
// import 'package:zocar/page/parcel_service_screen/parcel_route_view_screen.dart';
// import 'package:zocar/page/review_screens/add_review_screen.dart';
// import 'package:zocar/themes/button_them.dart';
// import 'package:zocar/widget/StarRating.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:location/location.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:text_scroll/text_scroll.dart';
//
// import '../../constant/show_toast_dialog.dart';
// import '../../themes/constant_colors.dart';
//
// class AllParcelScreen extends StatelessWidget {
//   const AllParcelScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetX<ParcelServiceController>(
//         init: ParcelServiceController(),
//         builder: (controller) {
//           print("AllParcelScreen ==> ${controller.parcelList}");
//           return Scaffold(
//             backgroundColor: ConstantColors.background,
//             body: RefreshIndicator(
//               onRefresh: () => controller.getParcel(),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 child: controller.isLoading.value
//                     ? Center(child: Constant.loader())
//                     : controller.parcelList.isEmpty
//                         ? Constant.emptyView(context,
//                             "You have not booked any parcel.".tr, false)
//                         : ListView.builder(
//                             physics: const BouncingScrollPhysics(),
//                             itemCount: controller.parcelList.length,
//                             shrinkWrap: true,
//                             itemBuilder: (context, index) {
//                               return buildHistory(context, controller,
//                                   controller.parcelList[index]);
//                             },
//                           ),
//               ),
//             ),
//           );
//         });
//   }
//
//   buildHistory(context, ParcelServiceController controller, ParcelData data) {
//     return GestureDetector(
//       onTap: () async {
//         if (data.status == "completed") {
//           var isDone = await Get.to(const ParcelDetailsScreen(), arguments: {
//             "parcelData": data,
//           });
//           if (isDone != null) {}
//         } else {
//           var argumentData = {'type': data.status.toString(), 'data': data};
//           if (Constant.mapType == "inappmap") {
//             Get.to(const ParcelRouteViewScreen(), arguments: argumentData);
//           } else {
//             Constant.redirectMap(
//               latitude: double.parse(data
//                   .latDestination!), //orderModel.destinationLocationLAtLng!.latitude!,
//               longLatitude: double.parse(data
//                   .lngDestination!), //orderModel.destinationLocationLAtLng!.longitude!,
//               name: data.destination!.toString(),
//             ); //orderModel.destinationLocationName.toString());
//           }
//         }
//       },
//       child: Stack(
//         children: [
//           Card(
//             elevation: 2,
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 15.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       buildLine(),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             buildUsersDetails(
//                               context,
//                               data,
//                               isSender: true,
//                             ),
//                             const SizedBox(
//                               height: 10,
//                             ),
//                             buildUsersDetails(
//                               context,
//                               data,
//                               isSender: false,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   Visibility(
//                     visible: data.status.toString() == "confirmed" &&
//                         Constant.rideOtp.toString().toLowerCase() ==
//                             'yes'.toLowerCase(),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 15, vertical: 10),
//                       child: Text("OTP : ${data.otp.toString()}"),
//                     ),
//                   ),
//                   Visibility(
//                     visible: data.status.toString() != "confirmed" ||
//                         Constant.rideOtp.toString().toLowerCase() ==
//                             'no'.toLowerCase(),
//                     child: const SizedBox(
//                       height: 10,
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                     ),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: Container(
//                             height: 80,
//                             padding: const EdgeInsets.symmetric(horizontal: 8),
//                             margin: const EdgeInsets.only(right: 8),
//                             decoration: BoxDecoration(
//                                 border: Border.all(
//                                   color: Colors.black12,
//                                 ),
//                                 borderRadius: const BorderRadius.all(
//                                     Radius.circular(10))),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   Constant.currency.toString(),
//                                   style: TextStyle(
//                                     color: ConstantColors.yellow,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 20,
//                                   ),
//                                 ),
//                                 TextScroll(
//                                   Constant().amountShow(
//                                       amount: data.amount.toString()),
//                                   mode: TextScrollMode.bouncing,
//                                   pauseBetween: const Duration(seconds: 2),
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.w800,
//                                     color: Colors.black54,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           child: Container(
//                             margin: const EdgeInsets.only(right: 8),
//                             padding: const EdgeInsets.symmetric(horizontal: 8),
//                             height: 80,
//                             decoration: BoxDecoration(
//                                 border: Border.all(
//                                   color: Colors.black12,
//                                 ),
//                                 borderRadius: const BorderRadius.all(
//                                     Radius.circular(10))),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Image.asset(
//                                   'assets/icons/ic_distance.png',
//                                   height: 22,
//                                   width: 22,
//                                   color: ConstantColors.yellow,
//                                 ),
//                                 const SizedBox(
//                                   height: 5,
//                                 ),
//                                 TextScroll(
//                                   "${double.parse(data.distance.toString()).toStringAsFixed(int.parse(Constant.decimal!))} ${data.distanceUnit}",
//                                   mode: TextScrollMode.bouncing,
//                                   pauseBetween: const Duration(seconds: 2),
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.w800,
//                                     color: Colors.black54,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 8),
//                             alignment: Alignment.center,
//                             height: 80,
//                             decoration: BoxDecoration(
//                                 border: Border.all(
//                                   color: Colors.black12,
//                                 ),
//                                 borderRadius: const BorderRadius.all(
//                                     Radius.circular(10))),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Image.asset(
//                                   'assets/icons/time.png',
//                                   height: 22,
//                                   width: 22,
//                                   color: ConstantColors.yellow,
//                                 ),
//                                 const SizedBox(
//                                   height: 5,
//                                 ),
//                                 TextScroll(data.duration.toString(),
//                                     mode: TextScrollMode.bouncing,
//                                     pauseBetween: const Duration(seconds: 2),
//                                     style: const TextStyle(
//                                         fontWeight: FontWeight.w800,
//                                         color: Colors.black54)),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   if ((data.status.toString() != "new" ||
//                           data.status.toString() != "canceled") &&
//                       data.idConducteur.toString() != "null")
//                     const SizedBox(
//                       height: 10,
//                     ),
//                   if ((data.status.toString() != "new" ||
//                           data.status.toString() != "canceled") &&
//                       data.idConducteur.toString() != "null")
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 15),
//                       child: Row(
//                         children: [
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(10),
//                             child: CachedNetworkImage(
//                               imageUrl: data.driverPhoto.toString(),
//                               height: 80,
//                               width: 80,
//                               fit: BoxFit.cover,
//                               placeholder: (context, url) => Constant.loader(),
//                               errorWidget: (context, url, error) =>
//                                   const Icon(Icons.error),
//                             ),
//                           ),
//                           Expanded(
//                             child: Padding(
//                               padding: const EdgeInsets.only(left: 8.0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text("${data.driverName}",
//                                       style: const TextStyle(
//                                           color: Colors.black87,
//                                           fontWeight: FontWeight.w600)),
//                                   StarRating(
//                                       size: 18,
//                                       rating: data.moyenne != "null"
//                                           ? double.parse(
//                                               data.moyenne.toString())
//                                           : 0.0,
//                                       color: ConstantColors.yellow),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Row(
//                                 children: [
//                                   Row(
//                                     children: [
//                                       data.status != "completed"
//                                           ? Padding(
//                                               padding: const EdgeInsets.only(
//                                                   left: 10),
//                                               child: InkWell(
//                                                   onTap: () async {
//                                                     ShowToastDialog.showLoader(
//                                                         "Please wait");
//                                                     final Location
//                                                         currentLocation =
//                                                         Location();
//                                                     LocationData location =
//                                                         await currentLocation
//                                                             .getLocation();
//                                                     ShowToastDialog
//                                                         .closeLoader();
//
//                                                     await  Share.share(
//                                                       subject: 'ZoCar','\n''https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}');
//
//                                                    /* await FlutterShareMe()
//                                                         .shareToWhatsApp(
//                                                             msg:
//                                                                 'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}');*/
//                                                   },
//                                                   child: Container(
//                                                       height: 36,
//                                                       width: 36,
//                                                       decoration: BoxDecoration(
//                                                         shape: BoxShape.circle,
//                                                         color: ConstantColors
//                                                             .blueColor,
//                                                       ),
//                                                       child: const Icon(
//                                                         Icons.share_rounded,
//                                                         size: 26,
//                                                         color: Colors.white,
//                                                       ))),
//                                             )
//                                           : const Offstage(),
//                                     ],
//                                   ),
//                                   Row(
//                                     children: [
//                                       Padding(
//                                         padding:
//                                             const EdgeInsets.only(left: 10),
//                                         child: InkWell(
//                                             onTap: () {
//                                               Constant.makePhoneCall(
//                                                   data.driverPhone.toString());
//                                             },
//                                             child: Image.asset(
//                                               'assets/icons/call_icon.png',
//                                               height: 36,
//                                               width: 36,
//                                             )),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(
//                                   top: 5.0,
//                                 ),
//                                 child: Text(data.parcelDate.toString(),
//                                     style: const TextStyle(
//                                         color: Colors.black26,
//                                         fontWeight: FontWeight.w600)),
//                               ),
//                             ],
//                           )
//                         ],
//                       ),
//                     ),
//                   Visibility(
//                     visible: data.status.toString() == "completed",
//                     child: Padding(
//                       padding:
//                           const EdgeInsets.only(top: 15.0, left: 10, right: 10),
//                       child: Row(
//                         children: [
//                           Expanded(
//                               child: ButtonThem.buildButton(context,
//                                   btnHeight: 40,
//                                   title: data.paymentStatus == "yes"
//                                       ? "Paid".tr
//                                       : "Pay Now".tr,
//                                   btnColor: data.paymentStatus == "yes"
//                                       ? Colors.green
//                                       : ConstantColors.primary,
//                                   txtColor: Colors.white, onPress: () async {
//                             if (data.paymentStatus == "yes") {
//                             } else {
//                               var isDone = await Get.to(
//                                   const ParcelDetailsScreen(),
//                                   arguments: {
//                                     "parcelData": data,
//                                   });
//                               if (isDone != null) {}
//                             }
//                           })),
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           Expanded(
//                               child: ButtonThem.buildBorderButton(
//                             context,
//                             title: 'add_review'.tr,
//                             btnWidthRatio: 0.8,
//                             btnHeight: 40,
//                             btnColor: Colors.white,
//                             txtColor: ConstantColors.primary,
//                             btnBorderColor: ConstantColors.primary,
//                             onPress: () async {
//                               Get.to(const AddReviewScreen(), arguments: {
//                                 "data": data,
//                                 "ride_type": "parcel",
//                               })!
//                                   .then((value) {});
//                             },
//                           )),
//                         ],
//                       ),
//                     ),
//                   ),
//                   Visibility(
//                       visible: data.status == "completed",
//                       child: Padding(
//                         padding:
//                             const EdgeInsets.only(left: 10, right: 10, top: 10),
//                         child: ButtonThem.buildBorderButton(
//                           context,
//                           title: 'add_complaint'.tr,
//                           btnHeight: 40,
//                           btnColor: Colors.white,
//                           txtColor: ConstantColors.primary,
//                           btnBorderColor: ConstantColors.primary,
//                           onPress: () async {
//                             Get.to(AddComplaintScreen(), arguments: {
//                               "data": data,
//                               "ride_type": "parcel",
//                             })!
//                                 .then((value) {});
//                           },
//                         ),
//                       )),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//               right: 0,
//               child: Image.asset(
//                 data.status == "new"
//                     ? 'assets/images/new.png'
//                     : data.status == "confirmed"
//                         ? 'assets/images/conformed.png'
//                         : data.status == "onride"
//                             ? 'assets/images/onride.png'
//                             : data.status == "completed"
//                                 ? 'assets/images/completed.png'
//                                 : 'assets/images/rejected.png',
//                 height: 120,
//                 width: 120,
//               )),
//         ],
//       ),
//     );
//   }
//
//   buildUsersDetails(context, ParcelData data, {bool isSender = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 8.0,
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Text(
//                       isSender ? "${"Sender".tr} " : "${"Receiver".tr} ",
//                       style: TextStyle(
//                           fontSize: 16,
//                           color: isSender
//                               ? ConstantColors.primary
//                               : const Color(0xffd17e19)),
//                     ),
//                     Text(
//                       isSender
//                           ? data.senderName.toString()
//                           : data.receiverName.toString(),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                         fontSize: 16,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Text(
//                   isSender
//                       ? data.senderPhone.toString()
//                       : data.receiverPhone.toString(),
//                   style: TextStyle(
//                       fontSize: 16, color: ConstantColors.subTitleTextColor),
//                 ),
//                 Text(
//                   isSender
//                       ? data.source.toString()
//                       : data.destination.toString(),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                       fontSize: 16, color: ConstantColors.subTitleTextColor),
//                 ),
//               ],
//             ),
//           ),
//           !isSender
//               ? InkWell(
//                   onTap: () {
//                     Constant.makePhoneCall(data.receiverPhone.toString());
//                   },
//                   child: Image.asset(
//                     'assets/icons/call_icon.png',
//                     height: 36,
//                     width: 36,
//                   ))
//               : const Offstage(),
//         ],
//       ),
//     );
//   }
//
//   buildLine() {
//     return Column(
//       children: [
//         const SizedBox(
//           height: 6,
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 8.0,
//           ),
//           child: Image.asset("assets/images/circle.png", height: 20),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 2),
//           child: SizedBox(
//             width: 1.3,
//             child: ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: 15,
//                 itemBuilder: (context, index) {
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 1),
//                     child: Container(
//                       color: Colors.black38,
//                       height: 2.5,
//                     ),
//                   );
//                 }),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8.0),
//           child: Image.asset("assets/images/parcel_Image.png", height: 20),
//         ),
//       ],
//     );
//   }
// }
