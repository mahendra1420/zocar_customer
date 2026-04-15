// import 'package:zocar/constant/constant.dart';
// import 'package:zocar/model/parcel_category_model.dart';
// import 'package:zocar/page/parcel_service_screen/book_parcel_screen.dart';
// import 'package:zocar/themes/constant_colors.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controller/parcel_service_controller.dart';
//
// class ParcelCategoryScreen extends StatelessWidget {
//   const ParcelCategoryScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetX<ParcelServiceController>(
//         init: ParcelServiceController(),
//         builder: (controller) {
//           return Scaffold(
//             backgroundColor: ConstantColors.background,
//             body: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(left: 10.0, bottom: 10),
//                     child: Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         "What are you sending?".tr,
//                         style: const TextStyle(fontSize: 18),
//                         textAlign: TextAlign.left,
//                       ),
//                     ),
//                   ),
//                   controller.isLoading.value
//                       ? Center(child: Constant.loader())
//                       : Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 10),
//                           child: GridView.builder(
//                               gridDelegate:
//                                   const SliverGridDelegateWithFixedCrossAxisCount(
//                                       crossAxisCount: 2,
//                                       crossAxisSpacing: 15,
//                                       mainAxisSpacing: 15,
//                                       mainAxisExtent: 120),
//                               itemCount: controller.parcelCategoryList.length,
//                               padding: const EdgeInsets.all(8),
//                               shrinkWrap: true,
//                               physics: const ScrollPhysics(),
//                               itemBuilder: (context, index) {
//                                 return buildItems(
//                                     item: controller.parcelCategoryList[index],
//                                     controller: controller);
//                               }),
//                         )
//                 ],
//               ),
//             ),
//           );
//         });
//   }
//
//   buildItems(
//       {required ParcelCategoryData item,
//       required ParcelServiceController controller}) {
//     print("MyParcelImage ==> ${item.image.toString()}");
//     return InkWell(
//       onTap: () {
//         controller.selectedParcelCategoryId.value = item.id.toString();
//
//         Get.to(
//           () => const BookParcelScreen(),
//         );
//       },
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             CachedNetworkImage(
//               imageUrl: item.image.toString(),
//               height: 60,
//               width: 60,
//               imageBuilder: (context, imageProvider) => Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   image:
//                       DecorationImage(image: imageProvider, fit: BoxFit.cover),
//                 ),
//               ),
//               placeholder: (context, url) => Constant.loader(),
//               errorWidget: (context, url, error) => const Icon(Icons.error),
//               fit: BoxFit.cover,
//             ),
//             Text(item.title.toString()),
//           ],
//         ),
//       ),
//     );
//   }
// }
