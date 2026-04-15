// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
//
// import 'package:zocar/constant/show_toast_dialog.dart';
// import 'package:zocar/helpers/loader.dart';
// import 'package:zocar/model/rent_vehicle_model.dart';
// import 'package:zocar/service/api.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
//
// class RentVehicleController extends GetxController {
//   var rentVehicleList = <RentVehicleData>[].obs;
//   var isLoading = true.obs;
//   var startDate = DateTime.now().obs;
//   var endDate = DateTime.now().obs;
//
//   @override
//   void onInit() {
//     getRentVehicle();
//     super.onInit();
//   }
//
//   Future<dynamic> getRentVehicle() async {
//     try {
//       final response = await LoggingClient(http.Client()).get(Uri.parse(API.rentVehicle), headers: API.header);
//
//       log(response.request.toString());
//       log(response.body);
//       Map<String, dynamic> responseBody = json.safeDecode(response.body);
//
//       if (response.statusCode == 200 && responseBody['success'] == "success") {
//         isLoading.value = false;
//         RentVehicleModel model = RentVehicleModel.fromJson(responseBody);
//         rentVehicleList.value = model.data!;
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
//       log(e.toString());
//       isLoading.value = false;
//       ShowToastDialog.showToast(e.message.toString());
//     } on Error catch (e) {
//       log(e.toString());
//       isLoading.value = false;
//       ShowToastDialog.showToast(e.toString());
//     } catch (e) {
//       log(e.toString());
//       ShowToastDialog.closeLoader();
//       ShowToastDialog.showToast(e.toString());
//     }
//     return null;
//   }
//
//   Future<dynamic> bookRentalVehicle(BuildContext context, Map<String, dynamic> bodyParams) async {
//     try {
//       showLoader(context);
//       final response = await LoggingClient(http.Client()).post(Uri.parse(API.bookRentalVehicle), headers: API.header, body: jsonEncode(bodyParams));
//       hideLoader();
//       Map<String, dynamic> responseBody = json.safeDecode(response.body);
//       if (response.statusCode == 200 && responseBody['success'] == "success") {
//         return responseBody;
//       } else if (response.statusCode == 200 && responseBody['success'] == "Failed") {
//         ShowToastDialog.showToast(responseBody['error']);
//       } else {
//         ShowToastDialog.showToast('Something went wrong. Please try again later');
//         throw Exception('Something went wrong.!');
//       }
//     } on TimeoutException catch (e) {
//       ShowToastDialog.showToast(e.message.toString());
//     } on SocketException catch (e) {
//       ShowToastDialog.showToast(e.message.toString());
//     } catch (e) {
//       ShowToastDialog.showToast(e.toString());
//     }
//     return null;
//   }
// }
