import 'dart:convert';
import 'dart:io';

import 'package:zocar/constant/constant.dart';
import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/controller/add_photo_controller.dart';
import 'package:zocar/helpers/app_bg.dart';
import 'package:zocar/helpers/devlog.dart';
import 'package:zocar/model/user_model.dart';
import 'package:zocar/page/auth_screens/login_screen.dart';
import 'package:zocar/page/main_page.dart';
import 'package:zocar/themes/constant_colors.dart';
import 'package:zocar/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AddProfilePhotoScreen extends StatelessWidget {
  AddProfilePhotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<AddPhotoController>(
      init: AddPhotoController(),
      builder: (controller) {
        return AppBg(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                onPressed: () {
                  Get.offAll(() => LoginScreen());
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.black87,
                    size: 20,
                  ),
                ),
              ),
              // actions: [
              //   TextButton(
              //     onPressed: () {
              //       Preferences.setBoolean(Preferences.isLogin, true);
              //       Get.offAll(MainPage());
              //     },
              //     child: Text(
              //       'Skip'.tr,
              //       style: TextStyle(
              //         fontSize: 15,
              //         color: Colors.grey.shade600,
              //         fontWeight: FontWeight.w600,
              //       ),
              //     ),
              //   ),
              // ],
            ),
            body: WillPopScope(
              onWillPop: () async {
                Get.offAll(() => LoginScreen());
                return true;
              },
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Title
                      Text(
                        "Add Profile Photo".tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Subtitle
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "profile_message".tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            height: 1.5,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                      // Profile Photo Container
                      GestureDetector(
                        onTap: () => buildBottomSheet(context, controller),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Photo Circle
                            Container(
                              height: 200,
                              width: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: controller.image.isEmpty ? ConstantColors.primary.withOpacity(0.1) : Colors.transparent,
                                border: Border.all(
                                  color: ConstantColors.primary.withOpacity(0.3),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: ConstantColors.primary.withOpacity(0.2),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: controller.image.isNotEmpty
                                  ? ClipOval(
                                      child: Image.file(
                                        File(controller.image.value),
                                        height: 200,
                                        width: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(
                                      Icons.person_rounded,
                                      size: 100,
                                      color: ConstantColors.primary.withOpacity(0.3),
                                    ),
                            ),
                            // Camera Button Overlay
                            if (controller.image.isEmpty)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: ConstantColors.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: ConstantColors.primary.withOpacity(0.4),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                            // Edit Button (when photo exists)
                            if (controller.image.isNotEmpty)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: ConstantColors.primary,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.edit_rounded,
                                    color: ConstantColors.primary,
                                    size: 20,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Select Photo Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: () => buildBottomSheet(context, controller),
                          icon: const Icon(Icons.photo_library_rounded, size: 20),
                          label: Text(
                            controller.image.isEmpty ? 'Select Photo'.tr : 'Change Photo'.tr,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ConstantColors.primary,
                            side: BorderSide(
                              color: ConstantColors.primary,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButton: controller.image.isNotEmpty
                ? Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        ShowToastDialog.showLoader("Uploading photo".tr);
                        controller.uploadPhoto().then((value) {
                          ShowToastDialog.closeLoader();
                          if (value != null) {
                            if (value["success"] == "Success") {
                              UserModel userModel = Constant.getUserData();
                              userModel.data!.photoPath = value['data']['photo_path'];
                              Preferences.setString(Preferences.user, jsonEncode(userModel.toJson()));
                              Preferences.setBoolean(Preferences.isLogin, true);
                              Get.offAll(MainPage());
                            } else {
                              ShowToastDialog.showToast(value['error']);
                            }
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ConstantColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        shadowColor: ConstantColors.primary.withOpacity(0.4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue'.tr.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.check_circle_rounded, size: 22),
                        ],
                      ),
                    ),
                  )
                : null,
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          ),
        );
      },
    );
  }

  buildBottomSheet(BuildContext context, AddPhotoController controller) {
    return showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle Bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                "Choose Photo Source".tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Select where to get your photo from".tr,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              // Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Camera Option
                  Expanded(
                    child: InkWell(
                      onTap: () => pickFile(controller, source: ImageSource.camera),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: ConstantColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: ConstantColors.primary.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: ConstantColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Camera".tr,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: ConstantColors.primary,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Gallery Option
                  Expanded(
                    child: InkWell(
                      onTap: () => pickFile(controller, source: ImageSource.gallery),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: ConstantColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: ConstantColors.primary.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: ConstantColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.photo_library_rounded,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Gallery".tr,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: ConstantColors.primary,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  final ImagePicker _imagePicker = ImagePicker();

  Future pickFile(AddPhotoController controller, {required ImageSource source}) async {
    try {
      XFile? image = await _imagePicker.pickImage(
        source: source,
        maxHeight: 1024,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (image == null) return;
      controller.image.value = image.path;
      Get.back();
    } catch (e) {
      devlogError("error on pick file : $e");
      ShowToastDialog.showToast("Failed to pick image".tr);
    }
  }
}

// import 'dart:convert';
// import 'dart:io';
//
// import 'package:zocar/constant/constant.dart';
// import 'package:zocar/constant/show_toast_dialog.dart';
// import 'package:zocar/controller/add_photo_controller.dart';
// import 'package:zocar/model/user_model.dart';
// import 'package:zocar/page/auth_screens/login_screen.dart';
// import 'package:zocar/page/main_page.dart';
// import 'package:zocar/themes/button_them.dart';
// import 'package:zocar/themes/constant_colors.dart';
// import 'package:zocar/themes/responsive.dart';
// import 'package:zocar/utils/Preferences.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
//
// class AddProfilePhotoScreen extends StatelessWidget {
//   AddProfilePhotoScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetX<AddPhotoController>(
//       init: AddPhotoController(),
//       builder: (controller) {
//         return Scaffold(
//           backgroundColor: ConstantColors.background,
//           appBar: AppBar(
//             elevation: 0,
//             backgroundColor: ConstantColors.background,
//             leading: InkWell(
//               onTap: () {
//                 Get.offAll(() => LoginScreen());
//               },
//               child: const Icon(
//                 Icons.arrow_back_ios,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//           body: WillPopScope(
//             onWillPop: () async {
//               Get.offAll(
//                 () => LoginScreen(),
//               );
//               return true;
//             },
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 22.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(
//                     height: Responsive.height(8, context),
//                   ),
//                   Text(
//                     "select_profile_photo".tr,
//                     style: const TextStyle(
//                         color: Colors.black87,
//                         fontWeight: FontWeight.w600,
//                         letterSpacing: 1.2,
//                         fontSize: 22),
//                   ),
//                   const SizedBox(height: 15),
//                   Text(
//                     "profile_message".tr,
//                     style: const TextStyle(
//                         color: Colors.black54,
//                         fontWeight: FontWeight.w600,
//                         height: 2,
//                         letterSpacing: 1),
//                   ),
//                   SizedBox(
//                     height: Responsive.height(5, context),
//                   ),
//                   controller.image.isNotEmpty
//                       ? Center(
//                           child: ClipOval(
//                             child: Padding(
//                               padding: const EdgeInsets.all(4.0),
//                               child: ClipOval(
//                                   child: Image.file(
//                                 File(controller.image.value),
//                                 height: 190,
//                                 width: 190,
//                                 fit: BoxFit.cover,
//                               )),
//                             ),
//                           ),
//                         )
//                       : const SizedBox(),
//                 ],
//               ),
//             ),
//           ),
//           bottomNavigationBar: Container(
//             height: 80,
//             width: Responsive.width(100, context),
//             color: Colors.white,
//             child: Center(
//               child: ButtonThem.buildButton(
//                 context,
//                 title: 'select_photo'.tr,
//                 btnHeight: 45,
//                 btnWidthRatio: 0.8,
//                 btnColor: ConstantColors.primary,
//                 txtColor: Colors.white,
//                 onPress: () => buildBottomSheet(context, controller),
//               ),
//             ),
//           ),
//           floatingActionButton: FloatingActionButton(
//             backgroundColor: ConstantColors.yellow,
//             child: const Icon(
//               Icons.navigate_next,
//               size: 28,
//               color: Colors.black,
//             ),
//             onPressed: () {
//               if (controller.image.isNotEmpty) {
//                 controller.uploadPhoto().then((value) {
//                   if (value != null) {
//                     if (value["success"] == "Success") {
//                       UserModel userModel = Constant.getUserData();
//                       userModel.data!.photoPath = value['data']['photo_path'];
//                       Preferences.setString(
//                           Preferences.user, jsonEncode(userModel.toJson()));
//                       Preferences.setBoolean(Preferences.isLogin, true);
//                       Get.offAll(MainPage());
//                     } else {
//                       ShowToastDialog.showToast(value['error']);
//                     }
//                   }
//                 });
//               } else {
//                 ShowToastDialog.showToast("Please Choose Image".tr);
//               }
//             },
//           ),
//           floatingActionButtonLocation:
//               FloatingActionButtonLocation.centerFloat,
//         );
//       },
//     );
//   }
//
//   buildBottomSheet(BuildContext context, AddPhotoController controller) {
//     return showModalBottomSheet(
//         context: context,
//         builder: (context) {
//           return StatefulBuilder(builder: (context, setState) {
//             return Container(
//               height: Responsive.height(22, context),
//               color: Colors.white,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(top: 15),
//                     child: Text(
//                       "please_select".tr,
//                       style: TextStyle(
//                         color: const Color(0XFF333333).withOpacity(0.8),
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(18.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             IconButton(
//                                 onPressed: () => pickFile(controller,
//                                     source: ImageSource.camera),
//                                 icon: const Icon(
//                                   Icons.camera_alt,
//                                   size: 32,
//                                 )),
//                             Padding(
//                               padding: const EdgeInsets.only(top: 3),
//                               child: Text("camera".tr),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(18.0),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             IconButton(
//                                 onPressed: () => pickFile(controller,
//                                     source: ImageSource.gallery),
//                                 icon: const Icon(
//                                   Icons.photo_library_sharp,
//                                   size: 32,
//                                 )),
//                             Padding(
//                               padding: const EdgeInsets.only(top: 3),
//                               child: Text("gallery".tr),
//                             ),
//                           ],
//                         ),
//                       )
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           });
//         });
//   }
//
//   final ImagePicker _imagePicker = ImagePicker();
//
//   Future pickFile(AddPhotoController controller,
//       {required ImageSource source}) async {
//     try {
//       XFile? image = await _imagePicker.pickImage(source: source , maxHeight: 250 , maxWidth: 250);
//       if (image == null) return;
//       controller.image.value = image.path;
//       Get.back();
//     } on PlatformException catch (e) {
//       ShowToastDialog.showToast("Failed to Pick.tr" ": \n $e");
//     }
//   }
// }
