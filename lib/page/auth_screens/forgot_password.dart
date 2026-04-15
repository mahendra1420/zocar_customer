import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/controller/forgot_password_controller.dart';
import 'package:zocar/page/auth_screens/forgot_password_otp_screen.dart';
import 'package:zocar/page/auth_screens/zocar_logo_widget.dart';
import 'package:zocar/themes/constant_colors.dart';
import 'package:zocar/themes/text_field_them.dart';

import '../../constant/constant.dart';
import '../../helpers/app_bg.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final controller = Get.put(ForgotPasswordController());

  static final _formKey = GlobalKey<FormState>();
  static final _emailTextEditController = TextEditingController();

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
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ZocarLogoWidget(),
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
                        //     Icons.lock_reset_rounded,
                        //     size: 50,
                        //     color: ConstantColors.primary,
                        //   ),
                        // ),
                        const SizedBox(height: 32),
                        // Title
                        Text(
                          "Forgot Password?".tr,
                          style: const TextStyle(
                            fontSize: 28,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Description
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "Don't worry! Enter your email address and we'll send you a verification code to reset your password."
                                .tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        // Form Container
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
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Email Field Label
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8, left: 4),
                                  child: Text(
                                    'Email Address'.tr,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                                // Email Field
                                TextFieldThem.boxBuildTextField(
                                  hintText: 'Enter your email'.tr,
                                  controller: _emailTextEditController,
                                  textInputType: TextInputType.emailAddress,
                                  capitalization: TextCapitalization.none,
                                  contentPadding: EdgeInsets.zero,
                                  validators: (String? value) {
                                    if (value!.isEmpty) {
                                      return 'Email is required'.tr;
                                    }
                                    if (!GetUtils.isEmail(value)) {
                                      return 'Enter a valid email'.tr;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 28),
                                // Send Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      if (_formKey.currentState!.validate()) {
                                        Map<String, String> bodyParams = {
                                          'email': _emailTextEditController.text.trim(),
                                          'user_cat': "user_app",
                                        };
                                        ShowToastDialog.showLoader("Sending verification code".tr);
                                        controller.sendEmail(bodyParams).then((value) {
                                          ShowToastDialog.closeLoader();
                                          if (value != null) {
                                            if (value == true) {
                                              Get.to(
                                                ForgotPasswordOtpScreen(
                                                  email: _emailTextEditController.text.trim(),
                                                ),
                                                duration: const Duration(milliseconds: 300),
                                                transition: Transition.rightToLeft,
                                              );
                                            } else {
                                              ShowToastDialog.showToast(
                                                "Unable to send verification code. Please try again.".tr,
                                              );
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
                                          Icons.mail_outline_rounded,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Send Verification Code'.tr.toUpperCase(),
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
                        ),
                        const SizedBox(height: 32),
                        // Back to Login
                        GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_back_rounded,
                                size: 18,
                                color: ConstantColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Back to Login'.tr,
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

// import 'package:zocar/constant/show_toast_dialog.dart';
// import 'package:zocar/controller/forgot_password_controller.dart';
// import 'package:zocar/page/auth_screens/forgot_password_otp_screen.dart';
// import 'package:zocar/themes/button_them.dart';
// import 'package:zocar/themes/constant_colors.dart';
// import 'package:zocar/themes/text_field_them.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class ForgotPasswordScreen extends StatelessWidget {
//   ForgotPasswordScreen({super.key});
//
//   final controller = Get.put(ForgotPasswordController());
//
//   static final _formKey = GlobalKey<FormState>();
//   static final _emailTextEditController = TextEditingController();
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
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Forgot Password".tr,
//                         style: const TextStyle(
//                             letterSpacing: 0.60,
//                             fontSize: 22,
//                             color: Colors.black,
//                             fontWeight: FontWeight.w600),
//                       ),
//                       SizedBox(
//                           width: 80,
//                           child: Divider(
//                             color: ConstantColors.yellow1,
//                             thickness: 3,
//                           )),
//                       Padding(
//                         padding: const EdgeInsets.only(top: 20),
//                         child: Text(
//                           "Enter the email address we will send an OPT to create new password."
//                               .tr,
//                           textAlign: TextAlign.start,
//                           style: TextStyle(
//                               letterSpacing: 1.0,
//                               color: ConstantColors.hintTextColor,
//                               fontWeight: FontWeight.w600),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(top: 30),
//                         child: Form(
//                           key: _formKey,
//                           child: TextFieldThem.boxBuildTextField(
//                             hintText: 'email'.tr,
//                             controller: _emailTextEditController,
//                             textInputType: TextInputType.emailAddress,
//                             contentPadding: EdgeInsets.zero,
//                             validators: (String? value) {
//                               if (value!.isNotEmpty) {
//                                 return null;
//                               } else {
//                                 return 'required'.tr;
//                               }
//                             },
//                           ),
//                         ),
//                       ),
//                       Padding(
//                           padding: const EdgeInsets.only(top: 40),
//                           child: ButtonThem.buildButton(
//                             context,
//                             title: 'send'.tr,
//                             btnHeight: 50,
//                             btnColor: ConstantColors.primary,
//                             txtColor: Colors.white,
//                             onPress: () {
//                               FocusScope.of(context).unfocus();
//                               if (_formKey.currentState!.validate()) {
//                                 Map<String, String> bodyParams = {
//                                   'email': _emailTextEditController.text.trim(),
//                                   'user_cat': "user_app",
//                                 };
//                                 controller.sendEmail(bodyParams).then((value) {
//                                   if (value != null) {
//                                     if (value == true) {
//                                       Get.to(
//                                           ForgotPasswordOtpScreen(
//                                               email: _emailTextEditController
//                                                   .text
//                                                   .trim()),
//                                           duration:
//                                               const Duration(milliseconds: 400),
//                                           //duration of transitions, default 1 sec
//                                           transition: Transition.rightToLeft);
//                                     } else {
//                                       ShowToastDialog.showToast(
//                                           "Please try again later".tr);
//                                     }
//                                   }
//                                 });
//                               }
//                             },
//                           )),
//                     ],
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
