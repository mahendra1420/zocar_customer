import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:zocar/constant/constant.dart';
import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/helpers/devlog.dart';
import 'package:zocar/model/user_model.dart';
import 'package:zocar/service/api.dart';
import 'package:zocar/utils/preferences.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AddPhotoController extends GetxController {
  RxString image = "".obs;
  RxString idProofImage = "".obs;

  @override
  void onInit() {
    getUsrData();
    super.onInit();
  }

  String userCat = "";
  String? statusNic = "";

  getUsrData() async {
    UserModel userModel = Constant.getUserData();
    userCat = userModel.data!.userCat!;
    statusNic = userModel.data!.statutNic!;
  }

  Future<dynamic> uploadPhoto() async {
    try {
      ShowToastDialog.showLoader("Please wait");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(API.uploadUserPhoto),
      );
      request.headers.addAll(API.header);
      print("uploadPhoto id_user ==> ${Preferences.getInt(Preferences.userId).toString()}");
      print("uploadPhoto user_cat ==> ${userCat}");
      request.files.add(http.MultipartFile.fromBytes('image', File(image.value).readAsBytesSync(), filename: File(image.value).path.split('/').last));
      request.fields['id_user'] = Preferences.getInt(Preferences.userId).toString();
      request.fields['user_cat'] = userCat;

      var res = await request.send();

      var responseData = await res.stream.toBytes();
      devlog("String.fromCharCodes(responseData) :${String.fromCharCodes(responseData)}");
      Map<String, dynamic> response = jsonDecode(String.fromCharCodes(responseData));
      print("uploadPhoto ==> ${responseData}");
      if (res.statusCode == 200) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Uploaded!");
        return response;
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast('Something went wrong. Please try again later');
        throw Exception('Something went wrong.!');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
      print("uploadPhoto TimeoutException ==> ${e.message.toString()}");
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
      print("uploadPhoto SocketException ==> ${e.message.toString()}");
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
      print("uploadPhoto Error catch ==> ${e.toString()}");
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
      print("uploadPhoto catch ==> ${e.toString()}");
    }
  }

  Future<dynamic> uploadNicPhoto() async {
    try {
      ShowToastDialog.showLoader("Please wait");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(API.updateUserNic),
      );
      request.headers.addAll(API.header);

      request.files.add(http.MultipartFile.fromBytes('image', File(idProofImage.value).readAsBytesSync(), filename: File(idProofImage.value).path.split('/').last));
      request.fields['id_user'] = Preferences.getInt(Preferences.userId).toString();
      request.fields['user_cat'] = userCat;

      var res = await request.send();
      var responseData = await res.stream.toBytes();
      Map<String, dynamic> response = jsonDecode(String.fromCharCodes(responseData));
      if (res.statusCode == 200) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Uploaded!");
        return response;
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
  }
}
