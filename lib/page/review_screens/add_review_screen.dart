import 'package:zocar/constant/constant.dart';
import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/controller/add_review_controller.dart';
import 'package:zocar/controller/all_rides_controller.dart';
import 'package:zocar/model/coupan_code_model.dart';
import 'package:zocar/page/rewards/reward_dialog.dart';
import 'package:zocar/themes/button_them.dart';
import 'package:zocar/themes/constant_colors.dart';
import 'package:zocar/themes/text_field_them.dart';
import 'package:zocar/widget/my_separator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';

class AddReviewScreen extends StatelessWidget {
  const AddReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<AddReviewController>(
      init: AddReviewController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: ConstantColors.primary,
          appBar: AppBar(
              backgroundColor: ConstantColors.primary,
              elevation: 0,
              centerTitle: true,
              title: Text("Add review".tr, style: const TextStyle(color: Colors.white)),
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.black,
                        ),
                      )),
                ),
              )),
          body: controller.isLoading.value == true
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 42, bottom: 20),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 65),
                            child: Column(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                          controller.rideType.value == "ride"
                                              ? "${controller.rideData.value.prenomConducteur} ${controller.rideData.value.nomConducteur ?? ""}"
                                              : "${controller.parcelData.value.driverName ?? ""}",
                                          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 18)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                                      child: RatingBar.builder(
                                        initialRating: controller.rideType.value == "ride"
                                            ? double.tryParse(controller.rideData.value.moyenne.toString()) ?? 0
                                            : double.tryParse(controller.parcelData.value.moyenne.toString()) ?? 0,
                                        minRating: 1,
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemSize: 22,
                                        tapOnlyMode: false,
                                        updateOnDrag: false,
                                        itemBuilder: (context, _) => const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        onRatingUpdate: (double value) {},
                                      ),
                                    ),
                                    if (controller.rideType.value.toString() == "ride")
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(controller.rideData.value.numberplate?.toUpperCase().toString() ?? "",
                                              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: Text("${controller.rideData.value.brand ?? ""} ${controller.rideData.value.model ?? ""}",
                                                style: const TextStyle(color: Colors.black38, fontWeight: FontWeight.w600)),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: MySeparator(color: Colors.grey),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Text(
                                    'How is your trip?'.tr,
                                    style: const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 2),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Your feedback  will help us improve \n driving experience better'.tr,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: ConstantColors.subTitleTextColor, letterSpacing: 0.8),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Text(
                                    'Rate for'.tr,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: ConstantColors.subTitleTextColor, letterSpacing: 0.8),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    controller.rideType.value == "ride"
                                        ? "${controller.rideData.value.prenomConducteur.toString()} ${controller.rideData.value.nomConducteur.toString()}"
                                        : "${controller.parcelData.value.driverName}",
                                    style: const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 2),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: RatingBar.builder(
                                    initialRating: controller.rating.value,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                    itemBuilder: (context, _) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (rating) {
                                      controller.rating(rating);
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
                                  child: TextFieldThem.boxBuildTextField(
                                    hintText: 'Type comment....'.tr,
                                    controller: controller.reviewCommentController.value,
                                    textInputType: TextInputType.emailAddress,
                                    maxLine: 5,
                                    contentPadding: EdgeInsets.zero,
                                    validators: (String? value) {
                                      if (value!.isNotEmpty) {
                                        return null;
                                      } else {
                                        return 'required'.tr;
                                      }
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
                                  child: ButtonThem.buildButton(context, btnHeight: 45, title: "Submit review".tr, btnColor: ConstantColors.primary, txtColor: Colors.white,
                                      onPress: () async {
                                    if (controller.reviewCommentController.value.text.trim().isEmpty) {
                                      ShowToastDialog.showToast("Please enter comment.!", position: EasyLoadingToastPosition.bottom);
                                      return;
                                    }
                                    Map<String, String> bodyParams = {};
                                    if (controller.rideType.value.toString() == "ride") {
                                      bodyParams = {
                                        'ride_id': controller.rideData.value.id.toString(),
                                        'id_user_app': controller.rideData.value.idUserApp.toString(),
                                        'id_conducteur': controller.rideData.value.idConducteur.toString(),
                                        'note_value': controller.rating.value.toString(),
                                        'comment': controller.reviewCommentController.value.text,
                                        'ride_type': controller.rideType.value.toString(),
                                      };
                                    } else {
                                      bodyParams = {
                                        'ride_id': controller.parcelData.value.id.toString(),
                                        'id_user_app': controller.parcelData.value.idUserApp.toString(),
                                        'id_conducteur': controller.parcelData.value.idConducteur.toString(),
                                        'note_value': controller.rating.value.toString(),
                                        'comment': controller.reviewCommentController.value.text,
                                        'ride_type': controller.rideType.value.toString(),
                                      };
                                    }

                                    final ctx = context;

                                    await controller.addReview(bodyParams).then((value) async {
                                      if (value.$1 != null) {
                                        if (value.$1 == true) {
                                          ShowToastDialog.showToast("Review added successfully!".tr);
                                          Get.back();
                                          final allRidesCtr = Get.find<AllRidesController>();
                                          allRidesCtr.goToTab(1);
                                          allRidesCtr.getAllRides();

                                          if (value.$2.isNotEmpty) {
                                            await Future.delayed(Duration(milliseconds: 500));
                                            showDialog(
                                              barrierDismissible: false,
                                              context: navigator?.context ?? ctx,
                                              builder: (context) => RewardDialog(
                                                rewardCount: value.$2.length,
                                                parentContext: navigator?.context ?? ctx,
                                                couponList: value.$2
                                                    .where((element) => element is Map<String, dynamic>?)
                                                    .map((e) => CoupanCodeData.fromJson((e as Map<String, dynamic>?) ?? {}))
                                                    .toList(),
                                              ),
                                            );
                                          }
                                        } else {
                                          ShowToastDialog.showToast("Something went wrong".tr);
                                        }
                                      }
                                    });
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              blurRadius: 8,
                              spreadRadius: 6,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: CachedNetworkImage(
                            imageUrl: controller.rideType.value == "ride" ? controller.rideData.value.photoPath.toString() : controller.parcelData.value.driverPhoto.toString(),
                            height: 110,
                            width: 110,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Constant.loader(),
                            errorWidget: (context, url, error) => const Icon(Icons.person_2_outlined),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
