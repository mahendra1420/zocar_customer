// ignore_for_file: must_be_immutable

import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/controller/forgot_password_controller.dart';
import 'package:zocar/helpers/app_bg.dart';
import 'package:zocar/helpers/size_ext.dart';
import 'package:zocar/page/auth_screens/login_screen.dart';
import 'package:zocar/themes/constant_colors.dart';
import 'package:zocar/themes/text_field_them.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

class ForgotPasswordOtpScreen extends StatelessWidget {
  String? email;

  ForgotPasswordOtpScreen({super.key, required this.email});

  final controller = Get.put(ForgotPasswordController());
  static final _formKey = GlobalKey<FormState>();

  final textEditingController = TextEditingController();
  final _passwordController = TextEditingController();
  final _conformPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppBg(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 5.h),
                          // Lock Icon
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
                          //     Icons.lock_open_rounded,
                          //     size: 50,
                          //     color: ConstantColors.primary,
                          //   ),
                          // ),
                          // SizedBox(height: 1.h),
                          // Title
                          Text(
                            "Reset Password".tr,
                            style: const TextStyle(
                              fontSize: 28,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          // Subtitle with email
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
                                  TextSpan(text: "Enter the 4-digit code sent to\n".tr),
                                  TextSpan(
                                    text: email ?? "",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: ConstantColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 3.h),
                          // Form Container
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // OTP Section Label
                                Center(
                                  child: Text(
                                    'Verification Code'.tr,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // OTP Input
                                Center(
                                  child: Pinput(
                                    controller: textEditingController,
                                    length: 4,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.next,
                                    defaultPinTheme: PinTheme(
                                      height: 60,
                                      width: 60,
                                      textStyle: const TextStyle(
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
                                      width: 60,
                                      textStyle: const TextStyle(
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
                                      width: 60,
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
                                  ),
                                ),
                                const SizedBox(height: 28),
                                // New Password Section
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8, left: 4),
                                  child: Text(
                                    'New Password'.tr,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                                TextFieldThem.boxBuildTextField(
                                  hintText: 'Enter new password'.tr,
                                  controller: _passwordController,
                                  textInputType: TextInputType.text,
                                  obscureText: false,
                                  contentPadding: EdgeInsets.zero,
                                  validators: (String? value) {
                                    if (value!.length >= 6) {
                                      return null;
                                    } else {
                                      return 'Password must be at least 6 characters'.tr;
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),
                                // Confirm Password
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8, left: 4),
                                  child: Text(
                                    'Confirm Password'.tr,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                                TextFieldThem.boxBuildTextField(
                                  hintText: 'Re-enter password'.tr,
                                  controller: _conformPasswordController,
                                  textInputType: TextInputType.text,
                                  obscureText: false,
                                  contentPadding: EdgeInsets.zero,
                                  validators: (String? value) {
                                    if (_passwordController.text != value) {
                                      return 'Passwords do not match'.tr;
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                                const SizedBox(height: 28),
                                // Reset Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      if (_formKey.currentState!.validate()) {
                                        if (textEditingController.text.length != 4) {
                                          ShowToastDialog.showToast("Please enter 4-digit code".tr);
                                          return;
                                        }
                                        ShowToastDialog.showLoader("Resetting password".tr);
                                        Map<String, String> bodyParams = {
                                          'email': email.toString(),
                                          'otp': textEditingController.text.trim(),
                                          'new_password': _passwordController.text.trim(),
                                          'confirm_password': _passwordController.text.trim(),
                                          'user_cat': "user_app",
                                        };
                                        controller.resetPassword(bodyParams).then((value) {
                                          ShowToastDialog.closeLoader();
                                          if (value != null) {
                                            if (value == true) {
                                              ShowToastDialog.showToast("Password changed successfully!".tr);
                                              Get.offAll(
                                                LoginScreen(),
                                                duration: const Duration(milliseconds: 300),
                                                transition: Transition.rightToLeft,
                                              );
                                            } else {
                                              ShowToastDialog.showToast("Invalid code. Please try again.".tr);
                                            }
                                          }
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ConstantColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                      shadowColor: ConstantColors.primary.withOpacity(0.3),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.lock_reset_rounded,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Reset Password'.tr.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 3.h),
                          // Resend Code
                          GestureDetector(
                            onTap: () {
                              ShowToastDialog.showLoader("Resending code".tr);
                              Map<String, String> bodyParams = {
                                'email': email.toString(),
                                'user_cat': "user_app",
                              };
                              controller.sendEmail(bodyParams).then((value) {
                                ShowToastDialog.closeLoader();
                                if (value == true) {
                                  ShowToastDialog.showToast("Verification code sent".tr);
                                } else {
                                  ShowToastDialog.showToast("Failed to send code".tr);
                                }
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
                          SizedBox(height: 2.h),
                        ],
                      ),
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
// import 'package:zocar/constant/show_toast_dialog.dart';
// import 'package:zocar/controller/forgot_password_controller.dart';
// import 'package:zocar/page/auth_screens/login_screen.dart';
// import 'package:zocar/themes/button_them.dart';
// import 'package:zocar/themes/constant_colors.dart';
// import 'package:zocar/themes/text_field_them.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:pinput/pinput.dart';
//
// class ForgotPasswordOtpScreen extends StatelessWidget {
//   String? email;
//
//   ForgotPasswordOtpScreen({super.key, required this.email});
//
//   final controller = Get.put(ForgotPasswordController());
//   static final _formKey = GlobalKey<FormState>();
//
//   final textEditingController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _conformPasswordController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: Container(
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
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
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
//                           padding: const EdgeInsets.only(
//                               top: 30, right: 50, left: 50),
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
//                             length: 4,
//                           ),
//
//                           // PinCodeTextField(
//                           //   length: 4,
//                           //   appContext: context,
//                           //   keyboardType: TextInputType.phone,
//                           //   textInputAction: TextInputAction.done,
//                           // pinTheme: PinTheme(
//                           //     fieldHeight: 50,
//                           //     fieldWidth: 50,
//                           //     activeColor:
//                           //         ConstantColors.textFieldBoarderColor,
//                           //     selectedColor:
//                           //         ConstantColors.textFieldBoarderColor,
//                           //     inactiveColor:
//                           //         ConstantColors.textFieldBoarderColor,
//                           //     activeFillColor: Colors.white,
//                           //     inactiveFillColor: Colors.white,
//                           //     selectedFillColor: Colors.white,
//                           //     shape: PinCodeFieldShape.box,
//                           //     borderRadius: BorderRadius.circular(10),
//                           //     borderWidth: 0.7),
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
//                           padding: const EdgeInsets.only(top: 50),
//                           child: TextFieldThem.boxBuildTextField(
//                             hintText: 'password'.tr,
//                             controller: _passwordController,
//                             textInputType: TextInputType.text,
//                             obscureText: false,
//                             contentPadding: EdgeInsets.zero,
//                             validators: (String? value) {
//                               if (value!.length >= 6) {
//                                 return null;
//                               } else {
//                                 return 'Password required at least 6 characters'
//                                     .tr;
//                               }
//                             },
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(top: 20),
//                           child: TextFieldThem.boxBuildTextField(
//                             hintText: 'confirm_password'.tr,
//                             controller: _conformPasswordController,
//                             textInputType: TextInputType.text,
//                             obscureText: false,
//                             contentPadding: EdgeInsets.zero,
//                             validators: (String? value) {
//                               if (_passwordController.text != value) {
//                                 return 'Confirm password is invalid'.tr;
//                               } else {
//                                 return null;
//                               }
//                             },
//                           ),
//                         ),
//                         Padding(
//                             padding: const EdgeInsets.only(top: 40),
//                             child: ButtonThem.buildButton(
//                               context,
//                               title: 'done'.tr,
//                               btnHeight: 50,
//                               btnColor: ConstantColors.primary,
//                               txtColor: Colors.white,
//                               onPress: () {
//                                 FocusScope.of(context).unfocus();
//                                 if (_formKey.currentState!.validate()) {
//                                   Map<String, String> bodyParams = {
//                                     'email': email.toString(),
//                                     'otp': textEditingController.text.trim(),
//                                     'new_password':
//                                         _passwordController.text.trim(),
//                                     'confirm_password':
//                                         _passwordController.text.trim(),
//                                     'user_cat': "user_app",
//                                   };
//                                   controller
//                                       .resetPassword(bodyParams)
//                                       .then((value) {
//                                     if (value != null) {
//                                       if (value == true) {
//                                         Get.offAll(LoginScreen(),
//                                             duration: const Duration(
//                                                 milliseconds:
//                                                     400), //duration of transitions, default 1 sec
//                                             transition: Transition.rightToLeft);
//                                         ShowToastDialog.showToast(
//                                             "Password change successfully!".tr);
//                                       } else {
//                                         ShowToastDialog.showToast(
//                                             "Please try again later".tr);
//                                       }
//                                     }
//                                   });
//                                 }
//                               },
//                             )),
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
