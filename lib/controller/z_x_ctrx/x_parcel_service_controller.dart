// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:zocar/constant/constant.dart';
// import 'package:zocar/constant/show_toast_dialog.dart';
// import 'package:zocar/controller/main_page_controller.dart';
// import 'package:zocar/model/parcel_category_model.dart';
// import 'package:zocar/model/parcel_model.dart';
// import 'package:zocar/model/payment_setting_model.dart';
// import 'package:zocar/page/main_page.dart';
// import 'package:zocar/service/api.dart';
// import 'package:zocar/utils/Preferences.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
//
// class ParcelServiceController extends GetxController {
//   var parcelList = <ParcelData>[].obs;
//   RxList<ParcelCategoryData> parcelCategoryList = <ParcelCategoryData>[].obs;
//   var isLoading = true.obs;
//
//   RxString selectedParcelCategoryId = "".obs;
//
//   TextEditingController sNameController = TextEditingController();
//
//   TextEditingController sPhoneController = TextEditingController();
//   TextEditingController parcelWeightController = TextEditingController();
//   TextEditingController parcelDimentionController = TextEditingController();
//   TextEditingController noteController = TextEditingController();
//
//   TextEditingController rNameController = TextEditingController();
//   TextEditingController rPhoneController = TextEditingController();
//
//   RxString senderAddress = "".obs;
//   RxString receiverAddress = "".obs;
//   RxString senderAddressCity = "".obs;
//   RxString receiverAddressCity = "".obs;
//
//   LatLng? senderLocation;
//   LatLng? receiverLocation;
//
//   var paymentSettingModel = PaymentSettingModel().obs;
//
//   DateTime selectedDatePickUp = DateTime.now();
//   RxString senderDate =
//       "".obs; //DateFormat('yyyy-MM-dd').format(DateTime.now());
//
//   DateTime selectedDateDeliver = DateTime.now();
//   RxString receiverDate = "".obs;
//
//   TimeOfDay selectedTimePickUp = TimeOfDay.now();
//   RxString senderTime = "".obs;
//
//   TimeOfDay selectedTimeDeliver = TimeOfDay.now();
//   RxString receiverTime = "".obs;
//
//   RxDouble distance = 0.0.obs;
//   RxDouble subTotal = 0.0.obs;
//   RxString duration = "".obs;
//
//   RxBool cash = false.obs;
//   RxBool wallet = false.obs;
//   RxBool stripe = false.obs;
//   RxBool razorPay = false.obs;
//   RxBool payTm = false.obs;
//   RxBool paypal = false.obs;
//   RxBool payStack = false.obs;
//   RxBool flutterWave = false.obs;
//   RxBool mercadoPago = false.obs;
//   RxBool payFast = false.obs;
//   RxString paymentMethodType = "Select Method".obs;
//   RxString paymentMethodId = "".obs;
//
//   List<XFile> parcelImages = [];
//   @override
//   void onInit() {
//     getParcelCategory();
//     paymentSettingModel.value = Constant.getPaymentSetting();
//     // getArgument();
//     getParcel();
//     getCurrentLocation();
//     super.onInit();
//   }
//
//   getCurrentLocation() async {
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//     senderLocation = LatLng(position.latitude, position.longitude);
//     receiverLocation = LatLng(position.latitude, position.longitude);
//     senderAddress.value = await getAddressFromLatLong(position);
//     receiverAddress.value = await getAddressFromLatLong(position);
//
//     await getAddressFromLatLong(position).then((value) {
//       senderAddressCity.value = value.toString().split(",").last.trim();
//       receiverAddressCity.value = value.toString().split(",").last.trim();
//     });
//   }
//
//   Future<String> getAddressFromLatLong(Position position) async {
//     List<Placemark> placemarks =
//         await placemarkFromCoordinates(position.latitude, position.longitude);
//
//     Placemark place = placemarks[0];
//
//     return '${place.subLocality}, ${place.locality}';
//   }
//
//   // getArgument() async {
//   //   dynamic argumentData = Get.arguments;
//   //   print("========$argumentData");
//   //   if (argumentData != null) {
//   //     selectedCategory.value = argumentData["title"];
//   //   }
//   //   update();
//   // }
//
//   Future<GetParcelCategoryModel?> getParcelCategory() async {
//     try {
//       final response =
//           await LoggingClient(http.Client()).get(Uri.parse(API.getParcelCategory), headers: API.header);
//
//       Map<String, dynamic> responseBody = json.safeDecode(response.body);
//
//       if (response.statusCode == 200 && responseBody['success'] == "success") {
//         update();
//         isLoading.value = false;
//         GetParcelCategoryModel data =
//             GetParcelCategoryModel.fromJson(responseBody);
//         parcelCategoryList.value = data.data!;
//         selectedParcelCategoryId.value = parcelCategoryList[0].id.toString();
//         return GetParcelCategoryModel.fromJson(responseBody);
//       } else {
//         isLoading.value = false;
//         ShowToastDialog.showToast(
//             'Something went wrong. Please try again later');
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
//       isLoading.value = false;
//       ShowToastDialog.showToast(e.toString());
//     }
//     return null;
//   }
//
//   Future<dynamic> getDurationDistance(
//       LatLng departureLatLong, LatLng destinationLatLong) async {
//     ShowToastDialog.showLoader("Please wait");
//     double originLat, originLong, destLat, destLong;
//     originLat = departureLatLong.latitude;
//     originLong = departureLatLong.longitude;
//     destLat = destinationLatLong.latitude;
//     destLong = destinationLatLong.longitude;
//
//     String url = 'https://maps.googleapis.com/maps/api/distancematrix/json';
//     http.Response restaurantToCustomerTime = await LoggingClient(http.Client()).get(Uri.parse(
//         '$url?units=metric&origins=$originLat,'
//         '$originLong&destinations=$destLat,$destLong&key=${Constant.kGoogleApiKey}'));
//
//     var decodedResponse = jsonDecode(restaurantToCustomerTime.body);
//
//     if (decodedResponse['status'] == 'OK' &&
//         decodedResponse['rows'].first['elements'].first['status'] == 'OK') {
//       ShowToastDialog.closeLoader();
//       if (decodedResponse != null) {
//         if (Constant.distanceUnit == "KM") {
//           distance.value = decodedResponse['rows']
//                   .first['elements']
//                   .first['distance']['value'] /
//               1000.00;
//         } else {
//           distance.value = decodedResponse['rows']
//                   .first['elements']
//                   .first['distance']['value'] /
//               1609.34;
//         }
//
//         duration.value = decodedResponse['rows']
//             .first['elements']
//             .first['duration']['text']
//             .toString();
//       }
//
//       subTotal.value = (distance.value *
//               double.parse(Preferences.getString(Preferences.deliverChargeParcel))) +
//           (double.parse(parcelWeightController.text.toString()) *
//               double.parse(Preferences.getString(Preferences.parcelPerWeightCharge)));
//       return decodedResponse;
//     }
//     ShowToastDialog.closeLoader();
//     return null;
//   }
//
//   Future<dynamic> getParcel() async {
//     try {
//       final response = await LoggingClient(http.Client()).get(
//           Uri.parse(
//               "${API.getParcel}?id_user_app=${Preferences.getInt(Preferences.userId)}"),
//           headers: API.header);
//       Map<String, dynamic> responseBody = json.safeDecode(response.body);
//       // print("MyParcelList ==> ${responseBody}");
//       // print("MyParcelList Url ==> ${"${API.getParcel}?id_user_app=${Preferences.getInt(Preferences.userId)}"}");
//       if (response.statusCode == 200 &&
//           responseBody['success'].toString() == "success") {
//         isLoading.value = false;
//         ParcelModel model = ParcelModel.fromJson(responseBody);
//         parcelList.value = model.data!;
//         Future.delayed(const Duration(seconds: 5), () {
//           getParcel();
//         });
//       } else if (response.statusCode == 200 &&
//           responseBody['success'] == "Failed") {
//         parcelList.clear();
//         isLoading.value = false;
//         Future.delayed(const Duration(seconds: 5), () {
//           getParcel();
//         });
//       } else {
//         isLoading.value = false;
//         // ShowToastDialog.showToast(
//         //     'Something went wrong. Please try again later');
//         Future.delayed(const Duration(seconds: 5), () {
//           getParcel();
//         });
//         // throw Exception('Something went wrong.!');
//       }
//     } on TimeoutException catch (e) {
//       isLoading.value = false;
//       print("ParcelScreen SocketException catch ==> ${e.message.toString()}");
//       Future.delayed(const Duration(seconds: 5), () {
//         getParcel();
//       });
//     } on SocketException catch (e) {
//       isLoading.value = false;
//       print("ParcelScreen SocketException catch ==> ${e.message.toString()}");
//       Future.delayed(const Duration(seconds: 5), () {
//         getParcel();
//       });
//       // ShowToastDialog.showToast(e.message.toString());
//     } on Error catch (e) {
//       print("MyParcelList ==> ${e.toString()}");
//       isLoading.value = false;
//       Future.delayed(const Duration(seconds: 5), () {
//         getParcel();
//       });
//     } catch (e) {
//       isLoading.value = false;
//       ShowToastDialog.closeLoader();
//       print("MyParcelList ==> ${e.toString()}");
//       Future.delayed(const Duration(seconds: 5), () {
//         getParcel();
//       });
//       // ShowToastDialog.showToast(e.toString());
//     }
//     return null;
//   }
//
//   bookParcelRide() async {
//     try {
//       ShowToastDialog.showLoader("Please wait");
//
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse(API.bookParcel),
//       );
//       request.headers.addAll(API.header);
//       for (var i = 0; i < parcelImages.length; i++) {
//         request.files.add(http.MultipartFile.fromBytes(
//             'parcel_image[]', File(parcelImages[i].path).readAsBytesSync(),
//             filename: parcelImages[i].path.split('/').last));
//       }
//
//       request.fields['user_id'] =
//           Preferences.getInt(Preferences.userId).toString();
//
//       request.fields['lat1'] = senderLocation!.latitude.toString();
//
//       request.fields['lng1'] = senderLocation!.longitude.toString();
//       request.fields['lat2'] = receiverLocation!.latitude.toString();
//       request.fields['lng2'] = receiverLocation!.longitude.toString();
//
//       request.fields['source_city'] = senderAddressCity.value.toString().trim();
//       request.fields['destination_city'] = receiverAddressCity.value.trim();
//
//       request.fields['distance'] = distance.value.toString();
//       request.fields['distance_unit'] = Constant.distanceUnit.toString();
//
//       request.fields['id_payment'] = paymentMethodId.value.toString();
//       request.fields['source_adrs'] = senderAddress.toString().trim();
//
//       request.fields['destination_adrs'] = receiverAddress.toString().trim();
//       request.fields['sender_name'] = sNameController.text.toString().trim();
//       request.fields['receiver_name'] = rNameController.text.toString().trim();
//       request.fields['sender_phone'] = sPhoneController.text.toString().trim();
//       request.fields['receiver_phone'] =
//           rPhoneController.text.toString().trim();
//       request.fields['note'] = noteController.text.toString().trim();
//       request.fields['parcel_weight'] =
//           parcelWeightController.text.trim().toString();
//       request.fields['parcel_dimension'] =
//           parcelDimentionController.text.trim().toString();
//
//       request.fields['parcel_type'] = selectedParcelCategoryId.toString();
//       request.fields['parcel_date'] = senderDate.value.toString();
//       request.fields['parcel_time'] = senderTime.value.toString();
//       request.fields['receive_date'] = receiverDate.value.toString();
//       request.fields['receive_time'] = receiverTime.value.toString();
//       request.fields['amount'] = subTotal.value.toString();
//       request.fields['duration'] = duration.value.toString();
//
//       var res = await request.send();
//       var responseData = await res.stream.toBytes();
//
//       Map<String, dynamic> response =
//           jsonDecode(String.fromCharCodes(responseData));
//       print("ParcelScreen responseData ==> ${response}");
//       if (res.statusCode == 200) {
//         ShowToastDialog.closeLoader();
//         MainPageController dashBoardController =
//             Get.put(MainPageController());
//         dashBoardController.selectedDrawerIndex.value = 6;
//         await Get.to(MainPage());
//         return response;
//       }
//       else {
//         ShowToastDialog.closeLoader();
//         ShowToastDialog.showToast(
//             'Something went wrong. Please try again later');
//         throw Exception('Something went wrong.!');
//       }
//     } on TimeoutException catch (e) {
//       ShowToastDialog.closeLoader();
//       ShowToastDialog.showToast(e.message.toString());
//       print("ParcelScreen TimeoutException catch ==> ${e.message.toString()}");
//     } on SocketException catch (e) {
//       ShowToastDialog.closeLoader();
//       ShowToastDialog.showToast(e.message.toString());
//       print("ParcelScreen SocketException catch ==> ${e.message.toString()}");
//     } on Error catch (e) {
//       ShowToastDialog.closeLoader();
//       ShowToastDialog.showToast(e.toString());
//       print("ParcelScreen Error catch  ==> ${e.toString()}");
//     } catch (e) {
//       ShowToastDialog.closeLoader();
//       ShowToastDialog.showToast(e.toString());
//       print("ParcelScreen catch ==> ${e.toString()}");
//     }
//   }
//
//   onCameraClick(context) {
//     final action = CupertinoActionSheet(
//       message: Text(
//         'Add your parcel image.'.tr,
//         style: const TextStyle(fontSize: 15.0),
//       ),
//       actions: <Widget>[
//         CupertinoActionSheetAction(
//           isDefaultAction: false,
//           onPressed: () async {
//             Navigator.pop(context);
//             await ImagePicker().pickMultiImage(maxWidth: 250 , maxHeight: 250).then((value) {
//               for (var element in value) {
//                 parcelImages.add(element);
//               }
//             });
//           },
//           child: Text('Choose image from gallery'.tr),
//         ),
//         CupertinoActionSheetAction(
//           isDestructiveAction: false,
//           onPressed: () async {
//             Get.back();
//             final XFile? photo =
//                 await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 250 , maxHeight: 250);
//             if (photo != null) {
//               parcelImages.add(photo);
//             }
//           },
//           child: Text('Take a picture'.tr),
//         ),
//       ],
//       cancelButton: CupertinoActionSheetAction(
//         child: Text(
//           'Cancel'.tr,
//         ),
//         onPressed: () {
//           Get.back();
//         },
//       ),
//     );
//     showCupertinoModalPopup(context: context, builder: (context) => action);
//   }
//
//   selectDate(BuildContext context, {bool isPickUp = true}) async {
//     final DateTime? picked = await showDatePicker(
//         context: context,
//         initialDate: selectedDatePickUp,
//         initialDatePickerMode: DatePickerMode.day,
//         firstDate: selectedDatePickUp,
//         lastDate: DateTime(2101));
//     if (picked != null) {
//       if (isPickUp) {
//         selectedDatePickUp = picked;
//
//         senderDate.value = DateFormat('dd-MMM-yyyy').format(selectedDatePickUp);
//       } else {
//         selectedDateDeliver = picked;
//
//         receiverDate.value =
//             DateFormat('dd-MMM-yyyy').format(selectedDateDeliver);
//       }
//     }
//   }
//
//   selectTime(BuildContext context, {bool isPickUp = true}) async {
//     final localizations = MaterialLocalizations.of(context);
//
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: selectedTimePickUp,
//     );
//     if (picked != null) {
//       if (isPickUp) {
//         selectedTimePickUp = picked;
//         senderTime.value = localizations.formatTimeOfDay(selectedTimePickUp);
//       } else {
//         selectedTimeDeliver = picked;
//         receiverTime.value = localizations.formatTimeOfDay(selectedTimeDeliver);
//       }
//     }
//   }
// }
