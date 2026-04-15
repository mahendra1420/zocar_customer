import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/service/api.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordController extends GetxController {
  Future<bool?> sendEmail(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await LoggingClient(http.Client()).post(Uri.parse(API.sendResetPasswordOtp), headers: API.header, body: jsonEncode(bodyParams));
      // final response = await LoggingClient(http.Client()).post(Uri.parse(API.resetPasswordOtp), headers: API.header, body: jsonEncode(bodyParams));
      Map<String, dynamic> responseBody = json.safeDecode(response.body);
      print("ForgotPasswordController responseBody ==> $responseBody");
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.closeLoader();
        return true;
      } else if (response.statusCode == 200 && responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(responseBody['error']);
        print("ForgotPasswordController responseBody['error'] ==> ${responseBody['error']}");
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast('Something went wrong. Please try again later');
        throw Exception(responseBody['data']?['message']?.toString() ?? responseBody['error']?.toString() ?? responseBody['message']?.toString() ?? 'Something went wrong.!');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
      print("ForgotPasswordController TimeoutException ==> ${e.message.toString()}");
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
      print("ForgotPasswordController SocketException ==> ${e.message.toString()}");
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
      print("ForgotPasswordController Error catch ==> ${e.toString()}");
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
      print("ForgotPasswordController catch ==> ${e.toString()}");
    }
    return null;
  }

  Future<bool?> resetPassword(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await LoggingClient(http.Client()).post(Uri.parse(API.resetPasswordOtp), headers: API.header, body: jsonEncode(bodyParams));

      Map<String, dynamic> responseBody = json.safeDecode(response.body);
      print("ForgotPasswordController ResetPassword responseBody ==> ${responseBody}");
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.closeLoader();
        return true;
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
      print("ForgotPasswordController ResetPassword TimeoutException ==> ${e.message.toString()}");
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
      print("ForgotPasswordController ResetPassword SocketException ==> ${e.message.toString()}");
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
      print("ForgotPasswordController ResetPassword Error catch ==> ${e.toString()}");
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
      print("ForgotPasswordController ResetPassword catch ==> ${e.toString()}");
    }
    return null;
  }
}
