import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/model/user_model.dart';
import 'package:zocar/page/auth_screens/otp_screen.dart';
import 'package:zocar/service/api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class PhoneNumberController extends GetxController {
  RxString phoneNumber = "".obs;
  RxBool phoneNumberValid = false.obs;

  sendCodeFireBase(String phoneNumber) async {
    await FirebaseAuth.instance
        .verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        ShowToastDialog.closeLoader();
        if (e.code == 'invalid-phone-number') {
          ShowToastDialog.showToast("The provided phone number is not valid.");
        } else {
          ShowToastDialog.showToast(e.code.toString());
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        ShowToastDialog.closeLoader();
        Get.to(OtpScreen(
          phoneNumber: phoneNumber,
          verificationId: verificationId,
        ));
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    )
        .catchError((error) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(
          "You have try many time please send otp after some time");
    });
  }


  sendCode(String phoneNumber) async {
    try {
      Map<String, String> bodyParams = {
        'mobile': phoneNumber.toString(),
        'type': "customer",
      };
      ShowToastDialog.showLoader("Please wait");
      final response = await LoggingClient(http.Client()).post(Uri.parse(API.userLoginOtp),
          headers: API.authheader, body: jsonEncode(bodyParams));
      print("phoneNumberIsExit phoneNumberIsExit ==> ${response.body.toString()}");
      Map<String, dynamic> responseBody = json.safeDecode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.closeLoader();
        Get.to(OtpScreen(
          phoneNumber: phoneNumber,
          verificationId: "customer",
        ));
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(responseBody['error']);
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
            'Something went wrong. Please try again later');
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

  sendVerifyCode(String otp) async {
    try {
      Map<String, String> bodyParams = {
        'mobile': phoneNumber.toString(),
        'type': "customer",
        'otp': otp,
      };
      ShowToastDialog.showLoader("Please wait");
      final response = await LoggingClient(http.Client()).post(Uri.parse(API.userLoginVerifyOtp),
          headers: API.authheader, body: jsonEncode(bodyParams));
      print("phoneNumberIsExit phoneNumberIsExit ==> ${response.body.toString()}");
      Map<String, dynamic> responseBody = json.safeDecode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.closeLoader();
        return true;
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(responseBody['error']);
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
            'Something went wrong. Please try again later');
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
    return false;
  }

  Future<bool?> phoneNumberIsExit(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await LoggingClient(http.Client()).post(Uri.parse(API.getExistingUserOrNot),
          headers: API.authheader, body: jsonEncode(bodyParams));
      print("phoneNumberIsExit phoneNumberIsExit ==> ${response.body.toString()}");
      Map<String, dynamic> responseBody = json.safeDecode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.closeLoader();
        if (responseBody['data'] == true) {
          return true;
        } else {
          return false;
        }
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(responseBody['error']);
        return false;
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
            'Something went wrong. Please try again later');
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

  Future<UserModel?> getDataByPhoneNumber(
      Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await LoggingClient(http.Client()).post(Uri.parse(API.getProfileByPhone),
          headers: API.header, body: jsonEncode(bodyParams));
      print("phoneNumberIsExit getDataByPhoneNumber ==> ${response.body.toString()}");
      Map<String, dynamic> responseBody = json.safeDecode(response.body);
      print("MyLogData DataByPhoneNumber Customer ==> $responseBody");
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.closeLoader();
        return UserModel.fromJson(responseBody);
      } else if (response.statusCode == 200 &&
          responseBody['success'] == "Failed") {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(responseBody['error']);
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast(
            'Something went wrong. Please try again later');
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
