// ignore_for_file: implicit_call_tearoffs

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zocar/controller/on_boarding_controller.dart';
import 'package:zocar/helpers/app_bg.dart';
import 'package:zocar/page/auth_screens/login_screen.dart';
import 'package:zocar/themes/constant_colors.dart';
import 'package:zocar/utils/preferences.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<OnBoardingController>(
      init: OnBoardingController(),
      builder: (controller) {
        return AppBg(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: controller.selectedPageIndex.value != 0
                  ? IconButton(
                onPressed: () {
                  controller.pageController.animateToPage(
                    controller.selectedPageIndex.value - 1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black87,
                    size: 20,
                  ),
                ),
              )
                  : const SizedBox.shrink(),
              actions: [
                if (controller.selectedPageIndex.value != 2)
                  TextButton(
                    onPressed: () {
                      Preferences.setBoolean(Preferences.isFinishOnBoardingKey, true);
                      Get.offAll(() => LoginScreen());
                    },
                    child: Text(
                      'skip'.tr,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: controller.pageController,
                      onPageChanged: controller.selectedPageIndex,
                      itemCount: controller.onBoardingList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              Expanded(
                                flex: 3,
                                child: Hero(
                                  tag: 'onboarding_$index',
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: ConstantColors.primary.withOpacity(0.1),
                                          blurRadius: 30,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: Image.asset(
                                        controller.onBoardingList[index].imageAsset.toString(),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    Text(
                                      controller.onBoardingList[index].title.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 26,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                        height: 1.3,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Text(
                                        controller.onBoardingList[index].description.toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey.shade600,
                                          height: 1.6,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // Page indicators
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.onBoardingList.length,
                            (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: controller.selectedPageIndex.value == index ? 40 : 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: controller.selectedPageIndex.value == index
                                ? ConstantColors.primary
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Bottom button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: controller.selectedPageIndex.value == 2
                        ? SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Preferences.setBoolean(Preferences.isFinishOnBoardingKey, true);
                          Get.offAll(LoginScreen());
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
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    )
                        : SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          controller.pageController.animateToPage(
                            controller.selectedPageIndex.value + 1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ConstantColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'next'.tr,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// // ignore_for_file: implicit_call_tearoffs
//
// import 'package:zocar/controller/on_boarding_controller.dart';
// import 'package:zocar/page/auth_screens/login_screen.dart';
// import 'package:zocar/themes/constant_colors.dart';
// import 'package:zocar/utils/Preferences.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class OnBoardingScreen extends StatelessWidget {
//   const OnBoardingScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetX<OnBoardingController>(
//       init: OnBoardingController(),
//       builder: (controller) {
//         return Scaffold(
//           backgroundColor: Colors.white,
//           appBar: AppBar(
//             backgroundColor: Colors.white,
//             elevation: 0,
//             leading: controller.selectedPageIndex.value != 0
//                 ? InkWell(
//                     onTap: () {
//                       controller.pageController.jumpToPage(controller.selectedPageIndex.value - 1);
//                     },
//                     child: const Icon(
//                       Icons.arrow_back_ios,
//                       color: Colors.black,
//                     ),
//                   )
//                 : const Offstage(),
//           ),
//           body: SafeArea(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Expanded(
//                   child: PageView.builder(
//                       controller: controller.pageController,
//                       onPageChanged: controller.selectedPageIndex,
//                       itemCount: controller.onBoardingList.length,
//                       itemBuilder: (context, index) {
//                         return Column(
//                           children: [
//                             Expanded(
//                               child: Padding(
//                                 padding: const EdgeInsets.only(top: 40),
//                                 child: Center(
//                                   child: Image.asset(
//                                     controller.onBoardingList[index].imageAsset.toString(),
//                                     width: 260,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                                 child: Padding(
//                               padding: const EdgeInsets.only(top: 50),
//                               child: Column(
//                                 children: [
//                                   Text(
//                                     controller.onBoardingList[index].title.toString(),
//                                     style: TextStyle(fontSize: 20, color: ConstantColors.primary, fontWeight: FontWeight.w900, letterSpacing: 1.5),
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
//                                     child: Text(
//                                       controller.onBoardingList[index].description.toString(),
//                                       textAlign: TextAlign.center,
//                                       style: const TextStyle(fontSize: 16, color: Colors.black87, letterSpacing: 1.5),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ))
//                           ],
//                         );
//                       }),
//                 ),
//                 controller.selectedPageIndex.value == 2
//                     ? ElevatedButton(
//                         onPressed: () {
//                           Preferences.setBoolean(Preferences.isFinishOnBoardingKey, true);
//                           Get.offAll(LoginScreen());
//                         },
//                         style: ElevatedButton.styleFrom(shape: const StadiumBorder(), backgroundColor: ConstantColors.primary),
//                         child: const Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
//                           child: Text('Get started'),
//                         ),
//                       )
//                     : InkWell(
//                         borderRadius: BorderRadius.circular(10),
//                         onTap: () {
//                           controller.pageController.jumpToPage(controller.selectedPageIndex.value + 1);
//                         },
//                         child: Padding(
//                           padding:  EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
//                           child: Text(
//                             'next'.tr,
//                             style: const TextStyle(fontSize: 16, letterSpacing: 1.5, color: Color(0xff6F6F6F), fontWeight: FontWeight.w500),
//                           ),
//                         )),
//
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 50),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: List.generate(
//                       controller.onBoardingList.length,
//                       (index) => Container(
//                           margin: controller.selectedPageIndex.value == index ? const EdgeInsets.symmetric(horizontal: 10) : EdgeInsets.zero,
//                           width: controller.selectedPageIndex.value == index ? 50 : 66,
//                           height: 10,
//                           decoration: BoxDecoration(
//                             color: controller.selectedPageIndex.value == index ? ConstantColors.primary : const Color(0xffD4D5E0),
//                             borderRadius: borderRadius(controller.selectedPageIndex.value, index),
//                           )),
//                     ),
//                   ),
//                 ),
//
//                 // InkWell(onTap: () {
//                 //   if (controller.selectedPageIndex.value == controller.onBoardingList.length - 1) {
//                 //     Preferences.setBoolean(Preferences.isFinishOnBoardingKey, true);
//                 //     Get.offAll(LoginScreen());
//                 //   } else {
//                 //     controller.pageController.nextPage(duration: 300.milliseconds, curve: Curves.ease);
//                 //   }
//                 // }, child: Obx(() {
//                 //   return Text(
//                 //     controller.isLastPage ? 'done'.tr : 'next'.tr,
//                 //     style: const TextStyle(fontSize: 16),
//                 //   );
//                 // }))
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   BorderRadiusGeometry borderRadius(int index, int currentIndex) {
//     if (index == 0 && currentIndex == 0) {
//       return const BorderRadius.all(Radius.circular(10.0));
//     }
//     if (index == 0 && currentIndex == 1) {
//       return const BorderRadius.only(topLeft: Radius.circular(40.0), bottomLeft: Radius.circular(40.0));
//     }
//     if (index == 0 && currentIndex == 2) {
//       return const BorderRadius.only(topRight: Radius.circular(40.0), bottomRight: Radius.circular(40.0));
//     }
//     if (index == 1 && currentIndex == 1) {
//       return const BorderRadius.all(Radius.circular(10.0));
//     }
//     if (index == 1 && currentIndex == 1) {
//       return const BorderRadius.all(Radius.circular(10.0));
//     }
//     if (index == 1 && currentIndex == 2) {
//       return const BorderRadius.all(Radius.circular(10.0));
//     }
//     if (index == 2 && currentIndex == 2) {
//       return const BorderRadius.all(Radius.circular(10.0));
//     }
//     if (index == 2 && currentIndex == 0) {
//       return const BorderRadius.only(topLeft: Radius.circular(40.0), bottomLeft: Radius.circular(40.0));
//     }
//     if (index == 2 && currentIndex == 1) {
//       return const BorderRadius.only(topRight: Radius.circular(40.0), bottomRight: Radius.circular(40.0));
//     }
//     return const BorderRadius.all(Radius.circular(10.0));
//   }
// }
