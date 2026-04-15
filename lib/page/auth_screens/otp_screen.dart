// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/controller/phone_number_controller.dart';
import 'package:zocar/helpers/app_bg.dart';
import 'package:zocar/helpers/unfocusall.dart';
import 'package:zocar/page/auth_screens/add_profile_photo_screen.dart';
import 'package:zocar/page/auth_screens/zocar_logo_widget.dart';
import 'package:zocar/page/main_page.dart';
import 'package:zocar/service/api.dart';
import 'package:zocar/utils/preferences.dart';

import '../../themes/constant_colors.dart';
import 'signup_screen.dart';

class OtpScreen extends StatelessWidget {
  String? phoneNumber;
  String? verificationId;

  OtpScreen({super.key, required this.phoneNumber, required this.verificationId});

  final controller = Get.put(PhoneNumberController());
  final textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppBg(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ZocarLogoWidget(),
                        // Shield Check Icon
                        // Container(
                        //   padding: const EdgeInsets.all(20),
                        //   decoration: BoxDecoration(
                        //     color: Colors.white.withOpacity(0.95),
                        //     shape: BoxShape.circle,
                        //     boxShadow: [
                        //       BoxShadow(
                        //         color: ConstantColors.primary.withOpacity(0.3),
                        //         blurRadius: 25,
                        //         offset: const Offset(0, 10),
                        //       ),
                        //     ],
                        //   ),
                        //   child: Icon(
                        //     Icons.verified_user_rounded,
                        //     size: 50,
                        //     color: ConstantColors.primary,
                        //   ),
                        // ),
                        const SizedBox(height: 32),
                        // Title
                        Text(
                          "Verify Your Number".tr,
                          style: const TextStyle(
                            fontSize: 28,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Subtitle with phone number
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                              children: [
                                TextSpan(text: "Enter the 6-digit code sent to\n".tr),
                                TextSpan(
                                  text: phoneNumber ?? "",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ConstantColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        // OTP Input Container
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Pinput(
                                controller: textEditingController,
                                length: 6,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                defaultPinTheme: PinTheme(
                                  height: 60,
                                  width: 50,
                                  textStyle: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey.shade100,
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                focusedPinTheme: PinTheme(
                                  height: 60,
                                  width: 50,
                                  textStyle: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                    border: Border.all(
                                      color: ConstantColors.primary,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: ConstantColors.primary.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                submittedPinTheme: PinTheme(
                                  height: 60,
                                  width: 50,
                                  textStyle: TextStyle(
                                    fontSize: 20,
                                    color: ConstantColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                    border: Border.all(
                                      color: ConstantColors.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                errorPinTheme: PinTheme(
                                  height: 60,
                                  width: 50,
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.red.shade400,
                                    border: Border.all(
                                      color: Colors.red.shade700,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onCompleted: (pin) {
                                  // Auto-verify when complete
                                },
                              ),
                              const SizedBox(height: 28),
                              // Verify Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    unfocusAll();

                                    if (textEditingController.text.length == 6) {
                                      ShowToastDialog.showLoader("Verifying code".tr);

                                      await controller.sendVerifyCode(textEditingController.text).then((value) async {
                                        Map<String, String> bodyParams = {
                                          'phone': phoneNumber.toString(),
                                          'user_cat': "customer",
                                        };

                                        if (value == true) {
                                          await controller.phoneNumberIsExit(bodyParams).then((value) async {
                                            if (value == true) {
                                              Map<String, String> bodyParams = {
                                                'phone': phoneNumber.toString(),
                                                'user_cat': "customer",
                                              };
                                              await controller.getDataByPhoneNumber(bodyParams).then((value) {
                                                if (value != null) {
                                                  if (value.success == "success") {
                                                    ShowToastDialog.closeLoader();

                                                    Preferences.setInt(Preferences.userId, int.parse(value.data!.id.toString()));
                                                    Preferences.setString(Preferences.user, jsonEncode(value));
                                                    Preferences.setString(Preferences.accesstoken, value.data!.accesstoken.toString());
                                                    Preferences.setString(Preferences.admincommission, value.data!.adminCommission.toString());
                                                    API.header['accesstoken'] = Preferences.getString(Preferences.accesstoken);

                                                    if (value.data!.photo == null || value.data!.photoPath.toString().isEmpty) {
                                                      Get.to(() => AddProfilePhotoScreen());
                                                    } else {
                                                      Preferences.setBoolean(Preferences.isLogin, true);
                                                      Get.offAll(MainPage());
                                                    }
                                                  } else {
                                                    ShowToastDialog.showToast(value.error);
                                                  }
                                                }
                                              });
                                            } else if (value == false) {
                                              ShowToastDialog.closeLoader();
                                              Get.off(SignupScreen(
                                                phoneNumber: phoneNumber.toString(),
                                              ));
                                            }
                                          });
                                        }
                                      }).catchError((error) {
                                        ShowToastDialog.closeLoader();
                                        ShowToastDialog.showToast("Invalid verification code".tr);
                                      });
                                    } else {
                                      ShowToastDialog.showToast("Please enter 6-digit code".tr);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ConstantColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'Verify & Continue'.tr.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Resend Code
                        GestureDetector(
                          onTap: () {
                            // Resend OTP logic
                            ShowToastDialog.showLoader("Resending code".tr);
                            controller.sendCode(phoneNumber ?? "").then((_) {
                              ShowToastDialog.closeLoader();
                              ShowToastDialog.showToast("Verification code sent".tr);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.refresh_rounded,
                                  size: 18,
                                  color: ConstantColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Didn't receive code? Resend".tr,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: ConstantColors.primary,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              // Back Button
              Positioned(
                top: 16,
                left: 16,
                child: GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white.withOpacity(0.95),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.black87,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// // ignore_for_file: must_be_immutable
//
// import 'dart:convert';
// import 'package:zocar/constant/show_toast_dialog.dart';
// import 'package:zocar/controller/phone_number_controller.dart';
// import 'package:zocar/page/auth_screens/add_profile_photo_screen.dart';
// import 'package:zocar/page/main_page.dart';
// import 'package:zocar/service/api.dart';
// import 'package:zocar/themes/button_them.dart';
// import 'package:zocar/utils/Preferences.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:pinput/pinput.dart';
//
// import '../../themes/constant_colors.dart';
// import 'signup_screen.dart';
//
// class OtpScreen extends StatelessWidget {
//   String? phoneNumber;
//   String? verificationId;
//
//   OtpScreen(
//       {super.key, required this.phoneNumber, required this.verificationId});
//
//   final controller = Get.put(PhoneNumberController());
//   final textEditingController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ConstantColors.background,
//       body: SafeArea(
//         child: Container(
//           height: Get.height,
//           decoration: const BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage("assets/images/login_bg.png"),
//               fit: BoxFit.cover,
//             ),
//           ),
//           child: Stack(
//             children: [
//               Center(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 22),
//                   child: SingleChildScrollView(
//                     child: Column(
//                       children: [
//                         Text(
//                           "Enter OTP".tr,
//                           style: const TextStyle(
//                               letterSpacing: 0.60,
//                               fontSize: 22,
//                               color: Colors.black,
//                               fontWeight: FontWeight.w600),
//                         ),
//                         SizedBox(
//                             width: 80,
//                             child: Divider(
//                               color: ConstantColors.yellow1,
//                               thickness: 3,
//                             )),
//                         Padding(
//                           padding: const EdgeInsets.only(top: 50),
//                           child: Pinput(
//                             controller: textEditingController,
//                             defaultPinTheme: PinTheme(
//                               height: 50,
//                               width: 50,
//                               textStyle: const TextStyle(
//                                   letterSpacing: 0.60,
//                                   fontSize: 16,
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.w600),
//                               // margin: EdgeInsets.all(10),
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(10),
//                                 shape: BoxShape.rectangle,
//                                 color: Colors.white,
//                                 border: Border.all(
//                                     color: ConstantColors.textFieldBoarderColor,
//                                     width: 0.7),
//                               ),
//                             ),
//                             keyboardType: TextInputType.phone,
//                             textInputAction: TextInputAction.done,
//                             length: 6,
//                           ),
//
//                           // PinCodeTextField(
//                           //   length: 6,
//                           //   appContext: context,
//                           //   keyboardType: TextInputType.phone,
//                           //   textInputAction: TextInputAction.done,
//                           //   pinTheme: PinTheme(
//                           //     fieldHeight: 50,
//                           //     fieldWidth: 50,
//                           //     activeColor: ConstantColors.textFieldBoarderColor,
//                           //     selectedColor:
//                           //         ConstantColors.textFieldBoarderColor,
//                           //     inactiveColor:
//                           //         ConstantColors.textFieldBoarderColor,
//                           //     activeFillColor: Colors.white,
//                           //     inactiveFillColor: Colors.white,
//                           //     selectedFillColor: Colors.white,
//                           //     shape: PinCodeFieldShape.box,
//                           //     borderRadius: BorderRadius.circular(10),
//                           //   ),
//                           //   enableActiveFill: true,
//                           //   cursorColor: ConstantColors.primary,
//                           //   controller: textEditingController,
//                           //   onCompleted: (v) async {},
//                           //   onChanged: (value) {
//                           //     log(value);
//                           //   },
//                           // ),
//                         ),
//                         Padding(
//                             padding: const EdgeInsets.only(top: 40),
//                             child: ButtonThem.buildButton(
//                               context,
//                               title: 'done'.tr,
//                               btnHeight: 50,
//                               btnColor: ConstantColors.primary,
//                               txtColor: Colors.white,
//                               onPress: () async {
//                                 FocusScope.of(context).unfocus();
//
//                                 if (textEditingController.text.length == 6) {
//                                   ShowToastDialog.showLoader("Verify OTP".tr);
//                                   // PhoneAuthCredential credential =
//                                   //     PhoneAuthProvider.credential(
//                                   //         verificationId:
//                                   //             verificationId.toString(),
//                                   //         smsCode: textEditingController.text);
//                                   // await FirebaseAuth.instance
//                                   //     .signInWithCredential(credential)
//
//                                 await controller.sendVerifyCode(textEditingController.text)
//                                       .then((value) async {
//                                     Map<String, String> bodyParams = {
//                                       'phone': phoneNumber.toString(),
//                                       'user_cat': "customer",
//                                     };
//
//                                     if(value == true){
//                                     await controller
//                                         .phoneNumberIsExit(bodyParams)
//                                         .then((value) async {
//                                       if (value == true) {
//
//                                         Map<String, String> bodyParams = {
//                                           'phone': phoneNumber.toString(),
//                                           'user_cat': "customer",
//                                         };
//                                         await controller
//                                             .getDataByPhoneNumber(bodyParams)
//                                             .then((value) {
//                                           if (value != null) {
//                                             if (value.success == "success") {
//                                               ShowToastDialog.closeLoader();
//
//                                               Preferences.setInt(
//                                                   Preferences.userId,
//                                                   int.parse(value.data!.id
//                                                       .toString()));
//                                               Preferences.setString(
//                                                   Preferences.user,
//                                                   jsonEncode(value));
//                                               Preferences.setString(
//                                                   Preferences.accesstoken,
//                                                   value.data!.accesstoken
//                                                       .toString());
//                                               Preferences.setString(
//                                                   Preferences.admincommission,
//                                                   value.data!.adminCommission
//                                                       .toString());
//                                               API.header['accesstoken'] =
//                                                   Preferences.getString(
//                                                       Preferences.accesstoken);
//
//                                               if (value.data!.photo == null ||
//                                                   value.data!.photoPath
//                                                       .toString()
//                                                       .isEmpty) {
//                                                 Get.to(() =>
//                                                     AddProfilePhotoScreen());
//                                               } else {
//                                                 Preferences.setBoolean(
//                                                     Preferences.isLogin, true);
//                                                 Get.offAll(MainPage());
//                                               }
//                                             } else {
//                                               ShowToastDialog.showToast(
//                                                   value.error);
//                                             }
//                                           }
//                                         });
//                                       } else if (value == false) {
//                                         ShowToastDialog.closeLoader();
//                                         Get.off(SignupScreen(
//                                           phoneNumber: phoneNumber.toString(),
//                                         ));
//                                       }
//                                     });}
//                                   }).catchError((error) {
//                                     ShowToastDialog.closeLoader();
//                                     ShowToastDialog.showToast(
//                                         "Code is Invalid".tr);
//                                   });
//                                 } else {
//                                   ShowToastDialog.showToast(
//                                       "Please Enter OTP".tr);
//                                 }
//                               },
//                             ))
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: GestureDetector(
//                   onTap: () {
//                     Get.back();
//                   },
//                   child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(30),
//                         color: Colors.white,
//                         boxShadow: <BoxShadow>[
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.3),
//                             blurRadius: 10,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: const Padding(
//                         padding: EdgeInsets.all(8),
//                         child: Icon(
//                           Icons.arrow_back_ios_rounded,
//                           color: Colors.black,
//                         ),
//                       )),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
