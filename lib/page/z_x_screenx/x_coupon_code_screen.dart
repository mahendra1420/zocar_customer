// // ignore_for_file: prefer_const_constructors
//
// import 'package:zocar/constant/constant.dart';
// import 'package:zocar/controller/coupon_code_controller.dart';
// import 'package:zocar/model/CoupanCodeModel.dart';
// import 'package:zocar/themes/constant_colors.dart';
// import 'package:clipboard/clipboard.dart';
// import 'package:dotted_border/dotted_border.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class CouponCodeScreen extends StatelessWidget {
//   const CouponCodeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetX<CouponCodeController>(
//         init: CouponCodeController(),
//         builder: (controller) {
//           return Scaffold(
//             backgroundColor: ConstantColors.background,
//             appBar: AppBar(title: Text("Coupons"),),
//             body: RefreshIndicator(
//               onRefresh: () => controller.getCoupanCodeData(),
//               child: controller.isLoading.value
//                   ? Constant.loader()
//                   : controller.coupanCodeList.isEmpty
//                       ? Center(
//                           child: Constant.emptyView(
//                               context, "No coupons available".tr, false),
//                         )
//                       : ListView.builder(
//                           itemCount: controller.coupanCodeList.length,
//                           shrinkWrap: true,
//                           itemBuilder: (context, index) {
//                             return buildPromoCodeItem(
//                                 context, controller.coupanCodeList[index]);
//                           }),
//             ),
//           );
//         });
//   }
//
//   Widget buildPromoCodeItem(BuildContext context, CoupanCodeData data) {
//     return Container(
//       height: 140,
//       padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: const BoxDecoration(
//         image: DecorationImage(
//           image: AssetImage('assets/images/promo_bg.png'),
//           fit: BoxFit.fill,
//         ),
//       ),
//       child: Center(
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(left: 30),
//               child: Container(
//                 decoration: const BoxDecoration(
//                     color: Colors.blue,
//                     borderRadius: BorderRadius.all(Radius.circular(30))),
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Image.asset(
//                     'assets/icons/promocode.png',
//                     width: 40,
//                     height: 40,
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 35),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       data.discription.toString(),
//                       style: const TextStyle(
//                           color: Colors.black,
//                           fontSize: 18,
//                           fontWeight: FontWeight.w900,
//                           letterSpacing: 1),
//                     ),
//                     const SizedBox(
//                       height: 3,
//                     ),
//                     Row(
//                       children: [
//                         InkWell(
//                           onTap: () {
//                             FlutterClipboard.copy(data.code.toString())
//                                 .then((value) {
//                               final SnackBar snackBar = SnackBar(
//                                 content: Text(
//                                   "Coupon Code Copied".tr,
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                                 backgroundColor: Colors.black38,
//                               );
//                               ScaffoldMessenger.of(context)
//                                   .showSnackBar(snackBar);
//                               // return Navigator.pop(context);
//                             });
//                           },
//                           child: Container(
//                             color: Colors.black.withOpacity(0.05),
//                             child: DottedBorder(
//                               color: Colors.grey,
//                               strokeWidth: 1,
//                               dashPattern: const [3, 3],
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 8, vertical: 5),
//                                 child: Text(
//                                   data.code.toString(),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(
//                           width: 8,
//                         ),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "Valid till".tr + data.expireAt.toString(),
//                                 style: const TextStyle(fontSize: 12),
//                               ),
//                               Builder(
//                                   builder: (context) {
//                                     final minAmount = int.tryParse(data.minimum_amount?.toString().trim() ?? '');
//                                     if (minAmount != null && minAmount != 0)
//                                       return Text(
//                                         "${"Min Spend: ".tr} ${data.minimum_amount}",
//                                         style: const TextStyle(fontSize: 12),
//                                         maxLines: 1,
//                                         overflow: TextOverflow.ellipsis,
//                                       );
//                                     return SizedBox();
//                                   }
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         const SizedBox(
//                           width: 8,
//                         ),
//                       ],
//                     ),
//                     Builder(
//                         builder: (context) {
//                           if (data.remainingCount != null && data.remainingCount != 0)
//                             return Text(
//                               "${"Remaining Usages: ".tr} ${data.remainingCount}",
//                               style: const TextStyle(fontSize: 12),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             );
//                           return SizedBox();
//                         }
//                     ),
//                   ],
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
