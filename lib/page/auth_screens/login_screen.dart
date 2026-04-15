import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/controller/login_conroller.dart';
import 'package:zocar/helpers/app_bg.dart';
import 'package:zocar/helpers/unfocusall.dart';
import 'package:zocar/helpers/widget_binding.dart';
import 'package:zocar/page/auth_screens/add_profile_photo_screen.dart';
import 'package:zocar/page/auth_screens/forgot_password.dart';
import 'package:zocar/page/auth_screens/mobile_number_screen.dart';
import 'package:zocar/page/auth_screens/zocar_logo_widget.dart';
import 'package:zocar/page/main_page.dart';
import 'package:zocar/themes/constant_colors.dart';
import 'package:zocar/themes/text_field_them.dart';
import 'package:zocar/utils/preferences.dart';

import '../../constant/constant.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  static final _phoneController = TextEditingController();
  static final _passwordController = TextEditingController();

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final controller = Get.put(LoginController());
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
      ),
    );
    widgetBinding((_) {
      if(kDebugMode){
        LoginScreen._phoneController.text = "npr24c@gmail.com";
        LoginScreen._passwordController.text = "123456";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBg(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ZocarLogoWidget(),
                    // Logo or Icon (optional)
                    // Container(
                    //   padding: const EdgeInsets.all(20),
                    //   decoration: BoxDecoration(
                    //     color: Colors.white.withOpacity(0.9),
                    //     shape: BoxShape.circle,
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: ConstantColors.primary.withOpacity(0.2),
                    //         blurRadius: 20,
                    //         offset: const Offset(0, 10),
                    //       ),
                    //     ],
                    //   ),
                    //   child: Icon(
                    //     Icons.person_rounded,
                    //     size: 50,
                    //     color: ConstantColors.primary,
                    //   ),
                    // ),
                    const SizedBox(height: 32),
                    // Title
                    Text(
                      "Welcome Back".tr,
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Login with Email".tr,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 40),
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
                        key: _loginFormKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Email Field
                            TextFieldThem.boxBuildTextField(
                              hintText: 'email'.tr,
                              controller: LoginScreen._phoneController,
                              textInputType: TextInputType.emailAddress,
                              contentPadding: EdgeInsets.zero,
                              capitalization: TextCapitalization.none,
                              validators: (String? value) {
                                if (value!.isNotEmpty) {
                                  return null;
                                } else {
                                  return 'required'.tr;
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            // Password Field

                            TextFieldThem.boxBuildTextField(
                              hintText: 'password'.tr,
                              controller: LoginScreen._passwordController,
                              textInputType: TextInputType.text,
                              obscureText: !_isPasswordVisible,
                              contentPadding: EdgeInsets.zero,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  size: 16,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              validators: (String? value) {
                                if (value != null && value.isNotEmpty) {
                                  return null;
                                } else {
                                  return 'required'.tr;
                                }
                              },
                            ),

                            const SizedBox(height: 16),
                            // Forgot Password
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  unfocusAll();
                                  Get.to(
                                    () => ForgotPasswordScreen(),
                                    duration: const Duration(milliseconds: 300),
                                    transition: Transition.rightToLeft,
                                  );
                                },
                                child: Text(
                                  "forgot".tr,
                                  style: TextStyle(
                                    color: ConstantColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_loginFormKey.currentState!.validate()) {
                                    Map<String, String> bodyParams = {
                                      'email': LoginScreen._phoneController.text.trim(),
                                      'mdp': LoginScreen._passwordController.text,
                                      'user_cat': "customer",
                                    };
                                    unfocusAll();
                                    await controller.loginAPI(bodyParams).then((value) {
                                      if (value != null) {
                                        if (value.success == "Success") {
                                          Preferences.setInt(Preferences.userId, int.parse(value.data!.id.toString()));
                                          Preferences.setString(Preferences.user, jsonEncode(value));
                                          LoginScreen._phoneController.clear();
                                          LoginScreen._passwordController.clear();
                                          if (value.data!.photo == null || value.data!.photoPath.toString().isEmpty) {
                                            Get.to(() => AddProfilePhotoScreen());
                                          } else {
                                            Preferences.setBoolean(Preferences.isLogin, true);
                                            Get.offAll(
                                              () => MainPage(),
                                              duration: const Duration(milliseconds: 400),
                                              transition: Transition.rightToLeft,
                                            );
                                          }
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
                                child: Text(
                                  'log in'.tr.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Divider with OR
                            Row(
                              children: [
                                Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Phone Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  Get.to(
                                    MobileNumberScreen(isLogin: true),
                                    duration: const Duration(milliseconds: 300),
                                    transition: Transition.fade,
                                  );
                                },
                                icon: Icon(
                                  Icons.phone_android_rounded,
                                  color: ConstantColors.primary,
                                  size: 20,
                                ),
                                label: Text(
                                  'Login With Phone Number'.tr,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                    color: ConstantColors.primary,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: ConstantColors.primary, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  backgroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(24),
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
            child: Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                children: [
                  TextSpan(
                    text: "You don't have an account yet?".tr,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(text: "  "),
                  TextSpan(
                    text: 'SIGNUP'.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ConstantColors.primary,
                      fontSize: 15,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        unfocusAll();
                        Get.to(
                          () => MobileNumberScreen(isLogin: false),
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

// import 'dart:convert';
//
// import 'package:zocar/constant/show_toast_dialog.dart';
// import 'package:zocar/controller/login_conroller.dart';
// import 'package:zocar/helpers/app_bg.dart';
// import 'package:zocar/page/auth_screens/add_profile_photo_screen.dart';
// import 'package:zocar/page/auth_screens/forgot_password.dart';
// import 'package:zocar/page/auth_screens/mobile_number_screen.dart';
// import 'package:zocar/page/main_page.dart';
// import 'package:zocar/themes/button_them.dart';
// import 'package:zocar/themes/constant_colors.dart';
// import 'package:zocar/themes/text_field_them.dart';
// import 'package:zocar/utils/Preferences.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class LoginScreen extends StatelessWidget {
//   LoginScreen({super.key});
//
//   static final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
//
//   static final _phoneController = TextEditingController();
//   static final _passwordController = TextEditingController();
//   final controller = Get.put(LoginController());
//
//   @override
//   Widget build(BuildContext context) {
//     return AppBg(
//       child: SafeArea(
//         child: Scaffold(
//           backgroundColor: Colors.transparent,
//           body: Center(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 22),
//               child: SingleChildScrollView(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "Login with Email".tr,
//                       style: const TextStyle(letterSpacing: 0.60, fontSize: 22, color: Colors.black, fontWeight: FontWeight.w600),
//                     ),
//                     SizedBox(
//                         width: 80,
//                         child: Divider(
//                           color: ConstantColors.yellow1,
//                           thickness: 3,
//                         )),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 40),
//                       child: Form(
//                         key: _loginFormKey,
//                         autovalidateMode: AutovalidateMode.onUserInteraction,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             TextFieldThem.boxBuildTextField(
//                               hintText: 'email'.tr,
//                               controller: _phoneController,
//                               textInputType: TextInputType.emailAddress,
//                               contentPadding: EdgeInsets.zero,
//                               validators: (String? value) {
//                                 if (value!.isNotEmpty) {
//                                   return null;
//                                 } else {
//                                   return 'required'.tr;
//                                 }
//                               },
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(top: 15),
//                               child: TextFieldThem.boxBuildTextField(
//                                 hintText: 'password'.tr,
//                                 controller: _passwordController,
//                                 textInputType: TextInputType.text,
//                                 obscureText: false,
//                                 contentPadding: EdgeInsets.zero,
//                                 validators: (String? value) {
//                                   if (value!.isNotEmpty) {
//                                     return null;
//                                   } else {
//                                     return 'required'.tr;
//                                   }
//                                 },
//                               ),
//                             ),
//                             Padding(
//                                 padding: const EdgeInsets.only(top: 50),
//                                 child: ButtonThem.buildButton(
//                                   context,
//                                   title: 'log in'.tr,
//                                   btnHeight: 50,
//                                   btnColor: ConstantColors.primary,
//                                   txtColor: Colors.white,
//                                   onPress: () async {
//                                     FocusScope.of(context).unfocus();
//                                     if (_loginFormKey.currentState!.validate()) {
//                                       Map<String, String> bodyParams = {
//                                         'email': _phoneController.text.trim(),
//                                         'mdp': _passwordController.text,
//                                         'user_cat': "customer",
//                                       };
//                                       await controller.loginAPI(bodyParams).then((value) {
//                                         if (value != null) {
//                                           if (value.success == "Success") {
//                                             Preferences.setInt(Preferences.userId, int.parse(value.data!.id.toString()));
//                                             Preferences.setString(Preferences.user, jsonEncode(value));
//                                             _phoneController.clear();
//                                             _passwordController.clear();
//                                             if (value.data!.photo == null || value.data!.photoPath.toString().isEmpty) {
//                                               Get.to(() => AddProfilePhotoScreen());
//                                             } else {
//                                               Preferences.setBoolean(Preferences.isLogin, true);
//                                               Get.offAll(MainPage(),
//                                                   duration: const Duration(milliseconds: 400),
//                                                   //duration of transitions, default 1 sec
//                                                   transition: Transition.rightToLeft);
//                                             }
//                                           } else {
//                                             ShowToastDialog.showToast(value.error);
//                                           }
//                                         }
//                                       });
//                                     }
//                                   },
//                                 )),
//                             GestureDetector(
//                               onTap: () {
//                                 Get.to(ForgotPasswordScreen(),
//                                     duration: const Duration(milliseconds: 400), //duration of transitions, default 1 sec
//                                     transition: Transition.rightToLeft);
//                               },
//                               child: Padding(
//                                 padding: const EdgeInsets.only(top: 20),
//                                 child: Center(
//                                   child: Text(
//                                     "forgot".tr,
//                                     style: TextStyle(color: ConstantColors.primary, fontWeight: FontWeight.w600),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Padding(
//                                 padding: const EdgeInsets.only(top: 40),
//                                 child: ButtonThem.buildBorderButton(
//                                   context,
//                                   title: 'Login With Phone Number'.tr,
//                                   btnHeight: 50,
//                                   btnColor: Colors.white,
//                                   txtColor: ConstantColors.primary,
//                                   onPress: () {
//                                     FocusScope.of(context).unfocus();
//                                     Get.to(MobileNumberScreen(isLogin: true),
//                                         duration: const Duration(milliseconds: 400), //duration of transitions, default 1 sec
//                                         transition: Transition.rightToLeft);
//                                   },
//                                   btnBorderColor: ConstantColors.primary,
//                                 )),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           bottomNavigationBar: Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Text.rich(
//                 textAlign: TextAlign.center,
//                 TextSpan(
//                   children: [
//                     TextSpan(
//                       text: 'You don’t have an account yet? '.tr,
//                       style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
//                       recognizer: TapGestureRecognizer()
//                         ..onTap = () {
//                           Get.to(MobileNumberScreen(isLogin: false),
//                               duration: const Duration(milliseconds: 400), //duration of transitions, default 1 sec
//                               transition: Transition.rightToLeft); //transition effect);
//                         },
//                     ),
//                     TextSpan(text: " "),
//                     TextSpan(
//                       text: 'SIGNUP'.tr,
//                       style: TextStyle(fontWeight: FontWeight.bold, color: ConstantColors.primary),
//                       recognizer: TapGestureRecognizer()
//                         ..onTap = () {
//                           Get.to(
//                               MobileNumberScreen(
//                                 isLogin: false,
//                               ),
//                               duration: const Duration(milliseconds: 400), //duration of transitions, default 1 sec
//                               transition: Transition.rightToLeft); //transition effect);
//                         },
//                     ),
//                   ],
//                 ),
//               )),
//         ),
//       ),
//     );
//   }
// }
