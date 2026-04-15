// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:zocar/constant/constant.dart';
// import 'package:zocar/constant/show_toast_dialog.dart';
// import 'package:zocar/model/user_model.dart';
// import 'package:zocar/service/api.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
//
// class ParcelDetailsController extends GetxController {
//   @override
//   void onInit() {
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
//   Future<dynamic> rejectParcel(Map<String, String> bodyParams) async {
//     try {
//       ShowToastDialog.showLoader("Please wait");
//       final response = await LoggingClient(http.Client()).post(Uri.parse(API.parcelCanceled),
//           headers: API.header, body: jsonEncode(bodyParams));
//
//       Map<String, dynamic> responseBody = json.safeDecode(response.body);
//
//       if (response.statusCode == 200 && responseBody['success'] == "success") {
//         ShowToastDialog.closeLoader();
//         return responseBody;
//       } else if (response.statusCode == 200 &&
//           responseBody['success'] == "Failed") {
//         ShowToastDialog.closeLoader();
//         ShowToastDialog.showToast(responseBody['error']);
//       } else {
//         ShowToastDialog.closeLoader();
//         ShowToastDialog.showToast(
//             'Something went wrong. Please try again later');
//         throw Exception('Something went wrong.!');
//       }
//     } on TimeoutException catch (e) {
//       ShowToastDialog.closeLoader();
//       ShowToastDialog.showToast(e.message.toString());
//     } on SocketException catch (e) {
//       ShowToastDialog.closeLoader();
//       ShowToastDialog.showToast(e.message.toString());
//     } on Error catch (e) {
//       ShowToastDialog.closeLoader();
//       ShowToastDialog.showToast(e.toString());
//     }
//     ShowToastDialog.closeLoader();
//     return null;
//   }
//
//   Future<dynamic> canceledParcel(Map<String, String> bodyParams) async {
//     try {
//       ShowToastDialog.showLoader("Please wait");
//       final response = await LoggingClient(http.Client()).post(Uri.parse(API.parcelReject),
//           headers: API.header, body: jsonEncode(bodyParams));
//
//       Map<String, dynamic> responseBody = json.safeDecode(response.body);
//
//       if (response.statusCode == 200 && responseBody['success'] == "success") {
//         ShowToastDialog.closeLoader();
//         return responseBody;
//       } else if (response.statusCode == 200 &&
//           responseBody['success'] == "Failed") {
//         ShowToastDialog.closeLoader();
//         ShowToastDialog.showToast(responseBody['error']);
//       } else {
//         ShowToastDialog.closeLoader();
//         ShowToastDialog.showToast(
//             'Something went wrong. Please try again later');
//         throw Exception('Something went wrong.!');
//       }
//     } on TimeoutException catch (e) {
//       ShowToastDialog.closeLoader();
//       ShowToastDialog.showToast(e.message.toString());
//     } on SocketException catch (e) {
//       ShowToastDialog.closeLoader();
//       ShowToastDialog.showToast(e.message.toString());
//     } on Error catch (e) {
//       ShowToastDialog.closeLoader();
//       ShowToastDialog.showToast(e.toString());
//     }
//     ShowToastDialog.closeLoader();
//     return null;
//   }
// }
