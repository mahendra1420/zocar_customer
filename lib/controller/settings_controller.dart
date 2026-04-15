import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as get_cord_address;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:zocar/constant/constant.dart';
import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/helpers/size_ext.dart';
import 'package:zocar/model/ride_settings_model.dart';
import 'package:zocar/model/settings_model.dart';
import 'package:zocar/service/api.dart';
import 'package:zocar/utils/preferences.dart';

import '../helpers/devlog.dart';
import '../model/payment_setting_model.dart';
import '../model/tax_model.dart';
import '../themes/constant_colors.dart';

class SettingsController extends GetxController {
  Location location = Location();

  /// for background handle of ride request and when driver accepte ride than update ui
  ///
  bool get isAcceptedRide => _isAcceptedRide;
  bool _isAcceptedRide = false;

  void setAcceptedRide(bool status, {bool listen = false}) {
    _isAcceptedRide = status;
    if (listen) update();
  }

  ///

  @override
  void onInit() async {
    API.header['accesstoken'] = Preferences.getString(Preferences.accesstoken);
    getRideSettingsData();
    PermissionStatus permissionStatus = await location.hasPermission();
    if (permissionStatus != PermissionStatus.granted) {
      _showPermissionDialog();
    } else {
      getSettingsData();
      getPaymentSettingData();
    }

    super.onInit();
  }

  RxBool isChecked = false.obs;

