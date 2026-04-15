import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/helpers/devlog.dart';
import 'package:zocar/model/coupan_code_model.dart';
import 'package:zocar/service/api.dart';

class CouponCodeController extends GetxController {
  var isLoading = true.obs;
  var coupanCodeList = <CoupanCodeData>[].obs;
  var rewardCoupanCodeList = <CoupanCodeData>[].obs;

  @override
  void onInit() {
    getCoupanCodeData();
    getRewardCoupanCodeData();
    super.onInit();
  }

  Future<dynamic> getCoupanCodeData() async {
    try {
      final response = await LoggingClient(http.Client()).get(Uri.parse(API.discountList), headers: API.header);
      final response2 = await LoggingClient(http.Client()).get(Uri.parse(API.rewardDiscountList), headers: API.header);

      Map<String, dynamic> responseBody = json.safeDecode(response.body);
      Map<String, dynamic> response2Body = json.safeDecode(response2.body);
      devlog("MyLogData CouponCodeData==> $responseBody");
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        isLoading.value = false;
        CoupanCodeModel model = CoupanCodeModel.fromJson(responseBody);
        coupanCodeList.value = model.data!;
      } else if (response.statusCode == 200 && responseBody['success'] == "Failed") {
        coupanCodeList.clear();
        isLoading.value = false;
      } else {
        ShowToastDialog.showToast('Something went wrong. Please try again later');
        throw Exception('Something went wrong.!');
      }
      if (response2.statusCode == 200 && response2Body['success'] == "success") {
        CoupanCodeModel model = CoupanCodeModel.fromJson(response2Body);
        coupanCodeList.value += model.data!;
      } else if (response2.statusCode == 200 && response2Body['success'] == "Failed") {
        // coupanCodeList.clear();
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
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    isLoading.value = false;
    return null;
  }

  Future<dynamic> getRewardCoupanCodeData() async {
    try {
      final response2 = await LoggingClient(http.Client()).get(Uri.parse("${API.rewardDiscountList}&type=both"), headers: API.header);
      Map<String, dynamic> response2Body = json.safeDecode(response2.body);
      if (response2.statusCode == 200 && response2Body['success'] == "success") {
        CoupanCodeModel model = CoupanCodeModel.fromJson(response2Body);
        rewardCoupanCodeList.value = model.data!;
        devlog("model dat length : ${model.data?.length}");
      } else if (response2.statusCode == 200 && response2Body['success'] == "Failed") {
        // coupanCodeList.clear();
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
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    isLoading.value = false;
    return null;
  }
}
