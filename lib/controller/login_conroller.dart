import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/controller/settings_controller.dart';
import 'package:zocar/helpers/widget_binding.dart';
import 'package:zocar/model/user_model.dart';
import 'package:zocar/service/api.dart';
import 'package:zocar/utils/preferences.dart';

import '../service/active_user_checker.dart';

class LoginController extends GetxController {
  Future<UserModel?> loginAPI(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await LoggingClient(http.Client()).post(Uri.parse(API.userLogin), headers: API.authheader, body: jsonEncode(bodyParams));

      Map<String, dynamic> responseBody = json.safeDecode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "Success") {
        ShowToastDialog.closeLoader();
        Preferences.setString(Preferences.accesstoken, responseBody['data']['accesstoken'].toString());
        Preferences.setInt(Preferences.userId, int.tryParse(responseBody['data']['id'].toString()) ?? 0);
        Preferences.setString(Preferences.admincommission, responseBody['data']['admin_commission'].toString());
        SettingsController settingsController = Get.put(SettingsController());
        settingsController.getSettingsData();
        API.header['accesstoken'] = Preferences.getString(Preferences.accesstoken);
        return UserModel.fromJson(responseBody);
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
    return null;
  }
}