  void _showPermissionDialog() {
    Get.dialog(
        PopScope(
          canPop: isChecked.value,
          child: AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 5.h),
            title: const Text(
              'Location Prominent Disclosure – ZoCar Taxi',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            content: Scrollbar(
              child: SingleChildScrollView(
                child: const Text(
                  'ZoCar Taxi collects and uses your location data, including background location access (even when the app is not actively in use), to provide reliable, safe, and efficient taxi services.\n\n'
                  'The primary purpose of using background location is to obtain live Customer and Driver location for seamless trip management and service delivery.\n\n'
                  'Background location is used for the following features:\n\n'
                  '• Real-time tracking of Customer and Driver location\n'
                  '• Accurate ETA (Estimated Time of Arrival) calculation\n'
                  '• Location-based driver–customer matching\n'
                  '• Route optimization for faster and more efficient trips\n'
                  '• Safety features and emergency assistance during rides\n\n'
                  'By enabling location access, you help ZoCar Taxi ensure a smooth, transparent, and secure ride experience.',
                  style: TextStyle(height: 1.4),
                ),
              ),
            ),
            actions: [
              Obx(() => Row(
                    children: [
                      Checkbox(
                        value: isChecked.value,
                        onChanged: (bool? value) {
                          isChecked.value = value!;
                        }, // Define a variable to store checkbox state
                      ),
                      Text('I Agree'),
                    ],
                  )),
              TextButton(
                child: Text('OK'),
                onPressed: () async {
                  if (isChecked.value) {
                    Get.back(); // Close dialog if checkbox is checked
                    // return; // Exit the function after closing dialog
                    PermissionStatus permissionStatus = await location.requestPermission();
                    if (permissionStatus == PermissionStatus.granted) {
                      getSettingsData();
                      getPaymentSettingData();
                    }
                  } else {
                    ShowToastDialog.showToast('Please check I Agree with Disclosure');
                  }
                },
              ),
            ],
          ),
        ),
        barrierDismissible: false);
  }

  Future<SettingsModel?> getSettingsData() async {
    try {
      final response = await LoggingClient(http.Client()).get(
        Uri.parse(API.settings),
        headers: API.authheader,
      );

      Map<String, dynamic> responseBody = json.safeDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "success") {
        log("responseBody responseBody responseBody ${API.authheader} ===>${responseBody.toString()}");
        ShowToastDialog.closeLoader();
        SettingsModel model = SettingsModel.fromJson(responseBody);
        LocationData location = await Location().getLocation();
        List<get_cord_address.Placemark> placeMarks = await get_cord_address.placemarkFromCoordinates(location.latitude ?? 0.0, location.longitude ?? 0.0);

        // Update primary color
        ConstantColors.primary = Color(int.parse(model.data!.websiteColor!.replaceFirst("#", "0xff")));

        // Update all Constant values using setters (which will persist to SharedPreferences)
        Constant.distanceUnit = model.data!.deliveryDistance!;
        Constant.driverRadius = model.data!.driverRadios!;
        Preferences.setString(Preferences.driverRadius, model.data!.driverRadios!);
        Preferences.setString(Preferences.admincommission, responseBody['data']['admin_commission'].toString());
        Preferences.setString(Preferences.adminCommissionType, responseBody['data']['commision_type'].toString());

        // await Preferences.setInitialPaymentPercentage(model.data?.initialPaymentPercentage ?? 0);
        // devlog("Saved Initial Payment Percentage: ${Preferences.getInitialPaymentPercentage()}");
        devlog("Api Payment Percentage: ${model.data!.initialPaymentPercentage.toString()}");

        // Constant.initialPaymentPercentage = model.data!.initialPaymentPercentage!;
        Constant.decimal = model.data!.decimalDigit!;
        Constant.driverLocationUpdate = model.data!.driverLocationUpdate!;
        Constant.mapType = model.data!.mapType!;
        Constant.deliverChargeParcel = model.data!.deliverChargeParcel!;

        devlog("SettingData deliverChargeParcel ==> ${model.data!.deliverChargeParcel!}");
        devlog("SettingData driverRadios ==> ${model.data!.driverRadios!}");
        print("SettingData parcelPerWeightCharge ==> ${model.data!.parcelPerWeightCharge!}");
        devlog("SettingData admin_commission ==> ${responseBody['data']['admin_commission'].toString()}");
        devlog("SettingData commision_type ==> ${responseBody['data']['commision_type'].toString()}");

        Preferences.setString(Preferences.deliverChargeParcel, model.data!.deliverChargeParcel!);
        Preferences.setString(Preferences.parcelPerWeightCharge, model.data!.parcelPerWeightCharge!);

        Constant.parcelPerWeightCharge = model.data!.parcelPerWeightCharge!;

        // Build tax list based on country
        List<TaxModel> countryTaxList = [];
        for (var i = 0; i < model.data!.taxModel!.length; i++) {
          if (placeMarks.first.country.toString().toUpperCase() == model.data!.taxModel![i].country!.toUpperCase()) {
            countryTaxList.add(model.data!.taxModel![i]);
          }
        }
        Constant.taxList = countryTaxList;

        devlog("===== FULL TAX MODEL LIST =====");
        for (var tax in model.data!.taxModel!) {
          devlog("Tax -> Country: ${tax.country}, "
              "Title: ${tax.statut}, "
              "Type: ${tax.type}, "
              "Value: ${tax.value}");
        }
        devlog("User Country ==> ${placeMarks.first.country}");
        devlog("Total Tax Received: ${model.data!.taxModel!.length}");
        devlog("Total Tax Applied: ${countryTaxList.length}");
        Constant.symbolAtRight = model.data!.symbolAtRight! == 'true';
        Constant.kGoogleApiKey = model.data!.googleMapApiKey!;

        Constant.contactUsEmail = model.data!.contactUsEmail!;
        Preferences.setString(Preferences.contactUsEmail, model.data!.contactUsEmail!);

        Constant.contactUsAddress = model.data!.contactUsAddress!;
        Preferences.setString(Preferences.contactUsAddress, model.data!.contactUsAddress!);

        Constant.contactUsPhone = model.data!.contactUsPhone!;
        Preferences.setString(Preferences.contactUsPhone, model.data!.contactUsPhone!);

        Constant.rideOtp = model.data!.showRideOtp!;
      } else {
        ShowToastDialog.showToast(responseBody['error']?.toString() ?? responseBody['message']?.toString() ?? 'Something went wrong. Please try again later');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
    }

    update();
    return null;
  }

  Future<RideSettings?> getRideSettingsData() async {
    try {
      final response = await LoggingClient(http.Client()).get(Uri.parse(API.rideSettings), headers: API.authheader);

      Map<String, dynamic> responseBody = json.safeDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "success") {
        RideSettings rideSettingsModel = RideSettings.fromJson(responseBody['data']);
        await Preferences.setRideSettings(rideSettingsModel);
        update();
        return rideSettingsModel;
      } else {
        ShowToastDialog.showToast(responseBody['error']?.toString() ?? responseBody['message']?.toString() ?? 'Something went wrong. Please try again later');
      }
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
    }

    update();
    return null;
  }

  Future<dynamic> getPaymentSettingData() async {
    try {
      final response = await LoggingClient(http.Client()).get(Uri.parse(API.paymentSetting), headers: API.header);

      log("Payment setting data SettingsController ${response.body}");

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
      // ShowToastDialog.closeLoader();
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
