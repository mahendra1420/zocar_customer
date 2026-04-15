// utils.dart
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zocar/constant/constant.dart';
import 'package:zocar/utils/preferences.dart';

import '../constant/show_toast_dialog.dart';
import '../controller/main_page_controller.dart';
import '../helpers/devlog.dart';
import '../service/api.dart';
import '../themes/custom_alert_dialog_new.dart';
import '../themes/custom_dialog_box_new.dart';
import 'main_page.dart';



class Utils {
  static Timer? autoCancelTimer;

  static String? idz;
  static BuildContext? contextz;

  static checkAndCancel(BuildContext context, String id) {
    final isAccepted = Preferences.getBoolean("isAccepted");
    devlog("isAccepted checkAndCancel: $isAccepted");
    if (Constant.isBottomSheetVisible || isAccepted) {
      cancelll(context, id);
    }
  }

  static checkAndCancelIfAccepted(BuildContext context, String id) async {
    final sp = await SharedPreferences.getInstance();
    await sp.reload();
    final isAccepted = sp.getBool("isAcceptedNew") ?? false;
    devlog("isAcceptedNew checkAndCancelIfAccepted: $isAccepted");
    if (isAccepted) {
      Utils.closeBottomSheet();
      MainPageController dashBoardController = Get.put(MainPageController());
      dashBoardController.selectedDrawerIndex.value = drawerItems.indexWhere((element) => element.isAllRides);
      await Get.to(MainPage());
    }
  }

  static cancelll(BuildContext context, String id) {
    Map<String, String> bodyParams = {'ride_id': id, "version": "2", "auto_cancel": "1"};
    cancelRide(bodyParams).then((value) {
        Utils.closeBottomSheet();
      if (value != null && value['success'] != "Failed") {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return CustomDialogBoxNew(
              title: "No ZoCar Available",
              // descriptions: "No ZoCar is available at your location right now."
              //     "If you have a little time, please choose Schedule Ride."
              //     "ZoCar will plan your ride with priority. 💛",
              descriptions: "No ZoCar nearby right now.",
              subDescriptions: "Please schedule your ride 1 hour later.",
              // text: "Ok".tr,
              text: "Schedule for 1 Hour Later",
              onPress: () {
                Navigator.of(context).pop();
              },
              img: Image.asset('assets/images/img_cancel.png'),
            );
          },
        );
      }
    });
  }




  static void showBottomSearchDriver(BuildContext context, String id) {
    idz = id;
    contextz = context;
    print("call showBottomSearchDriver id ------->: $idz");
    // autoCancelTimer = Timer( Duration(seconds: Preferences.rideSettings?.requestCancelTime ?? 90), () {
    //   print("autoCancelTimer executed for id ------->: $id");
    //   checkAndCancel(context, id);
    // });

    Constant.isBottomSheetVisible = true;
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(15),
              topLeft: Radius.circular(15),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 15),
              Icon(Icons.directions_car, size: 30, color: Colors.blue),
              SizedBox(height: 15),
              Text(
                'Ride requested',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 15),
              Text(
                'Searching for an online driver...',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 60),
              SizedBox(
                height: 150,
                width: 110,
                child: Lottie.asset(
                  'assets/lottie/vehicleSearch.json',
                  width: 145,
                  height: 105,
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () {
                  showDialog(
                    barrierColor: Colors.black26,
                    context: context,
                    builder: (ctx) {
                      return CustomAlertDialogNew(
                        title: "Do you want to cancel this booking?".tr,
                        onPressNegative: () => Get.back(),
                        negativeButtonText: 'No'.tr,
                        positiveButtonText: 'Yes'.tr,
                        onPressPositive: () {
                          autoCancelTimer?.cancel();
                          Navigator.pop(ctx);
                          Map<String, String> bodyParams = {'ride_id': id, "version": "2"};
                          cancelRide(bodyParams).then((value) {
                            if (value != null) {
                              autoCancelTimer?.cancel();
                              Utils.closeBottomSheet();
                              if (value != null && value['success'] != "Failed")
                                showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) {
                                  return CustomDialogBoxNew(
                                    title: "Cancel Successfully".tr,
                                    descriptions: "Ride Successfully Canceled.".tr,
                                    text: "Ok".tr,
                                    onPress: () {
                                      Get.back();
                                      Get.back();
                                      Get.back();
                                    },
                                    img: Image.asset(
                                      'assets/images/green_checked.png',
                                    ),
                                  );
                                },
                              );
                            }
                          });
                        },
                      );
                    },
                  );
                },
                child: Text(
                  'Cancel ride',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ),
              SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  static void closeBottomSheet({bool isFromNotification = false}) {
    autoCancelTimer?.cancel();
    autoCancelTimer = null;
    Constant.isBottomSheetVisible = false;
    Constant.isAccepted = false;
    SharedPreferences.getInstance().then((value) {
      value.setBool("isAcceptedNew", false);
    });
    Get.back();
  }

  static Future<dynamic> cancelRide(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await LoggingClient(http.Client()).post(Uri.parse(API.CancelRequest), headers: API.header, body: jsonEncode(bodyParams));
      devlog("MyLogData cancelRide ==> ${response.body.toString()}");
      Map<String, dynamic> responseBody = {};
      try {
        responseBody = json.safeDecode(response.body);
        devlog("MyLogData cancelRide ==> $responseBody");
      } catch (e) {
        debugPrint("neon -> error in json decode body  fkljehh : $e");
      }
      log(responseBody.toString());
      if (response.statusCode == 200 && responseBody['success'] == "success" || responseBody['success'] == "Success") {
        ShowToastDialog.closeLoader();
        return responseBody;
      } else if (response.statusCode == 200 && responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(responseBody['error']);
        return responseBody;
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast('Something went wrong. Please try again later');
        // throw Exception('Something went wrong.!');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    ShowToastDialog.closeLoader();
    return null;
  }
}
