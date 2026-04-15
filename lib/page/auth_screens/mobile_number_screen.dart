import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/controller/phone_number_controller.dart';
import 'package:zocar/helpers/app_bg.dart';
import 'package:zocar/helpers/unfocusall.dart';
import 'package:zocar/page/auth_screens/zocar_logo_widget.dart';
import 'package:zocar/themes/constant_colors.dart';

class MobileNumberScreen extends StatelessWidget {
  final bool? isLogin;

  MobileNumberScreen({super.key, required this.isLogin});

  final controller = Get.put(PhoneNumberController());

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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ZocarLogoWidget(),
                        // Phone Icon
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
                        //     Icons.phone_android_rounded,
                        //     size: 50,
                        //     color: ConstantColors.primary,
                        //   ),
                        // ),
                        const SizedBox(height: 32),
                        // Title
                        Text(
                          isLogin == true ? "Phone Login".tr : "Phone Signup".tr,
                          style: const TextStyle(
                            fontSize: 28,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Subtitle
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            isLogin == true ? "Enter your phone number to login".tr : "Enter your phone number to get started".tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        // Phone Input Container
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: IntlPhoneField(
                            showCountryFlag: true,
                            // disablePickCountry: true,
                            initialCountryCode: 'IN',
                            onChanged: (phone) {
                              controller.phoneNumber.value = phone.completeNumber;
                              controller.phoneNumberValid.value = phone.isValidNumber();
                            },
                            invalidNumberMessage: "Invalid phone number".tr,
                            showDropdownIcon: false,
                            dropdownIcon: Icon(
                              Icons.arrow_drop_down_rounded,
                              color: ConstantColors.primary,
                              size: 28,
                            ),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            flagsButtonPadding: const EdgeInsets.only(left: 8, right: 12),
                            disableLengthCheck: false,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              hintText: 'Phone Number'.tr,
                              counterText: '',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            dropdownTextStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Continue Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () async {

                              if(!controller.phoneNumberValid.value){
                                ShowToastDialog.showToast("Invalid phone number".tr);
                                return;
                              }
                              if (controller.phoneNumber.value.isNotEmpty) {
                                unfocusAll();
                                ShowToastDialog.showLoader("Sending verification code".tr);
                                controller.sendCode(controller.phoneNumber.value);
                              } else {
                                ShowToastDialog.showToast("Please enter phone number".tr);
                              }
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
                                    letterSpacing: 1.2,
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
                        const SizedBox(height: 20),
                        // Divider with OR
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey.shade400,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey.shade400,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Email Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              Get.back();
                            },
                            icon: const Icon(
                              Icons.email_rounded,
                              size: 20,
                            ),
                            label: Text(
                              'Login With Email'.tr,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
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
                              backgroundColor: Colors.white.withOpacity(0.9),
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

// import 'package:zocar/constant/show_toast_dialog.dart';
// import 'package:zocar/controller/phone_number_controller.dart';
// import 'package:zocar/themes/button_them.dart';
// import 'package:zocar/themes/constant_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl_phone_field/countries.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';
//
// class MobileNumberScreen extends StatelessWidget {
//   final bool? isLogin;
//
//   MobileNumberScreen({super.key, required this.isLogin});
//
//   final controller = Get.put(PhoneNumberController());
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
//               image: AssetImage(
//                 "assets/images/login_bg.png",
//               ),
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
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           isLogin == true
//                               ? "Login Phone".tr
//                               : "Signup Phone".tr,
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
//                           padding: const EdgeInsets.only(top: 80),
//                           child: Container(
//                             decoration: BoxDecoration(
//                                 border: Border.all(
//                                   color: ConstantColors.textFieldBoarderColor,
//                                 ),
//                                 borderRadius:
//                                     const BorderRadius.all(Radius.circular(6))),
//                             padding: const EdgeInsets.only(left: 10),
//                             child: IntlPhoneField(
//                               initialCountryCode: 'IN',
//                               onChanged: (phone) {
//                                 controller.phoneNumber.value =
//                                     phone.completeNumber;
//                               },
//                               invalidNumberMessage: "number invalid",
//                               showDropdownIcon: false,
//                               disableLengthCheck: true,
//                               decoration: InputDecoration(
//                                 contentPadding:
//                                     const EdgeInsets.symmetric(vertical: 12),
//                                 hintText: 'Phone Number'.tr,
//                                 border: InputBorder.none,
//                                 isDense: true,
//                               ),
//                             ),
//                           ),
//                         ),
//                         Padding(
//                             padding: const EdgeInsets.only(top: 50),
//                             child: ButtonThem.buildButton(
//                               context,
//                               title: 'Continue'.tr,
//                               btnHeight: 50,
//                               btnColor: ConstantColors.primary,
//                               txtColor: Colors.white,
//                               onPress: () async {
//                                 FocusScope.of(context).unfocus();
//                                 if (controller.phoneNumber.value.isNotEmpty) {
//                                   ShowToastDialog.showLoader("Code sending".tr);
//                                   controller
//                                       .sendCode(controller.phoneNumber.value);
//                                 }
//                               },
//                             )),
//                         Padding(
//                             padding: const EdgeInsets.only(top: 50),
//                             child: ButtonThem.buildButton(
//                               context,
//                               title: 'Login With Email'.tr,
//                               btnHeight: 50,
//                               btnColor: ConstantColors.yellow,
//                               txtColor: Colors.white,
//                               onPress: () {
//                                 FocusScope.of(context).unfocus();
//                                 Get.back();
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
