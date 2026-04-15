// // ignore_for_file: depend_on_referenced_packages
//
// import 'dart:io';
// import 'package:zocar/constant/constant.dart';
// import 'package:zocar/constant/show_toast_dialog.dart';
// import 'package:zocar/controller/parcel_service_controller.dart';
// import 'package:zocar/page/parcel_service_screen/parcel_cart_screen.dart';
// import 'package:zocar/themes/button_them.dart';
// import 'package:zocar/themes/constant_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:intl_phone_number_input/intl_phone_number_input.dart';
// import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
//
// class BookParcelScreen extends StatefulWidget {
//   const BookParcelScreen({super.key});
//
//   @override
//   State<BookParcelScreen> createState() => _BookOrderScreenState();
// }
// String initialCountry = 'IN';
// PhoneNumber number = PhoneNumber(isoCode: 'IN');
// class _BookOrderScreenState extends State<BookParcelScreen> {
//   final GlobalKey<FormState> _key = GlobalKey();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ConstantColors.background,
//       appBar: AppBar(
//           backgroundColor: ConstantColors.background,
//           elevation: 0,
//           leading: GestureDetector(
//               onTap: () => Navigator.pop(context),
//               child: const Icon(
//                 Icons.arrow_back_ios,
//                 color: Colors.black,
//               )),
//           centerTitle: true,
//           title: Text(
//             "Book Parcel".tr,
//             style: const TextStyle(color: Colors.black),
//           )),
//       body: GetX<ParcelServiceController>(
//           init: ParcelServiceController(),
//           builder: (controller) {
//             return Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
//               child: SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 child: Column(
//                   children: [
//                     Form(
//                         key: _key,
//                         child: Column(
//                           children: [
//                             buildSenderDetails(context, controller),
//                             const SizedBox(
//                               height: 12,
//                             ),
//                             buildReceiverDetails(controller),
//                           ],
//                         )),
//                     parcelImageWidget(controller),
//                     Padding(
//                       padding: const EdgeInsets.only(top: 10.0, bottom: 10),
//                       child: ButtonThem.buildButton(context,
//                           title: "Continue".tr,
//                           btnColor: ConstantColors.primary,
//                           txtColor: Colors.white, onPress: () {
//                         if (_key.currentState!.validate()) {
//                           if (controller.senderDate.isEmpty ||
//                               controller.senderTime.isEmpty) {
//                             ShowToastDialog.showToast(
//                               "Select Sender date and time".tr,
//                             );
//                           } else if (controller.receiverDate.isEmpty ||
//                               controller.receiverTime.isEmpty) {
//                             ShowToastDialog.showToast(
//                                 "Select receiver date and time".tr);
//                           } else if (controller.rPhoneController.text.isEmpty ||
//                               controller.sPhoneController.text.isEmpty) {
//                             ShowToastDialog.showToast(
//                                 "Phone number is required.".tr);
//                           } else if (controller.parcelImages.isEmpty) {
//                             ShowToastDialog.showToast("Select parcel image".tr);
//                           } else {
//                             _key.currentState!.save();
//                             controller.getDurationDistance(
//                                 controller.senderLocation!,
//                                 controller.receiverLocation!);
//
//                             Get.to(() => const CartParcelScreen());
//                           }
//                         }
//                       }),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }),
//     );
//   }
//
//   buildSenderDetails(context, ParcelServiceController controller) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                   shape: BoxShape.circle, color: ConstantColors.primary),
//               child: const Padding(
//                 padding: EdgeInsets.all(7.0),
//                 child: Text(
//                   "1",
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ),
//             const SizedBox(
//               width: 8,
//             ),
//             Text(
//               "Sender’s Information".tr,
//               style: TextStyle(fontSize: 16, color: ConstantColors.primary),
//             ),
//           ],
//         ),
//         const SizedBox(
//           height: 8,
//         ),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Sender\'s Address'.tr,
//                           style: const TextStyle(fontWeight: FontWeight.w400)),
//                       const SizedBox(
//                         height: 4,
//                       ),
//                       Text(
//                         controller.senderAddress.toString(),
//                         style: const TextStyle(
//                             fontSize: 14, fontWeight: FontWeight.w600),
//                       )
//                     ],
//                   ),
//                 ),
//                 ElevatedButton(
//                     style: ButtonStyle(
//                         foregroundColor: MaterialStateProperty.all<Color>(
//                             ConstantColors.primary),
//                         backgroundColor:
//                             MaterialStateProperty.all<Color>(Colors.white),
//                         shape: MaterialStateProperty
//                             .all<RoundedRectangleBorder>(RoundedRectangleBorder(
//                                 borderRadius:
//                                     const BorderRadius.all(Radius.circular(8)),
//                                 side: BorderSide(
//                                     color: ConstantColors.primary)))),
//                     onPressed: () async {
//                       Get.to(
//                         () => PlacePicker(
//                           apiKey: Constant.kGoogleApiKey!,
//                           onPlacePicked: (result) async {
//                             controller.senderAddress.value =
//                                 result.formattedAddress!;
//                             // controller.sAddressController.text =
//                             //     result.formattedAddress!;
//                             controller.senderLocation = LatLng(
//                                 double.parse(
//                                     result.geometry!.location.lat.toString()),
//                                 double.parse(
//                                     result.geometry!.location.lng.toString()));
//
//                             await controller
//                                 .getAddressFromLatLong(Position.fromMap({
//                               'latitude': double.parse(
//                                   result.geometry!.location.lat.toString()),
//                               'longitude': double.parse(
//                                   result.geometry!.location.lng.toString()),
//                               'timestamp': 0
//                             }))
//                                 .then((value) {
//                               controller.senderAddressCity.value =
//                                   value.toString().split(",").last.trim();
//                             });
//                             Get.back();
//                           },
//                           initialPosition:
//                               const LatLng(-33.8567844, 151.213108),
//                           useCurrentLocation: true,
//                           selectInitialPosition: true,
//                           usePinPointingSearch: true,
//                           usePlaceDetailSearch: true,
//                           zoomGesturesEnabled: true,
//                           zoomControlsEnabled: true,
//                           initialMapType: MapType.terrain,
//                           resizeToAvoidBottomInset:
//                               false, // only works in page mode, less flickery, remove if wrong offsets
//                         ),
//                       );
//                     },
//                     child: Text(
//                       "Change".tr,
//                     ))
//               ],
//             ),
//             // buildTextFormField(
//             //   color: ConstantColors.primary,
//             //   title: "Sender's Address".tr,
//             //   controller: controller.sAddressController,
//             // ),
//             buildTextFormField(
//               color: ConstantColors.primary,
//               title: "Name".tr,
//               controller: controller.sNameController,
//             ),
//             Padding(
//               padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
//               child: InternationalPhoneNumberInput(
//                 initialValue: PhoneNumber(isoCode: 'IN'),
//                 onInputChanged: (PhoneNumber number) => controller
//                     .sPhoneController.text = number.phoneNumber.toString(),
//                 ignoreBlank: true,
//                 autoValidateMode: AutovalidateMode.onUserInteraction,
//                 inputDecoration: InputDecoration(
//                   hintText: 'Phone Number'.tr,
//                   isDense: true,
//                 ),
//                 inputBorder: const OutlineInputBorder(
//                   borderSide: BorderSide.none,
//                 ),
//                 selectorConfig: const SelectorConfig(
//                     selectorType: PhoneInputSelectorType.DIALOG),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 18.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "When to Pickup at this address".tr,
//                     style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       GestureDetector(
//                         onTap: () => controller.selectDate(
//                           context,
//                         ),
//                         child: Container(
//                           decoration: const BoxDecoration(),
//                           child: Text(
//                             controller.senderDate.isEmpty
//                                 ? 'Select Date'.tr
//                                 : controller.senderDate.toString(),
//                           ),
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () => controller.selectTime(
//                           context,
//                         ),
//                         child: Container(
//                           decoration: const BoxDecoration(),
//                           child: Text(
//                             controller.senderTime.isEmpty
//                                 ? 'Select Time'.tr
//                                 : controller.senderTime.toString(),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   Container(
//                     decoration: const BoxDecoration(color: Colors.black38),
//                     height: 1,
//                   )
//                 ],
//               ),
//             ),
//             // buildParcelDropDown(
//             //   title: "Select Parcel Weight".tr,
//             //   color: ConstantColors.primary,
//             // ),
//             buildTextFormField(
//               textInputType: TextInputType.number,
//               color: ConstantColors.primary,
//               title: "Parcel weight (In Kg.)".tr,
//               controller: controller.parcelWeightController,
//             ),
//             buildTextFormField(
//               textInputType: TextInputType.number,
//               color: ConstantColors.primary,
//               title: "Parcel dimension(In ft.)".tr,
//               controller: controller.parcelDimentionController,
//             ),
//             buildTextFormField(
//               textInputType: TextInputType.multiline,
//               color: ConstantColors.primary,
//               title: "Note".tr,
//               maxLine: 3,
//               controller: controller.noteController,
//             ),
//           ],
//         )
//       ],
//     );
//   }
//
//   buildReceiverDetails(ParcelServiceController controller) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(7.0),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: ConstantColors.primary,
//               ),
//               child: const Text(
//                 "2",
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//             const SizedBox(
//               width: 8,
//             ),
//             Text(
//               "Receiver’s Information".tr,
//               style: TextStyle(fontSize: 16, color: ConstantColors.primary),
//             ),
//           ],
//         ),
//         const SizedBox(
//           height: 8,
//         ),
//         Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Receiver\'s Location'.tr,
//                           style: const TextStyle(fontWeight: FontWeight.w400)),
//                       const SizedBox(
//                         height: 4,
//                       ),
//                       Text(
//                         controller.receiverAddress.toString(),
//                         style: const TextStyle(
//                             fontSize: 14, fontWeight: FontWeight.w600),
//                       )
//                     ],
//                   ),
//                 ),
//                 ElevatedButton(
//                     style: ButtonStyle(
//                         foregroundColor: MaterialStateProperty.all<Color>(
//                             ConstantColors.primary),
//                         backgroundColor:
//                             MaterialStateProperty.all<Color>(Colors.white),
//                         shape: MaterialStateProperty
//                             .all<RoundedRectangleBorder>(RoundedRectangleBorder(
//                                 borderRadius:
//                                     const BorderRadius.all(Radius.circular(8)),
//                                 side: BorderSide(
//                                     color: ConstantColors.primary)))),
//                     onPressed: () async {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => PlacePicker(
//                             apiKey: Constant.kGoogleApiKey!,
//                             onPlacePicked: (result) async {
//                               controller.receiverAddress.value =
//                                   result.formattedAddress!;
//                               controller.receiverLocation = LatLng(
//                                   double.parse(
//                                       result.geometry!.location.lat.toString()),
//                                   double.parse(result.geometry!.location.lng
//                                       .toString()));
//
//                               await controller
//                                   .getAddressFromLatLong(Position.fromMap({
//                                 'latitude': double.parse(
//                                     result.geometry!.location.lat.toString()),
//                                 'longitude': double.parse(
//                                     result.geometry!.location.lng.toString()),
//                                 'timestamp': 0
//                               }))
//                                   .then((value) {
//                                 controller.receiverAddressCity.value =
//                                     value.toString().split(",").last.trim();
//                               });
//
//                               Get.back();
//                             },
//                             initialPosition:
//                                 const LatLng(-33.8567844, 151.213108),
//                             useCurrentLocation: true,
//                             selectInitialPosition: true,
//                             usePinPointingSearch: true,
//                             usePlaceDetailSearch: true,
//                             zoomGesturesEnabled: true,
//                             zoomControlsEnabled: true,
//                             initialMapType: MapType.terrain,
//                             resizeToAvoidBottomInset:
//                                 false, // only works in page mode, less flickery, remove if wrong offsets
//                           ),
//                         ),
//                       );
//                     },
//                     child: Text(
//                       "Change".tr,
//                     ))
//               ],
//             ),
//             // buildTextFormField(
//             //   color: const Color(0xff576FDB),
//             //   title: "Receiver Location".tr,
//             //   controller: controller.rAddressController,
//             // ),
//             buildTextFormField(
//               textInputType: TextInputType.name,
//               color: const Color(0xff576FDB),
//               title: "Name".tr,
//               controller: controller.rNameController,
//             ),
//             Padding(
//               padding: const EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0),
//               child: InternationalPhoneNumberInput(
//                 initialValue: PhoneNumber(isoCode: 'IN'),
//                 onInputChanged: (PhoneNumber number) => controller
//                     .rPhoneController.text = number.phoneNumber.toString(),
//                 ignoreBlank: true,
//                 autoValidateMode: AutovalidateMode.onUserInteraction,
//                 inputDecoration: InputDecoration(
//                   hintText: 'Phone Number'.tr,
//                   isDense: true,
//                 ),
//                 inputBorder: const OutlineInputBorder(
//                   borderSide: BorderSide.none,
//                 ),
//                 selectorConfig: const SelectorConfig(
//                     selectorType: PhoneInputSelectorType.DIALOG),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 18.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "When to arrive at this address".tr,
//                     style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       GestureDetector(
//                         onTap: () =>
//                             controller.selectDate(context, isPickUp: false),
//                         child: Container(
//                           decoration: const BoxDecoration(),
//                           child: Text(
//                             controller.receiverDate.isEmpty
//                                 ? 'Select Date'.tr
//                                 : controller.receiverDate.toString(),
//                           ),
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () =>
//                             controller.selectTime(context, isPickUp: false),
//                         child: Container(
//                           decoration: const BoxDecoration(),
//                           child: Text(
//                             controller.receiverTime.isEmpty
//                                 ? 'Select Time'.tr
//                                 : controller.receiverTime.toString(),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 5,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Container(
//                       decoration: const BoxDecoration(color: Colors.black38),
//                       height: 1,
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ],
//         )
//       ],
//     );
//   }
//
//   buildTextFormField(
//       {required String title,
//       int maxLine = 1,
//       TextInputType textInputType = TextInputType.text,
//       required Color color,
//       required TextEditingController controller,
//       bool isIcons = false,
//       Function()? onClick}) {
//     return TextFormField(
//       keyboardType: textInputType,
//       minLines: 1,
//       maxLines: maxLine,
//       controller: controller,
//       cursorColor: color,
//       validator: (String? value) {
//         if (value!.isNotEmpty) {
//           return null;
//         } else {
//           return 'required'.tr;
//         }
//       },
//       decoration: InputDecoration(
//           floatingLabelStyle: TextStyle(color: color),
//           labelStyle: TextStyle(color: Colors.grey.shade500),
//           floatingLabelBehavior: FloatingLabelBehavior.always,
//           labelText: title,
//           hintText: title,
//           suffixIcon: isIcons
//               ? IconButton(
//                   onPressed: onClick,
//                   icon: const Icon(Icons.location_searching),
//                 )
//               : null,
//           hintStyle: TextStyle(color: Colors.grey.shade600),
//           alignLabelWithHint: true,
//           focusedBorder:
//               UnderlineInputBorder(borderSide: BorderSide(color: color)),
//           focusColor: color),
//     );
//   }
//
//   parcelImageWidget(ParcelServiceController controller) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                   shape: BoxShape.circle, color: ConstantColors.primary),
//               child: const Padding(
//                 padding: EdgeInsets.all(7.0),
//                 child: Text(
//                   "3",
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ),
//             const SizedBox(
//               width: 8,
//             ),
//             Text(
//               "Upload Parcel Image".tr,
//               style: TextStyle(fontSize: 16, color: ConstantColors.primary),
//             ),
//           ],
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           child: SizedBox(
//             height: 100,
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   ListView.builder(
//                     itemCount: controller.parcelImages.length,
//                     shrinkWrap: true,
//                     scrollDirection: Axis.horizontal,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemBuilder: (context, index) {
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 5),
//                         child: Container(
//                           width: 100,
//                           height: 100.0,
//                           decoration: BoxDecoration(
//                             image: DecorationImage(
//                                 fit: BoxFit.cover,
//                                 image: FileImage(
//                                     File(controller.parcelImages[index].path))),
//                             borderRadius:
//                                 const BorderRadius.all(Radius.circular(8.0)),
//                           ),
//                           child: InkWell(
//                               onTap: () {
//                                 controller.parcelImages.removeAt(index);
//                               },
//                               child: const Icon(
//                                 Icons.remove_circle,
//                                 size: 30,
//                               )),
//                         ),
//                       );
//                     },
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                     child: InkWell(
//                       onTap: () {
//                         controller.onCameraClick(context);
//                       },
//                       child: Image.asset('assets/images/parcel_add_image.png',
//                           height: 100),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//         )
//       ],
//     );
//   }
// }
