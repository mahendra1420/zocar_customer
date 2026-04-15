
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/main_page_controller.dart';
import '../controller/all_rides_controller.dart';
import '../page/main_page.dart';

pendingPaymentDialog(BuildContext context) {
  Widget okButton = TextButton(
    child: const Text("OK"),
    onPressed: () {
      Get.back();
      AllRidesController? newRideCtr;
      try {
        newRideCtr = Get.find<AllRidesController>();
      } catch (e) {
        newRideCtr = Get.put<AllRidesController>(AllRidesController());
      }
      MainPageController? mainCtr;
      try {
        mainCtr = Get.find<MainPageController>();
      } catch (e) {
        mainCtr = Get.put<MainPageController>(MainPageController());
      }

      mainCtr.selectedDrawerIndex.value = drawerItems.indexWhere((element) => element.isAllRides);
      newRideCtr.goToTab(0);
      Get.to(() => MainPage());
    },
  );

  AlertDialog alert = AlertDialog(
    title: const Text("ZoCar"),
    content: Text("You have pending payments. Please complete payment before book new trip.".tr),
    actions: [
      okButton,
    ],
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}