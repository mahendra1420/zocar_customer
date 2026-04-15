// import 'package:zocar/constant/constant.dart';
// import 'package:zocar/constant/show_toast_dialog.dart';
// import 'package:zocar/controller/parcel_service_controller.dart';
// import 'package:zocar/themes/button_them.dart';
// import 'package:zocar/themes/constant_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:text_scroll/text_scroll.dart';
//
// class CartParcelScreen extends StatelessWidget {
//   const CartParcelScreen({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ConstantColors.background,
//       appBar: AppBar(
//           backgroundColor: ConstantColors.background,
//           elevation: 0,
//           leading: GestureDetector(
//               onTap: () => Get.back(),
//               child: const Icon(
//                 Icons.arrow_back_ios,
//                 color: Colors.black,
//               )),
//           centerTitle: true,
//           title: Text(
//             "Confirm Parcel".tr,
//             style: const TextStyle(color: Colors.black),
//           )),
//       body: GetX<ParcelServiceController>(builder: (controller) {
//         return SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           child: Column(
//             children: [
//               showOrderOverView(
//                 context,
//                 controller,
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 15),
//                 child: paymentListView(controller),
//               ),
//             ],
//           ),
//         );
//       }),
//       bottomNavigationBar:
//           GetBuilder<ParcelServiceController>(builder: (controller) {
//         return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             child: ButtonThem.buildButton(context,
//                 title: 'Continue'.tr,
//                 btnColor: ConstantColors.primary,
//                 txtColor: Colors.white, onPress: () {
//               if (controller.paymentMethodId.isEmpty) {
//                 ShowToastDialog.showToast("Select Payment Option".tr);
//               } else {
//                 controller.bookParcelRide();
//               }
//             }));
//       }),
//     );
//   }
//
//   /// show Order Detail
//   showOrderOverView(
//     context,
//     ParcelServiceController controller,
//   ) {
//     return Container(
//       margin: const EdgeInsets.only(left: 13, top: 10, right: 13, bottom: 13),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.grey.shade100, width: 1),
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.5),
//             blurRadius: 5,
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 12.0),
//         child: Column(
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 buildLine(),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       buildUsersDetails(
//                         context,
//                         controller,
//                       ),
//                       const SizedBox(
//                         height: 5,
//                       ),
//                       buildUsersDetails(
//                         context,
//                         controller,
//                         isSender: false,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const Divider(
//               color: Colors.black12,
//               thickness: 1,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 showParcelDetails(
//                   title: "Distance".tr,
//                   value: controller.distance.toStringAsFixed(
//                           int.parse(Constant.decimal.toString())) +
//                       Constant.distanceUnit.toString(),
//                 ),
//                 showParcelDetails(
//                   title: "Duration".tr,
//                   value: controller.duration.value.toString(),
//                 ),
//
//                 //showParcelDetails(title: "Rate".tr(), value: "$symbol${subTotal.toStringAsFixed(decimal)}", color: Color(COLOR_PRIMARY)),
//                 showParcelDetails(
//                     title: "Total".tr,
//                     value: Constant().amountShow(
//                         amount: controller.subTotal.toStringAsFixed(
//                             int.parse(Constant.decimal.toString()))),
//                     color: ConstantColors.primary),
//               ],
//             ),
//             Row(
//               children: [
//                 showParcelDetails(
//                   title: "Weight".tr,
//                   value: "${controller.parcelWeightController.text}Kg",
//                 ),
//                 showParcelDetails(
//                   title: "Dimension".tr,
//                   value: "${controller.parcelDimentionController.text}ft",
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   ///show User Details
//   buildUsersDetails(
//     context,
//     ParcelServiceController controller, {
//     bool isSender = true,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 8.0,
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Text(
//                 isSender ? "${"Sender".tr} " : "${"Receiver".tr} ",
//                 style: TextStyle(fontSize: 16, color: ConstantColors.primary),
//               ),
//               Text(
//                 isSender
//                     ? controller.sNameController.text.toString()
//                     : controller.rNameController.text.toString(),
//                 style: const TextStyle(
//                   fontSize: 16,
//                 ),
//               ),
//             ],
//           ),
//           Text(
//             isSender
//                 ? controller.sPhoneController.text.toString()
//                 : controller.rPhoneController.text.toString(),
//             style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
//           ),
//           // const SizedBox(
//           //   height: 5,
//           // ),
//           Text(
//             isSender
//                 ? controller.senderAddress.toString()
//                 : controller.receiverAddress.toString(),
//             maxLines: 3,
//             style: TextStyle(color: Colors.grey.shade500),
//           ),
//           Text(
//             isSender
//                 ? controller.senderDate.toString()
//                 : controller.receiverDate.toString(),
//             maxLines: 3,
//             style: TextStyle(color: Colors.grey.shade500),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// show parcel details
//   showParcelDetails({
//     required String title,
//     required String value,
//     Color color = Colors.black,
//   }) {
//     return Expanded(
//       child: Container(
//         alignment: Alignment.center,
//         margin: const EdgeInsets.all(5),
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: Colors.black12,
//           ),
//           borderRadius: const BorderRadius.all(Radius.circular(10)),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             Text(title, style: const TextStyle(color: Colors.grey)),
//             const SizedBox(
//               height: 5,
//             ),
//             TextScroll(
//               value,
//               mode: TextScrollMode.bouncing,
//               pauseBetween: const Duration(seconds: 2),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   ///createLine
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
//
//   Widget paymentListView(ParcelServiceController controller) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         const Text("Select Payment Method"),
//         Divider(
//           color: Colors.grey.shade700,
//         ),
//         Visibility(
//           visible: controller.paymentSettingModel.value.cash != null &&
//                   controller.paymentSettingModel.value.cash!.isEnabled == "true"
//               ? true
//               : false,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 3.0),
//             child: Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               elevation: controller.cash.value ? 0 : 2,
//               child: RadioListTile(
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     side: BorderSide(
//                         color: controller.cash.value
//                             ? ConstantColors.primary
//                             : Colors.transparent)),
//                 controlAffinity: ListTileControlAffinity.trailing,
//                 value: "Cash",
//                 groupValue: controller.paymentMethodType.value,
//                 onChanged: (String? value) {
//                   controller.stripe = false.obs;
//                   controller.wallet = false.obs;
//                   controller.cash = true.obs;
//                   controller.razorPay = false.obs;
//                   controller.payTm = false.obs;
//                   controller.paypal = false.obs;
//                   controller.payStack = false.obs;
//                   controller.flutterWave = false.obs;
//                   controller.mercadoPago = false.obs;
//                   controller.payFast = false.obs;
//                   controller.paymentMethodType.value = value!;
//                   controller.paymentMethodId = controller
//                       .paymentSettingModel.value.cash!.idPaymentMethod
//                       .toString()
//                       .obs;
//                 },
//                 selected: controller.cash.value,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 6,
//                 ),
//                 title: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Container(
//                         decoration: BoxDecoration(
//                           color: Colors.blueGrey.shade50,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 4.0),
//                           child: SizedBox(
//                             width: 80,
//                             height: 35,
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(vertical: 6.0),
//                               child: Image.asset(
//                                 "assets/images/cash.png",
//                               ),
//                             ),
//                           ),
//                         )),
//                     const SizedBox(
//                       width: 20,
//                     ),
//                     Text("Cash".tr),
//                   ],
//                 ),
//                 //toggleable: true,
//               ),
//             ),
//           ),
//         ),
//         Visibility(
//           visible: controller.paymentSettingModel.value.myWallet != null &&
//                   controller.paymentSettingModel.value.myWallet!.isEnabled ==
//                       "true"
//               ? true
//               : false,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 3.0),
//             child: Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               elevation: controller.wallet.value ? 0 : 2,
//               child: RadioListTile(
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     side: BorderSide(
//                         color: controller.wallet.value
//                             ? ConstantColors.primary
//                             : Colors.transparent)),
//                 controlAffinity: ListTileControlAffinity.trailing,
//                 value: "Wallet",
//                 groupValue: controller.paymentMethodType.value,
//                 onChanged: (String? value) {
//                   controller.stripe = false.obs;
//                   controller.wallet = true.obs;
//                   controller.cash = false.obs;
//                   controller.razorPay = false.obs;
//                   controller.payTm = false.obs;
//                   controller.paypal = false.obs;
//                   controller.payStack = false.obs;
//                   controller.flutterWave = false.obs;
//                   controller.mercadoPago = false.obs;
//                   controller.payFast = false.obs;
//                   controller.paymentMethodType.value = value!;
//                   controller.paymentMethodId = controller
//                       .paymentSettingModel.value.myWallet!.idPaymentMethod
//                       .toString()
//                       .obs;
//                 },
//                 selected: controller.wallet.value,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 6,
//                 ),
//                 title: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Container(
//                         decoration: BoxDecoration(
//                           color: Colors.blueGrey.shade50,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 4.0),
//                           child: SizedBox(
//                             width: 80,
//                             height: 35,
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(vertical: 6.0),
//                               child: Image.asset(
//                                 "assets/icons/walltet_icons.png",
//                               ),
//                             ),
//                           ),
//                         )),
//                     const SizedBox(
//                       width: 20,
//                     ),
//                     Text("Wallet".tr),
//                   ],
//                 ),
//                 //toggleable: true,
//               ),
//             ),
//           ),
//         ),
//         Visibility(
//           visible: controller.paymentSettingModel.value.strip != null &&
//                   controller.paymentSettingModel.value.strip!.isEnabled ==
//                       "true"
//               ? true
//               : false,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 3.0),
//             child: Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               elevation: controller.stripe.value ? 0 : 2,
//               child: RadioListTile(
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     side: BorderSide(
//                         color: controller.stripe.value
//                             ? ConstantColors.primary
//                             : Colors.transparent)),
//                 controlAffinity: ListTileControlAffinity.trailing,
//                 value: "Stripe",
//                 groupValue: controller.paymentMethodType.value,
//                 onChanged: (String? value) {
//                   controller.stripe = true.obs;
//                   controller.wallet = false.obs;
//                   controller.cash = false.obs;
//                   controller.razorPay = false.obs;
//                   controller.payTm = false.obs;
//                   controller.paypal = false.obs;
//                   controller.payStack = false.obs;
//                   controller.flutterWave = false.obs;
//                   controller.mercadoPago = false.obs;
//                   controller.payFast = false.obs;
//                   controller.paymentMethodType.value = value!;
//                   controller.paymentMethodId = controller
//                       .paymentSettingModel.value.strip!.idPaymentMethod
//                       .toString()
//                       .obs;
//                 },
//                 selected: controller.stripe.value,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 6,
//                 ),
//                 title: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Container(
//                         decoration: BoxDecoration(
//                           color: Colors.blueGrey.shade50,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 4.0),
//                           child: SizedBox(
//                             width: 80,
//                             height: 35,
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(vertical: 6.0),
//                               child: Image.asset(
//                                 "assets/images/stripe.png",
//                               ),
//                             ),
//                           ),
//                         )),
//                     const SizedBox(
//                       width: 20,
//                     ),
//                     Text("Stripe".tr),
//                   ],
//                 ),
//                 //toggleable: true,
//               ),
//             ),
//           ),
//         ),
//         Visibility(
//           visible: controller.paymentSettingModel.value.payStack != null &&
//                   controller.paymentSettingModel.value.payStack!.isEnabled ==
//                       "true"
//               ? true
//               : false,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 3.0),
//             child: Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               elevation: controller.payStack.value ? 0 : 2,
//               child: RadioListTile(
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     side: BorderSide(
//                         color: controller.payStack.value
//                             ? ConstantColors.primary
//                             : Colors.transparent)),
//                 controlAffinity: ListTileControlAffinity.trailing,
//                 value: "PayStack",
//                 groupValue: controller.paymentMethodType.value,
//                 onChanged: (String? value) {
//                   controller.stripe = false.obs;
//                   controller.wallet = false.obs;
//                   controller.cash = false.obs;
//                   controller.razorPay = false.obs;
//                   controller.payTm = false.obs;
//                   controller.paypal = false.obs;
//                   controller.payStack = true.obs;
//                   controller.flutterWave = false.obs;
//                   controller.mercadoPago = false.obs;
//                   controller.payFast = false.obs;
//                   controller.paymentMethodType.value = value!;
//                   controller.paymentMethodId = controller
//                       .paymentSettingModel.value.payStack!.idPaymentMethod
//                       .toString()
//                       .obs;
//                 },
//                 selected: controller.payStack.value,
//                 //selectedRadioTile == "strip" ? true : false,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 6,
//                 ),
//                 title: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Container(
//                         decoration: BoxDecoration(
//                           color: Colors.blueGrey.shade50,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 4.0),
//                           child: SizedBox(
//                             width: 80,
//                             height: 35,
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(vertical: 6.0),
//                               child: Image.asset(
//                                 "assets/images/paystack.png",
//                               ),
//                             ),
//                           ),
//                         )),
//                     const SizedBox(
//                       width: 20,
//                     ),
//                     Text("PayStack".tr),
//                   ],
//                 ),
//                 //toggleable: true,
//               ),
//             ),
//           ),
//         ),
//         Visibility(
//           visible: controller.paymentSettingModel.value.flutterWave != null &&
//                   controller.paymentSettingModel.value.flutterWave!.isEnabled ==
//                       "true"
//               ? true
//               : false,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 3.0),
//             child: Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               elevation: controller.flutterWave.value ? 0 : 2,
//               child: RadioListTile(
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     side: BorderSide(
//                         color: controller.flutterWave.value
//                             ? ConstantColors.primary
//                             : Colors.transparent)),
//                 controlAffinity: ListTileControlAffinity.trailing,
//                 value: "FlutterWave",
//                 groupValue: controller.paymentMethodType.value,
//                 onChanged: (String? value) {
//                   controller.stripe = false.obs;
//                   controller.wallet = false.obs;
//                   controller.cash = false.obs;
//                   controller.razorPay = false.obs;
//                   controller.payTm = false.obs;
//                   controller.paypal = false.obs;
//                   controller.payStack = false.obs;
//                   controller.flutterWave = true.obs;
//                   controller.mercadoPago = false.obs;
//                   controller.payFast = false.obs;
//                   controller.paymentMethodType.value = value!;
//                   controller.paymentMethodId.value = controller
//                       .paymentSettingModel.value.flutterWave!.idPaymentMethod
//                       .toString();
//                 },
//                 selected: controller.flutterWave.value,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 6,
//                 ),
//                 title: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Container(
//                         decoration: BoxDecoration(
//                           color: Colors.blueGrey.shade50,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 4.0),
//                           child: SizedBox(
//                             width: 80,
//                             height: 35,
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(vertical: 6.0),
//                               child: Image.asset(
//                                 "assets/images/flutterwave.png",
//                               ),
//                             ),
//                           ),
//                         )),
//                     const SizedBox(
//                       width: 20,
//                     ),
//                     Text("FlutterWave".tr),
//                   ],
//                 ),
//                 //toggleable: true,
//               ),
//             ),
//           ),
//         ),
//         Visibility(
//           visible: controller.paymentSettingModel.value.razorpay != null &&
//                   controller.paymentSettingModel.value.razorpay!.isEnabled ==
//                       "true"
//               ? true
//               : false,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 3.0),
//             child: Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               elevation: controller.razorPay.value ? 0 : 2,
//               child: RadioListTile(
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     side: BorderSide(
//                         color: controller.razorPay.value
//                             ? ConstantColors.primary
//                             : Colors.transparent)),
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 6,
//                 ),
//                 controlAffinity: ListTileControlAffinity.trailing,
//                 value: "RazorPay",
//                 groupValue: controller.paymentMethodType.value,
//                 onChanged: (String? value) {
//                   controller.stripe = false.obs;
//                   controller.wallet = false.obs;
//                   controller.cash = false.obs;
//                   controller.razorPay = true.obs;
//                   controller.payTm = false.obs;
//                   controller.paypal = false.obs;
//                   controller.payStack = false.obs;
//                   controller.flutterWave = false.obs;
//                   controller.mercadoPago = false.obs;
//                   controller.payFast = false.obs;
//                   controller.paymentMethodType.value = value!;
//                   controller.paymentMethodId.value = controller
//                       .paymentSettingModel.value.razorpay!.idPaymentMethod
//                       .toString();
//                 },
//                 selected: controller.razorPay.value,
//                 title: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Container(
//                         decoration: BoxDecoration(
//                           color: Colors.blueGrey.shade50,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 3.0),
//                           child: SizedBox(
//                               width: 80,
//                               height: 35,
//                               child: Image.asset(
//                                   "assets/images/razorpay_@3x.png")),
//                         )),
//                     const SizedBox(
//                       width: 20,
//                     ),
//                     Text("RazorPay".tr),
//                   ],
//                 ),
//                 //toggleable: true,
//               ),
//             ),
//           ),
//         ),
//         Visibility(
//           visible: controller.paymentSettingModel.value.payFast != null &&
//                   controller.paymentSettingModel.value.payFast!.isEnabled ==
//                       "true"
//               ? true
//               : false,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 4.0),
//             child: Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               elevation: controller.payFast.value ? 0 : 2,
//               child: RadioListTile(
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     side: BorderSide(
//                         color: controller.payFast.value
//                             ? ConstantColors.primary
//                             : Colors.transparent)),
//                 controlAffinity: ListTileControlAffinity.trailing,
//                 value: "PayFast",
//                 groupValue: controller.paymentMethodType.value,
//                 onChanged: (String? value) {
//                   controller.stripe = false.obs;
//                   controller.wallet = false.obs;
//                   controller.cash = false.obs;
//                   controller.razorPay = false.obs;
//                   controller.payTm = false.obs;
//                   controller.paypal = false.obs;
//                   controller.payStack = false.obs;
//                   controller.flutterWave = false.obs;
//                   controller.mercadoPago = false.obs;
//                   controller.payFast = true.obs;
//                   controller.paymentMethodType.value = value!;
//                   controller.paymentMethodId.value = controller
//                       .paymentSettingModel.value.payFast!.idPaymentMethod
//                       .toString();
//                 },
//                 selected: controller.payFast.value,
//                 //selectedRadioTile == "strip" ? true : false,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 6,
//                 ),
//                 title: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Container(
//                         decoration: BoxDecoration(
//                           color: Colors.blueGrey.shade50,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 4.0),
//                           child: SizedBox(
//                             width: 80,
//                             height: 35,
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(vertical: 6.0),
//                               child: Image.asset(
//                                 "assets/images/payfast.png",
//                               ),
//                             ),
//                           ),
//                         )),
//                     const SizedBox(
//                       width: 20,
//                     ),
//                     Text("Pay Fast".tr),
//                   ],
//                 ),
//                 //toggleable: true,
//               ),
//             ),
//           ),
//         ),
//         Visibility(
//           visible: controller.paymentSettingModel.value.paytm != null &&
//                   controller.paymentSettingModel.value.paytm!.isEnabled ==
//                       "true"
//               ? true
//               : false,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 3.0),
//             child: Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               elevation: controller.payTm.value ? 0 : 2,
//               child: RadioListTile(
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     side: BorderSide(
//                         color: controller.payTm.value
//                             ? ConstantColors.primary
//                             : Colors.transparent)),
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 6,
//                 ),
//                 controlAffinity: ListTileControlAffinity.trailing,
//                 value: "PayTm",
//                 groupValue: controller.paymentMethodType.value,
//                 onChanged: (String? value) {
//                   controller.stripe = false.obs;
//                   controller.wallet = false.obs;
//                   controller.cash = false.obs;
//                   controller.razorPay = false.obs;
//                   controller.payTm = true.obs;
//                   controller.paypal = false.obs;
//                   controller.payStack = false.obs;
//                   controller.flutterWave = false.obs;
//                   controller.mercadoPago = false.obs;
//                   controller.payFast = false.obs;
//                   controller.paymentMethodType.value = value!;
//                   controller.paymentMethodId.value = controller
//                       .paymentSettingModel.value.paytm!.idPaymentMethod
//                       .toString();
//                 },
//                 selected: controller.payTm.value,
//                 title: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Container(
//                         decoration: BoxDecoration(
//                           color: Colors.blueGrey.shade50,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 3.0),
//                           child: SizedBox(
//                               width: 80,
//                               height: 35,
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(vertical: 3.0),
//                                 child: Image.asset(
//                                   "assets/images/paytm_@3x.png",
//                                 ),
//                               )),
//                         )),
//                     const SizedBox(
//                       width: 20,
//                     ),
//                     Text("Paytm".tr),
//                   ],
//                 ),
//                 //toggleable: true,
//               ),
//             ),
//           ),
//         ),
//         Visibility(
//           visible: controller.paymentSettingModel.value.mercadopago != null &&
//                   controller.paymentSettingModel.value.mercadopago!.isEnabled ==
//                       "true"
//               ? true
//               : false,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 4.0),
//             child: Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               elevation: controller.mercadoPago.value ? 0 : 2,
//               child: RadioListTile(
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     side: BorderSide(
//                         color: controller.mercadoPago.value
//                             ? ConstantColors.primary
//                             : Colors.transparent)),
//                 controlAffinity: ListTileControlAffinity.trailing,
//                 value: "MercadoPago",
//                 groupValue: controller.paymentMethodType.value,
//                 onChanged: (String? value) {
//                   controller.stripe = false.obs;
//                   controller.wallet = false.obs;
//                   controller.cash = false.obs;
//                   controller.razorPay = false.obs;
//                   controller.payTm = false.obs;
//                   controller.paypal = false.obs;
//                   controller.payStack = false.obs;
//                   controller.flutterWave = false.obs;
//                   controller.mercadoPago = true.obs;
//                   controller.payFast = false.obs;
//                   controller.paymentMethodType.value = value!;
//                   controller.paymentMethodId.value = controller
//                       .paymentSettingModel.value.mercadopago!.idPaymentMethod
//                       .toString();
//                 },
//                 selected: controller.mercadoPago.value,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 6,
//                 ),
//                 title: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Container(
//                         decoration: BoxDecoration(
//                           color: Colors.blueGrey.shade50,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 4.0),
//                           child: SizedBox(
//                             width: 80,
//                             height: 35,
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(vertical: 6.0),
//                               child: Image.asset(
//                                 "assets/images/mercadopago.png",
//                               ),
//                             ),
//                           ),
//                         )),
//                     const SizedBox(
//                       width: 20,
//                     ),
//                     Text("Mercado Pago".tr),
//                   ],
//                 ),
//                 //toggleable: true,
//               ),
//             ),
//           ),
//         ),
//         Visibility(
//           visible: controller.paymentSettingModel.value.payPal != null &&
//                   controller.paymentSettingModel.value.payPal!.isEnabled ==
//                       "true"
//               ? true
//               : false,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 3.0),
//             child: Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               elevation: controller.paypal.value ? 0 : 2,
//               child: RadioListTile(
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     side: BorderSide(
//                         color: controller.paypal.value
//                             ? ConstantColors.primary
//                             : Colors.transparent)),
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 6,
//                 ),
//                 controlAffinity: ListTileControlAffinity.trailing,
//                 value: "PayPal",
//                 groupValue: controller.paymentMethodType.value,
//                 onChanged: (String? value) {
//                   controller.stripe = false.obs;
//                   controller.wallet = false.obs;
//                   controller.cash = false.obs;
//                   controller.razorPay = false.obs;
//                   controller.payTm = false.obs;
//                   controller.paypal = true.obs;
//                   controller.payStack = false.obs;
//                   controller.flutterWave = false.obs;
//                   controller.mercadoPago = false.obs;
//                   controller.payFast = false.obs;
//                   controller.paymentMethodType.value = value!;
//                   controller.paymentMethodId.value = controller
//                       .paymentSettingModel.value.payPal!.idPaymentMethod
//                       .toString();
//                 },
//                 selected: controller.paypal.value,
//                 title: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Container(
//                         decoration: BoxDecoration(
//                           color: Colors.blueGrey.shade50,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 3.0),
//                           child: SizedBox(
//                               width: 80,
//                               height: 35,
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(vertical: 3.0),
//                                 child:
//                                     Image.asset("assets/images/paypal_@3x.png"),
//                               )),
//                         )),
//                     const SizedBox(
//                       width: 20,
//                     ),
//                     Text("PayPal".tr),
//                   ],
//                 ),
//                 //toggleable: true,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
