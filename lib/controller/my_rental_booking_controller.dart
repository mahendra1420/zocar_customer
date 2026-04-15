import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constant/logdata.dart';
import '../constant/show_toast_dialog.dart';
import '../helpers/devlog.dart';
import '../model/my_rental_booking.dart';
import '../model/vehicles_by_package.dart';
import '../service/active_user_checker.dart';
import '../service/api.dart';

class MyRentalBookingController extends GetxController {

  var isLoading = true.obs;
  var isLoadingVehicle = true.obs;
  var rideList = <PackageData>[].obs;
  var vehiclesData = <VehiclesData>[].obs;
  var latitude = "";
  var longitude = "";
  var rentalPackageId = "";
  var vehicleId = "";
  RxString selectedVehicle = "".obs;

  Future<dynamic> getPackagesData() async {
    try {
      final response = await LoggingClient(http.Client()).get(Uri.parse(API.getRidePackagesData) , headers: API.header);
      devlog("getPackagesData Response ==> ${response.body.toString()}");
      Map<String, dynamic> responseBody = json.safeDecode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        MyRentalBooking model = MyRentalBooking.fromJson(responseBody);
        rideList.value = model.data!;
        isLoading.value = false;
        if (rideList.isNotEmpty) {
          rentalPackageId = rideList.first.id.toString();
          getVehiclesByPackage(rideList.first.id.toString());
        }
      } else if (response.statusCode == 200 && responseBody['success'] == "Failed") {
        isLoading.value = false;
      } else {
        isLoading.value = false;
        ShowToastDialog.showToast('Something went wrong. Please try again later');
        throw Exception('Something went wrong.!');
      }
    } on TimeoutException catch (e) {
      isLoading.value = false;
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      isLoading.value = false;
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      isLoading.value = false;
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      log('FireStoreUtils.getCurrencys Parse error $e');
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Future<dynamic> getVehiclesByPackage(String packageId) async {
    isLoadingVehicle.value = true;
    try {
      Map<String, String> bodyParams = {};
      bodyParams = {
        'package_id': packageId,
        'latitude': latitude,
        'longitude': longitude,
      };
      devlog("getVehiclesByPackage Response ==> ${bodyParams.toString()}");
      final response = await LoggingClient(http.Client()).post(Uri.parse(API.getVehiclesByPackage) , body: jsonEncode(bodyParams) ,  headers: API.header);
      devlog("getVehiclesByPackage Response ==> ${response.body.toString()}");
      Map<String, dynamic> responseBody = json.safeDecode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        VehiclesByPackage model = VehiclesByPackage.fromJson(responseBody);
        vehiclesData.value = model.data!;
        showLog("neon -> getVehiclesByPackage response ==> $responseBody");
      } else if (response.statusCode == 200 && responseBody['success'] == "Failed") {
        ///
        vehiclesData.value = [];
      } else {
        ShowToastDialog.showToast('Something went wrong. Please try again later');
        throw Exception('Something went wrong.!');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      log('FireStoreUtils.getCurrencys Parse error $e');
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    } finally {
      isLoadingVehicle.value = false;
    }
    return null;
  }

}
