import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/model/favorite_model.dart';
import 'package:zocar/service/api.dart';
import 'package:zocar/utils/preferences.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class FavoriteController extends GetxController {
  var isLoading = true.obs;
  var favouriteList = <Data>[].obs;

  @override
  void onInit() {
    favouriteData();
    super.onInit();
  }

  Future<dynamic> favouriteData() async {
    try {
      final response = await LoggingClient(http.Client()).get(Uri.parse("${API.favorite}?id_user_app=${Preferences.getInt(Preferences.userId)}"), headers: API.header);

      log(response.request.toString());
      log(response.body);
      Map<String, dynamic> responseBody = json.safeDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "Success") {
        isLoading.value = false;
        FavoriteModel model = FavoriteModel.fromJson(responseBody);
        favouriteList.value = model.data!;
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

  Future<dynamic> deleteFavouriteRide(String favId) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await LoggingClient(http.Client()).get(Uri.parse("${API.deleteFavouriteRide}?id_ride_fav=$favId"), headers: API.header);

      Map<String, dynamic> responseBody = json.safeDecode(response.body);
      if (response.statusCode == 200) {
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
    return null;
  }
}
