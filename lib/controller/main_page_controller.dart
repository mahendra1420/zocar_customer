import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as get_cord_address;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// import 'package:launch_review/launch_review.dart';
import 'package:location/location.dart';
import 'package:zocar/constant/constant.dart';
import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/controller/home_controller.dart';
import 'package:zocar/model/user_model.dart';
import 'package:zocar/page/main_page.dart';
import 'package:zocar/service/api.dart';
import 'package:zocar/utils/preferences.dart';

import '../helpers/devlog.dart';
import '../model/driver_location_update.dart';
import '../model/payment_setting_model.dart';
import '../page/all_rides/route_view_screen.dart';
import 'all_rides_controller.dart';

bool isFirstTime = true;

class MainPageController extends GetxController {
  RxInt selectedDrawerIndex = 0.obs;
  Location location = Location();
  late StreamSubscription<LocationData> locationSubscription;
  RxBool isActive = true.obs;
  final controller = Get.put(HomeController());
  // final AllRidesController allridesController = AllRidesController();

  @override
  void onInit() {
    super.onInit();
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      updateFCMToken(newToken);
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      updateCurrentLocation();
      getUsrData();
      updateToken();
      getPaymentSettingData();
      getAndSetCurrentLocation();
      if (isFirstTime) {
        redirectToSearchingRideIfAvailable();
        isFirstTime = false;
      }
    });
    // allridesController.getAllRides(isinit: false);
  }

  void redirectToSearchingRideIfAvailable() async {
    AllRidesController? ctr;
    try {
      ctr = Get.find<AllRidesController>();
    } catch (e) {
      try {
        ctr = Get.put<AllRidesController>(AllRidesController());
      } catch (e) {
        devlogError("No New Ride Controller Available: $e");
      }
    }
    if (ctr != null) {
      await ctr.getAllRides();
      if (ctr.newRideList.any((element) => !element.isCompletedButPaymentAndReviewPending)) {
        final data = ctr.newRideList.firstWhere((element) => !element.isCompletedButPaymentAndReviewPending);
        final DateTime dateTime = DateFormat(
          'dd MMM, yyyy HH:mm:ss',
        ).parse("${data.dateRetour} ${data.heureRetour}");

        if (!data.isNew || dateTime.difference(DateTime.now()).inMinutes.abs() <= 5) {
          var argumentData = {
            'type': data.statut.toString(),
            'data': data,
          };

          selectedDrawerIndex.value = drawerItems.indexWhere((e) => e.isAllRides);

          Get.to(() => const RouteViewScreen(), arguments: argumentData);
        }
      }
    }
  }

  Future<void> getAndSetCurrentLocation() async {
    try {
      Position location = await Geolocator.getCurrentPosition();
      controller.locationData = location;
      controller.locationDataSetFromMainCtr = true;
      controller.update();
      List<get_cord_address.Placemark> placeMarks = await get_cord_address.placemarkFromCoordinates(location.latitude, location.longitude);
      final address = ((placeMarks.first.subLocality?.isEmpty ?? true) ? '' : "${placeMarks.first.subLocality}, ") +
          ((placeMarks.first.street?.isEmpty ?? true) ? '' : "${placeMarks.first.street}, ") +
          ((placeMarks.first.name?.isEmpty ?? true) ? '' : "${placeMarks.first.name}, ") +
          ((placeMarks.first.subAdministrativeArea?.isEmpty ?? true) ? '' : "${placeMarks.first.subAdministrativeArea}, ") +
          ((placeMarks.first.administrativeArea?.isEmpty ?? true) ? '' : "${placeMarks.first.administrativeArea}, ") +
          ((placeMarks.first.country?.isEmpty ?? true) ? '' : "${placeMarks.first.country}, ") +
          ((placeMarks.first.postalCode?.isEmpty ?? true) ? '' : "${placeMarks.first.postalCode}, ");
      controller.departureController.text = address;
    } catch (e) {
      devlog("neon -> error in get current location : $e");
    }
  }

  UserModel userModel = Constant.getUserData();

  getUsrData() {
    userModel = Constant.getUserData();
    // getDrawerItems();
  }

  Future<void> updateCurrentLocation() async {
    if (isActive.value) {
      PermissionStatus permissionStatus = await location.hasPermission();
      if (permissionStatus != PermissionStatus.granted) {
        _showPermissionDialog();
      }
    } else {
      DriverLocationModel driverLocationUpdate =
          DriverLocationModel(rotation: 0, active: false, driverId: Preferences.getInt(Preferences.userId), driverLatitude: 0, driverLongitude: 0);
      Constant.driverLocationUpdateNEw.doc(Preferences.getInt(Preferences.userId).toString()).set(driverLocationUpdate.toJson());
    }
  }

  void _showPermissionDialog() {
    Get.dialog(
        AlertDialog(
          title: Text('Location Access Required'),
          content: Text('We need access to your location to provide personalized content and features. Please grant location permission.'),
          actions: [
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Get.back();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () async {
                Get.back();
                PermissionStatus permissionStatus = await location.requestPermission();
                if (permissionStatus == PermissionStatus.granted) {
                  //_startLocationUpdates();
                }
              },
            ),
          ],
        ),
        barrierDismissible: false);
  }

  updateToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    devlog("FcmToken ==> ${token.toString()}");
    if (token != null) {
      updateFCMToken(token);
    }
  }

  onSelectItem(int index) {
    selectedDrawerIndex.value = index;
    Get.back();
  }

  Future<dynamic> updateFCMToken(String token) async {
    try {
      Map<String, dynamic> bodyParams = {'user_id': Preferences.getInt(Preferences.userId), 'fcm_id': token, 'device_id': "", 'user_cat': userModel.data!.userCat};
      final response = await LoggingClient(http.Client()).post(Uri.parse(API.updateToken), headers: API.header, body: jsonEncode(bodyParams));

      Map<String, dynamic> responseBody = json.safeDecode(response.body);
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        ShowToastDialog.showToast('Something went wrong. Please try again later');
        throw Exception('Something went wrong.!');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
      devlog("TimeoutException");
    } on SocketException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
      devlog("TimeoutException");
    } on Error catch (e) {
      ShowToastDialog.showToast(e.toString());
      devlog("TimeoutException");
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
      devlog("TimeoutException");
    }
    return null;
  }

  Future<dynamic> getPaymentSettingData() async {
    try {
      final response = await LoggingClient(http.Client()).get(Uri.parse(API.paymentSetting), headers: API.header);

      log("Payment setting data ${response.body}");

      Map<String, dynamic> responseBody = json.safeDecode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        Preferences.setString(Preferences.paymentSetting, jsonEncode(responseBody));
      } else if (response.statusCode == 200 && responseBody['success'] == "Failed") {
      } else {
        ShowToastDialog.showToast('Something went wrong. Please try again later');
        throw Exception('Something went wrong.!');
      }
    } on TimeoutException {
      // ShowToastDialog.showToast(e.message.toString());
    } on SocketException {
      // ShowToastDialog.showToast(e.message.toString());
    } on Error {
      // ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  static PaymentSettingModel getPaymentSetting() {
    final String user = Preferences.getString(Preferences.paymentSetting);
    if (user.isNotEmpty) {
      Map<String, dynamic> userMap = jsonDecode(user);
      return PaymentSettingModel.fromJson(userMap);
    }
    return PaymentSettingModel();
  }
}
