import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/service/api.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:http/http.dart' as http;

class TermsOfServiceController extends GetxController {
  @override
  void onInit() {
    getTermsOfService();

    super.onInit();
  }

  dynamic data;

  Future<dynamic> getTermsOfService() async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await LoggingClient(http.Client()).get(
        Uri.parse(API.termsOfCondition),
        headers: API.header,
      );
      Map<String, dynamic> responseBody = json.safeDecode(response.body);

      if (response.statusCode == 200) {
        data = responseBody['data']['terms'];
        ShowToastDialog.closeLoader();
        return responseBody;
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
    update();
    return null;
  }
}
