// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
//
// import 'package:zocar/constant/constant.dart';
// import 'package:zocar/constant/show_toast_dialog.dart';
// import 'package:zocar/model/ride_model.dart';
// import 'package:zocar/model/user_model.dart';
// import 'package:zocar/service/api.dart';
// import 'package:zocar/utils/Preferences.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
//
// class OnRideController extends GetxController {
//   var isLoading = true.obs;
//   var rideList = <RideData>[].obs;
//
//   @override
//   void onInit() {
//     getOnRide();
//     getUsrData();
//     super.onInit();
//   }
//
//   UserModel? userModel;
//
//   getUsrData() {
//     userModel = Constant.getUserData();
//   }
//
//   Future<dynamic> getOnRide() async {
//     try {
//       final response = await LoggingClient(http.Client()).get(Uri.parse("${API.onRide}?id_user_app=${Preferences.getInt(Preferences.userId)}"), headers: API.header);
//       log(response.body);
//       Map<String, dynamic> responseBody = json.safeDecode(response.body);
//       if (response.statusCode == 200 && responseBody['success'] == "success") {
//         isLoading.value = false;
//         RideModel model = RideModel.fromJson(responseBody);
//         rideList.value = model.data!;
//       } else if (response.statusCode == 200 && responseBody['success'] == "Failed") {
//         rideList.clear();
//         isLoading.value = false;
//       } else {
//         isLoading.value = false;
//         ShowToastDialog.showToast('Something went wrong. Please try again later');
//         throw Exception('Something went wrong.!');
//       }
//     } on TimeoutException catch (e) {
//       log("->1${e.message}");
//       isLoading.value = false;
//       ShowToastDialog.showToast(e.message.toString());
//     } on SocketException catch (e) {
//       log("->2${e.message}");
//
//       isLoading.value = false;
//       ShowToastDialog.showToast(e.message.toString());
//     } on Error catch (e) {
//       log("->3$e");
//
//       isLoading.value = false;
//       ShowToastDialog.showToast(e.toString());
//     } catch (e) {
//       log("->4$e");
//       ShowToastDialog.closeLoader();
//       ShowToastDialog.showToast(e.toString());
//     }
//     return null;
//   }
// }
