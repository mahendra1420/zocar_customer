// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/controller/sign_up_controller.dart';
import 'package:zocar/helpers/app_bg.dart';
import 'package:zocar/page/auth_screens/add_profile_photo_screen.dart';
import 'package:zocar/page/auth_screens/login_screen.dart';
import 'package:zocar/themes/constant_colors.dart';
import 'package:zocar/themes/text_field_them.dart';
import 'package:zocar/utils/preferences.dart';

class SignupScreen extends StatelessWidget {
  String? phoneNumber;

  SignupScreen({super.key, required this.phoneNumber});

  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  var _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _conformPasswordController = TextEditingController();
  final _referralCodeController = TextEditingController();

  final controller = Get.put(SignUpController());

  @override
  Widget build(BuildContext context) {
    _phoneController = TextEditingController(text: phoneNumber);
    return AppBg(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          // User Icon
                          // Container(
                          //   padding: const EdgeInsets.all(18),
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
                          //     Icons.person_add_rounded,
                          //     size: 40,
                          //     color: ConstantColors.primary,
                          //   ),
                          // ),
                          // const SizedBox(height: 24),
                          // Title
                          Text(
                            "Create Account".tr,
                            style: const TextStyle(
                              fontSize: 28,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Sign up to get started".tr,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Form Container
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 22),
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
                                // Name Fields Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFieldThem.boxBuildTextField(
                                        hintText: 'First Name'.tr,
                                        controller: _firstNameController,
                                        textInputType: TextInputType.text,
                                        maxLength: 22,
                                        contentPadding: EdgeInsets.zero,
                                        validators: (String? value) {
                                          if (value!.isNotEmpty) {
                                            return null;
                                          } else {
                                            return 'Required'.tr;
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFieldThem.boxBuildTextField(
                                        hintText: 'Last Name'.tr,
                                        controller: _lastNameController,
                                        textInputType: TextInputType.text,
                                        maxLength: 22,
                                        contentPadding: EdgeInsets.zero,
                                        validators: (String? value) {
                                          if (value!.isNotEmpty) {
                                            return null;
                                          } else {
                                            return 'Required'.tr;
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Phone Field (Disabled)
                                TextFieldThem.boxBuildTextField(
                                  hintText: 'phone'.tr,
                                  controller: _phoneController,
                                  textInputType: TextInputType.number,
                                  maxLength: 13,
                                  enabled: false,
                                  contentPadding: EdgeInsets.zero,
                                  validators: (String? value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return 'Required'.tr;
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),
                                // Email Field
                                TextFieldThem.boxBuildTextField(
                                  hintText: 'Email Address'.tr,
                                  controller: _emailController,
                                  textInputType: TextInputType.emailAddress,
                                  contentPadding: EdgeInsets.zero,
                                  validators: (String? value) {
                                    bool emailValid = RegExp(
                                        r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
                                        .hasMatch(value!);
                                    if (!emailValid) {
                                      return 'Invalid email address'.tr;
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),
                                // Password Field
                                TextFieldThem.boxBuildTextField(
                                  hintText: 'Password'.tr,
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
                                // Confirm Password Field
                                TextFieldThem.boxBuildTextField(
                                  hintText: 'Confirm Password'.tr,
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
                                const SizedBox(height: 16),
                                // Referral Code Field
                                TextFieldThem.boxBuildTextField(
                                  hintText: 'Referral Code (Optional)'.tr,
                                  controller: _referralCodeController,
                                  textInputType: TextInputType.text,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                const SizedBox(height: 28),
                                // Sign Up Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      FocusScope.of(context).unfocus();
                                      if (_formKey.currentState!.validate()) {
                                        ShowToastDialog.showLoader("Creating account".tr);
                                        Map<String, String> bodyParams = {
                                          'firstname': _firstNameController.text.trim().toString(),
                                          'lastname': _lastNameController.text.trim().toString(),
                                          'phone': _phoneController.text.trim(),
                                          'email': _emailController.text.trim(),
                                          'password': _passwordController.text,
                                          'referral_code': _referralCodeController.text.toString(),
                                          'login_type': 'phone',
                                          'tonotify': 'yes',
                                          'account_type': 'customer',
                                        };
                                        await controller.signUp(bodyParams).then((value) {
                                          ShowToastDialog.closeLoader();
                                          if (value != null) {
                                            if (value.success == "success") {
                                              Preferences.setInt(
                                                  Preferences.userId,
                                                  int.parse(value.data!.id.toString()));
                                              Preferences.setString(
                                                  Preferences.user, jsonEncode(value));
                                              Get.to(
                                                AddProfilePhotoScreen(),
                                                duration: const Duration(milliseconds: 300),
                                                transition: Transition.rightToLeft,
                                              );
                                            } else {
                                              ShowToastDialog.showToast(value.error);
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
                                        Text(
                                          'Create Account'.tr.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 20,
                                        ),
                                      ],
                                    ),
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
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Already have an account? '.tr,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: 'LOGIN'.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ConstantColors.primary,
                      fontSize: 15,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Get.offAll( () =>
                          LoginScreen(),
                          duration: const Duration(milliseconds: 300),
                          transition: Transition.fade,
                        );
                      },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// // ignore_for_file: must_be_immutable
//
// import 'dart:convert';
//
// import 'package:zocar/constant/show_toast_dialog.dart';
// import 'package:zocar/controller/sign_up_controller.dart';
// import 'package:zocar/page/auth_screens/add_profile_photo_screen.dart';
// import 'package:zocar/page/auth_screens/login_screen.dart';
// import 'package:zocar/themes/button_them.dart';
// import 'package:zocar/themes/constant_colors.dart';
// import 'package:zocar/themes/text_field_them.dart';
// import 'package:zocar/utils/Preferences.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class SignupScreen extends StatelessWidget {
//   String? phoneNumber;
//
//   SignupScreen({super.key, required this.phoneNumber});
//
//   static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final _firstNameController = TextEditingController();
//   final _lastNameController = TextEditingController();
//   var _phoneController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _conformPasswordController = TextEditingController();
//   final _referralCodeController = TextEditingController();
//
//   final controller = Get.put(SignUpController());
//
//   @override
//   Widget build(BuildContext context) {
//     _phoneController = TextEditingController(text: phoneNumber);
//     return Scaffold(
//       backgroundColor: ConstantColors.background,
//       body: SafeArea(
//         child: Container(
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
//                     child: SingleChildScrollView(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Text(
//                             "Sign up".tr.toUpperCase(),
//                             style: const TextStyle(
//                                 letterSpacing: 0.60,
//                                 fontSize: 22,
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.w600),
//                           ),
//                           SizedBox(
//                               width: 80,
//                               child: Divider(
//                                 color: ConstantColors.yellow1,
//                                 thickness: 3,
//                               )),
//                           const SizedBox(
//                             height: 30,
//                           ),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: TextFieldThem.boxBuildTextField(
//                                   hintText: 'Name'.tr,
//                                   controller: _firstNameController,
//                                   textInputType: TextInputType.text,
//                                   maxLength: 22,
//                                   contentPadding: EdgeInsets.zero,
//                                   validators: (String? value) {
//                                     if (value!.isNotEmpty) {
//                                       return null;
//                                     } else {
//                                       return 'required'.tr;
//                                     }
//                                   },
//                                 ),
//                               ),
//                               const SizedBox(
//                                 width: 10,
//                               ),
//                               Expanded(
//                                 child: TextFieldThem.boxBuildTextField(
//                                   hintText: 'Last Name'.tr,
//                                   controller: _lastNameController,
//                                   textInputType: TextInputType.text,
//                                   maxLength: 22,
//                                   contentPadding: EdgeInsets.zero,
//                                   validators: (String? value) {
//                                     if (value!.isNotEmpty) {
//                                       return null;
//                                     } else {
//                                       return 'required'.tr;
//                                     }
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(top: 16),
//                             child: TextFieldThem.boxBuildTextField(
//                               hintText: 'phone'.tr,
//                               controller: _phoneController,
//                               textInputType: TextInputType.number,
//                               maxLength: 13,
//                               enabled: false,
//                               contentPadding: EdgeInsets.zero,
//                               validators: (String? value) {
//                                 if (value!.isNotEmpty) {
//                                   return null;
//                                 } else {
//                                   return 'required'.tr;
//                                 }
//                               },
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(top: 16),
//                             child: TextFieldThem.boxBuildTextField(
//                               hintText: 'email'.tr,
//                               controller: _emailController,
//                               textInputType: TextInputType.emailAddress,
//                               contentPadding: EdgeInsets.zero,
//                               validators: (String? value) {
//                                 bool emailValid = RegExp(
//                                         r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
//                                     .hasMatch(value!);
//                                 if (!emailValid) {
//                                   return 'email not valid'.tr;
//                                 } else {
//                                   return null;
//                                 }
//                               },
//                             ),
//                           ),
//                           // Padding(
//                           //   padding: const EdgeInsets.only(top: 16),
//                           //   child: TextFieldThem.boxBuildTextField(
//                           //     hintText: 'address'.tr,
//                           //     controller: _addressController,
//                           //     textInputType: TextInputType.text,
//                           //     contentPadding: EdgeInsets.zero,
//                           //     validators: (String? value) {
//                           //       if (value!.isNotEmpty) {
//                           //         return null;
//                           //       } else {
//                           //         return 'required'.tr;
//                           //       }
//                           //     },
//                           //   ),
//                           // ),
//                           Padding(
//                             padding: const EdgeInsets.only(top: 16),
//                             child: TextFieldThem.boxBuildTextField(
//                               hintText: 'password'.tr,
//                               controller: _passwordController,
//                               textInputType: TextInputType.text,
//                               obscureText: false,
//                               contentPadding: EdgeInsets.zero,
//                               validators: (String? value) {
//                                 if (value!.length >= 6) {
//                                   return null;
//                                 } else {
//                                   return 'Password required at least 6 characters'
//                                       .tr;
//                                 }
//                               },
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(top: 16),
//                             child: TextFieldThem.boxBuildTextField(
//                               hintText: 'confirm_password'.tr,
//                               controller: _conformPasswordController,
//                               textInputType: TextInputType.text,
//                               obscureText: false,
//                               contentPadding: EdgeInsets.zero,
//                               validators: (String? value) {
//                                 if (_passwordController.text != value) {
//                                   return 'Confirm password is invalid'.tr;
//                                 } else {
//                                   return null;
//                                 }
//                               },
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(top: 16),
//                             child: TextFieldThem.boxBuildTextField(
//                               hintText: 'Referral Code (Optional)'.tr,
//                               controller: _referralCodeController,
//                               textInputType: TextInputType.text,
//                               contentPadding: EdgeInsets.zero,
//                             ),
//                           ),
//                           Padding(
//                               padding: const EdgeInsets.only(top: 50),
//                               child: ButtonThem.buildButton(
//                                 context,
//                                 title: 'Sign up'.tr,
//                                 btnHeight: 45,
//                                 btnColor: ConstantColors.primary,
//                                 txtColor: Colors.white,
//                                 onPress: () async {
//                                   FocusScope.of(context).unfocus();
//                                   if (_formKey.currentState!.validate()) {
//                                     Map<String, String> bodyParams = {
//                                       'firstname': _firstNameController.text
//                                           .trim()
//                                           .toString(),
//                                       'lastname': _lastNameController.text
//                                           .trim()
//                                           .toString(),
//                                       'phone': _phoneController.text.trim(),
//                                       'email': _emailController.text.trim(),
//                                       'password': _passwordController.text,
//                                       'referral_code': _referralCodeController
//                                           .text
//                                           .toString(),
//                                       // 'address': _addressController.text,
//                                       'login_type': 'phone',
//                                       'tonotify': 'yes',
//                                       'account_type': 'customer',
//                                     };
//                                     print("SignUpRequest ==> ${bodyParams}");
//                                     print("SignUpRequest ==> ${bodyParams.toString()}");
//                                     await controller
//                                         .signUp(bodyParams)
//                                         .then((value) {
//                                       if (value != null) {
//                                         if (value.success == "success") {
//                                           Preferences.setInt(
//                                               Preferences.userId,
//                                               int.parse(
//                                                   value.data!.id.toString()));
//                                           Preferences.setString(
//                                               Preferences.user,
//                                               jsonEncode(value));
//                                           Get.to(AddProfilePhotoScreen());
//                                         } else {
//                                           ShowToastDialog.showToast(
//                                               value.error);
//                                         }
//                                       }
//                                     });
//                                   }
//                                 },
//                               )),
//                         ],
//                       ),
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
//       bottomNavigationBar: Container(
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage("assets/images/login_bg.png"),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Text.rich(
//               textAlign: TextAlign.center,
//               TextSpan(
//                 children: [
//                   TextSpan(
//                     text: 'Already have an account? '.tr,
//                     style: const TextStyle(
//                         color: Colors.black, fontWeight: FontWeight.w500),
//                     recognizer: TapGestureRecognizer()
//                       ..onTap = () {
//                         Get.offAll(LoginScreen(),
//                             duration: const Duration(
//                                 milliseconds:
//                                     400), //duration of transitions, default 1 sec
//                             transition:
//                                 Transition.rightToLeft); //transition effect);
//                       },
//                   ),
//                   TextSpan(
//                     text: 'login'.tr.toUpperCase(),
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: ConstantColors.primary),
//                     recognizer: TapGestureRecognizer()
//                       ..onTap = () {
//                         Get.offAll(LoginScreen(),
//                             duration: const Duration(
//                                 milliseconds:
//                                     400), //duration of transitions, default 1 sec
//                             transition:
//                                 Transition.rightToLeft); //transition effect);
//                       },
//                   ),
//                 ],
//               ),
//             )),
//       ),
//     );
//   }
// }
