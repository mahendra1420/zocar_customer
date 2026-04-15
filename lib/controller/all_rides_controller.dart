import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/model/ride_model.dart';
import 'package:zocar/service/api.dart';
import 'package:zocar/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constant/logdata.dart';

class AllRidesController extends GetxController with GetTickerProviderStateMixin {
  var isLoading = true.obs;
  var rideList = <RideData>[].obs;
  var newRideList = <RideData>[].obs;
  var completedRideList = <RideData>[].obs;
  var rejectedRideList = <RideData>[].obs;
  Timer? timer;

  // bool isCompletedLastRide = false;

  TabController? tabController;

  void goToTab([int index = 0]) {
    tabController?.animateTo(index, duration: Duration(milliseconds: 300), curve: Curves.linear);
  }

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    print("cccccc----->");
    getAllRides(isinit: true);


    if(timer?.isActive ?? false){
      timer?.cancel();
      timer = null;
    }

    timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      getAllRides();
    });

    update();
  }

  @override
  void onClose() {
    if (timer != null) {
      timer!.cancel();
    }
    tabController?.dispose(); // Don't forget to dispose TabController
    super.onClose();
  }

  Future<dynamic> getAllRides({bool isinit = false}) async {
    try {
      if (isinit) {
        ShowToastDialog.showLoader("Please wait");
      }
      final response = await LoggingClient(http.Client()).get(Uri.parse("${API.userAllRides}?id_user_app=${Preferences.getInt(Preferences.userId)}"), headers: API.header);

      showLog("API :: URL :: ${API.userAllRides}?id_user_app=${Preferences.getInt(Preferences.userId)} ");
      showLog("API :: Header :: ${API.header.toString()} ");
      showLog("API :: responseStatus :: ${response.statusCode} ");
      showLog("API :: New Ride responseBody :: ${response.body} ");
      Map<String, dynamic> responseBody = json.safeDecode(response.body);
      if (response.statusCode.toString() == "200" && responseBody['success'] == "success") {
        showLog("hererer");
        isLoading.value = false;
        try {
          RideModel model = RideModel.fromJson(responseBody);

        newRideList.clear();
        completedRideList.clear();
        rejectedRideList.clear();
        for (var ride in model.data!) {
          if (ride.statut == "new" || ride.statut == "on ride" || ride.statut == "confirmed" || ride.statut == "accepted" || ride.isCompletedButPaymentAndReviewPending) {
            newRideList.add(ride);
          } else if (ride.statut == "completed") {
            completedRideList.add(ride);
          } else if (ride.statut == "rejected") {
            rejectedRideList.add(ride);
          }
        }
        } catch(e){
          showLog("hererer 3 $e");
        }
        ShowToastDialog.closeLoader();
      } else {
        showLog("hererer 2");
        newRideList.clear();
        completedRideList.clear();
        rejectedRideList.clear();
        ShowToastDialog.closeLoader();
        isLoading.value = false;
      }
    } on TimeoutException {
      ShowToastDialog.closeLoader();
      isLoading.value = false;
    } on SocketException {
      ShowToastDialog.closeLoader();
      isLoading.value = false;
    } on Error {
      ShowToastDialog.closeLoader();
      isLoading.value = false;
    } catch (e) {
      log('FireStoreUtils.getCurrencys Parse error $e');
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    update();
    return null;
  }
}
