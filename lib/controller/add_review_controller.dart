import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/model/parcel_model.dart';
import 'package:zocar/model/review_model.dart';
import 'package:zocar/model/ride_model.dart';
import 'package:zocar/service/api.dart';
import 'package:zocar/utils/preferences.dart';

class AddReviewController extends GetxController {
  var rating = 4.0.obs;
  final reviewCommentController = TextEditingController().obs;

  @override
  void onInit() {
    getArgument();
    getReview();
    super.onInit();
  }

  var rideData = RideData().obs;
  var parcelData = ParcelData().obs;
  var ratingModel = ReviewModel().obs;
  RxString rideType = "ride".obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      rideType.value = argumentData["ride_type"];
      if (argumentData["ride_type"].toString() == "ride") {
        rideData.value = argumentData["data"];
      } else {
        parcelData.value = argumentData["data"];
      }
    }
    update();
  }

  var isLoading = true.obs;

  Future<dynamic> getReview() async {
    try {
      final response = await LoggingClient(http.Client()).get(
          Uri.parse(
              "${API.getRideReview}?user_id=${Preferences.getInt(Preferences.userId)}&ride_id=${rideType.value.toString() == "ride" ? rideData.value.id : parcelData.value.id}&review_of=driver&ride_type=${rideType.value}"),
          headers: API.header);

      Map<String, dynamic> responseBody = json.safeDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "Success") {
        isLoading.value = false;
        ReviewModel model = ReviewModel.fromJson(responseBody);
        ratingModel.value = model;
        rating.value = double.parse(model.data!.niveau!);
        reviewCommentController.value.text = model.data!.comment.toString();
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
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Future<(bool?, List)> addReview(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await LoggingClient(http.Client()).post(Uri.parse(API.addReview), headers: API.headerForReview, body: jsonEncode(bodyParams));

      Map<String, dynamic> responseBody = json.safeDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "Success") {
        ShowToastDialog.closeLoader();
        final List<dynamic>? couponJson = responseBody['assigned_coupons'];

        return (true, (couponJson ?? []));
      } else if (response.statusCode == 200 && responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(responseBody['error']);
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast('Something went wrong. Please try again later');
        throw Exception('Something went wrong.!');
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
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return (null, []);
  }
}
