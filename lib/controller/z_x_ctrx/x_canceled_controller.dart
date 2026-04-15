// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:zocar/constant/show_toast_dialog.dart';
// import 'package:zocar/model/ride_model.dart';
// import 'package:zocar/service/api.dart';
// import 'package:zocar/utils/Preferences.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
//
// class CanceledController extends GetxController {
//   var isLoading = true.obs;
//   var rideList = <RideData>[].obs;
//
//   @override
//   void onInit() {
//     getCanceledRide();
//     super.onInit();
//   }
//
//   Future<dynamic> getCanceledRide() async {
//     try {
//       final response = await LoggingClient(http.Client()).get(Uri.parse("${API.canceledRide}?id_user_app=${Preferences.getInt(Preferences.userId)}"), headers: API.header);
//
//       Map<String, dynamic> responseBody = json.safeDecode(response.body);
//       if (response.statusCode == 200 && responseBody['success'] == "Success") {
//         isLoading.value = false;
//         RideModel model = RideModel.fromJson(responseBody);
//         rideList.value = model.data!;
//       } else if (response.statusCode == 200 && responseBody['success'] == "Failed") {
//         isLoading.value = false;
//       } else {
//         isLoading.value = false;
//         ShowToastDialog.showToast('Something went wrong. Please try again later');
//         throw Exception('Something went wrong.!');
//       }
//     } on TimeoutException catch (e) {
//       isLoading.value = false;
//       ShowToastDialog.showToast(e.message.toString());
//     } on SocketException catch (e) {
//       isLoading.value = false;
//       ShowToastDialog.showToast(e.message.toString());
//     } on Error catch (e) {
//       isLoading.value = false;
//       ShowToastDialog.showToast(e.toString());
//     } catch (e) {
//       ShowToastDialog.closeLoader();
//       ShowToastDialog.showToast(e.toString());
//     }
//     return null;
//   }
// }
