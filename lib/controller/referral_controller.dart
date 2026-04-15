import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/service/api.dart';
import 'package:zocar/utils/preferences.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as devlo;

class ReferralController extends GetxController {
  RxBool isLoading = false.obs;
  RxString referralCode = "".obs;
  RxString referralAmount = "".obs;

  @override
  void onInit() {
    getReferralAmount();
    super.onInit();
  }

  Future<dynamic> getReferralAmount() async {
    try {
      isLoading.value = true;
      final response = await LoggingClient(http.Client()).get(Uri.parse("${API.referralAmount}?id_user=${Preferences.getInt(Preferences.userId)}"), headers: API.header);
      Map<String, dynamic> responseBody = json.safeDecode(response.body);
      devlo.log(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "success") {
        isLoading.value = false;
        referralAmount.value = responseBody['data']['referral_amount'];
        referralCode.value = responseBody['data']['referral_code'];
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
}
