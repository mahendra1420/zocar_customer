import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/model/user_model.dart';
import 'package:zocar/service/api.dart';
import 'package:zocar/utils/preferences.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SignUpController extends GetxController {
  Future<UserModel?> signUp(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await LoggingClient(http.Client()).post(Uri.parse(API.userSignUP), headers: API.authheader, body: jsonEncode(bodyParams));
      Map<String, dynamic> responseBody = json.safeDecode(response.body);
      print("SignUpController ==> ${responseBody}");
      if (response.statusCode == 200) {
        final user = UserModel.fromJson(responseBody);
          ShowToastDialog.closeLoader();
        if(user.success == "Failed"){
          ShowToastDialog.showToast(user.error?.toString() ?? 'Something went wrong. Please try again later');
        } else {
          Preferences.setString(Preferences.accesstoken, responseBody['data']?['accesstoken']?.toString() ?? '');
          Preferences.setString(Preferences.admincommission, responseBody['data']?['admin_commission']?.toString() ?? '');
          API.header['accesstoken'] = Preferences.getString(Preferences.accesstoken);
          return user;
        }
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast('Something went wrong. Please try again later');
        throw Exception('Something went wrong.!');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
      print("SignUpController TimeoutException ==> ${e.message.toString()}");
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
      print("SignUpController SocketException ==> ${e.message.toString()}");
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
      print("SignUpController Error catch ==> ${e.toString()}");
      log(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
      print("SignUpController catch ==> ${e.toString()}");
    }
    return null;
  }
}
