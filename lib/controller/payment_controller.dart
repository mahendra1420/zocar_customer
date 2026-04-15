import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:zocar/constant/constant.dart';
import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/model/coupan_code_model.dart';
import 'package:zocar/model/payment_setting_model.dart';
import 'package:zocar/model/ride_details_model.dart';
import 'package:zocar/model/ride_model.dart';
import 'package:zocar/model/tax_model.dart';
import 'package:zocar/model/user_model.dart';
import 'package:zocar/service/api.dart';
import 'package:zocar/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../helpers/devlog.dart';

class PaymentController extends GetxController {
  var paymentSettingModel = PaymentSettingModel().obs;
  var walletAmount = "0.0".obs;
  TextEditingController couponCodeController = TextEditingController();
  TextEditingController tripAmountTextFieldController = TextEditingController();

  RxBool cash = false.obs;
  RxBool wallet = false.obs;
  RxBool stripe = false.obs;
  RxBool razorPay = false.obs;
  RxBool payTm = false.obs;
  RxBool paypal = false.obs;
  RxBool payStack = false.obs;
  RxBool flutterWave = false.obs;
  RxBool mercadoPago = false.obs;
  RxBool payFast = false.obs;

  @override
  void onInit() {
    getArgument();
    getCoupanCodeData();
    getUsrData();
    paymentSettingModel.value = Constant.getPaymentSetting();

    super.onInit();
  }

  RxDouble subTotalAmount = 0.0.obs;
  RxDouble tipAmount = 0.0.obs;
  RxDouble advanceAmount = 0.0.obs;
  RxDouble taxAmount = 0.0.obs;
  RxDouble discountAmount = 0.0.obs;
  RxDouble adminCommission = 0.0.obs;
  RxString selectedPromoCode = "".obs;
  RxString selectedPromoValue = "".obs;
  RxString selectedPromoId = "".obs;
  RxString selectedAssignId = "".obs;

  var data = RideData().obs;
  var coupanCodeList = <CoupanCodeData>[].obs;

  Future<dynamic> getCoupanCodeData() async {
    try {
      final response = await LoggingClient(http.Client()).get(Uri.parse(API.discountList), headers: API.header);
      final response2 = await LoggingClient(http.Client()).get(Uri.parse(API.rewardDiscountList), headers: API.header);

      Map<String, dynamic> responseBody = json.safeDecode(response.body);
      Map<String, dynamic> response2Body = json.safeDecode(response2.body);
      devlog("MyLogData CouponCodeData==> $responseBody");
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        CoupanCodeModel model = CoupanCodeModel.fromJson(responseBody);
        coupanCodeList.value = model.data!;
      } else if (response.statusCode == 200 && responseBody['success'] == "Failed") {
        coupanCodeList.clear();
      } else {
        ShowToastDialog.showToast('Something went wrong. Please try again later');
        throw Exception('Something went wrong.!');
      }
      if (response2.statusCode == 200 && response2Body['success'] == "success") {
        CoupanCodeModel model = CoupanCodeModel.fromJson(response2Body);
        coupanCodeList.value += model.data!;
      } else if (response2.statusCode == 200 && response2Body['success'] == "Failed") {
        // coupanCodeList.clear();
      } else {
        ShowToastDialog.showToast('Something went wrong. Please try again later');
        throw Exception('Something went wrong.!');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  getArgument() async {
    subTotalAmount.value = 0.0;
    tipAmount.value = 0.0;
    discountAmount.value = 0.0;
    taxAmount.value = 0.0;
    adminCommission.value = 0.0;
    advanceAmount.value = 0.0;
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      data.value = argumentData["rideData"];

      devlog(" data.value  data.value ${data.value}");
      selectedRadioTile.value = data.value.payment.toString();
      subTotalAmount.value = double.parse(data.value.montant.toString());
      advanceAmount.value = double.parse(data.value.advancePayment.toString());
      // taxAmount.value = double.parse(Constant.taxValue ?? "0.0");

      if (selectedRadioTile.value == "Wallet") {
        wallet.value = true;
      } else if (selectedRadioTile.value == "Cash") {
        cash.value = true;
      } else if (selectedRadioTile.value == "Stripe") {
        stripe.value = true;
      } else if (selectedRadioTile.value == "PayStack") {
        payStack.value = true;
      } else if (selectedRadioTile.value == "FlutterWave") {
        flutterWave.value = true;
      } else if (selectedRadioTile.value == "RazorPay") {
        razorPay.value = true;
      } else if (selectedRadioTile.value == "PayFast") {
        payFast.value = true;
      } else if (selectedRadioTile.value == "PayTm") {
        payTm.value = true;
      } else if (selectedRadioTile.value == "MercadoPago") {
        mercadoPago.value = true;
      } else if (selectedRadioTile.value == "PayPal") {
        paypal.value = true;
      }
    }
    getAmount();
    // if (data.value.paymentStatus == "yes") {
      getRideDetailsData(data.value.id.toString());
    // }
    if (data.value.paymentStatus != "yes") {
      for (var i = 0; i < Constant.taxList.length; i++) {
        if (Constant.taxList[i].statut == 'yes') {
          if (Constant.taxList[i].type == "Fixed") {
            taxAmount.value += double.parse(Constant.taxList[i].value.toString());
          } else {
            taxAmount.value += ((subTotalAmount.value - discountAmount.value) * double.parse(Constant.taxList[i].value!.toString())) / 100;
          }
        }
      }
    }
    update();
  }

  Future<dynamic> getAmount() async {
    try {
      final response = await LoggingClient(http.Client()).get(Uri.parse("${API.wallet}?id_user=${Preferences.getInt(Preferences.userId)}&user_cat=user_app"), headers: API.header);
      Map<String, dynamic> responseBody = json.safeDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "success") {
        walletAmount.value = responseBody['data']['amount']?.toString() ?? "0";
      } else if (response.statusCode == 200 && responseBody['success'] == "Failed") {
      } else {
        ShowToastDialog.showToast('Something went wrong. Please try again later');
        throw Exception('Something went wrong.!');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Future<dynamic> getRideDetailsData(String id) async {
    try {
      final response = await LoggingClient(http.Client()).get(Uri.parse("${API.rideDetails}?ride_id=$id"), headers: API.header);
      log("dfhdkfhskdjfhskdjhf " + response.body);

      Map<String, dynamic> responseBody = json.safeDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "success") {
        RideDetailsModel rideDetailsModel = RideDetailsModel.fromJson(responseBody);

        subTotalAmount.value = double.parse(rideDetailsModel.rideDetailsdata!.montant.toString());
        tipAmount.value = double.parse(rideDetailsModel.rideDetailsdata!.tipAmount.toString());
        discountAmount.value = double.parse(rideDetailsModel.rideDetailsdata!.discount.toString());
        for (var i = 0; i < rideDetailsModel.rideDetailsdata!.taxModel!.length; i++) {
          if (rideDetailsModel.rideDetailsdata!.taxModel![i].statut! == 'yes') {
            if (rideDetailsModel.rideDetailsdata!.taxModel![i].type == "Fixed") {
              taxAmount.value += double.parse(rideDetailsModel.rideDetailsdata!.taxModel![i].value.toString());
            } else {
              taxAmount.value += ((subTotalAmount.value - discountAmount.value) * double.parse(rideDetailsModel.rideDetailsdata!.taxModel![i].value!.toString())) / 100;
            }
          }
        }
      } else if (response.statusCode == 200 && responseBody['success'] == "Failed") {
        ShowToastDialog.showToast(responseBody['error']?.toString() ?? 'Something went wrong. Please try again later');
      } else {
        ShowToastDialog.showToast('Something went wrong. Please try again later');
        // throw Exception('Something went wrong.!');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  double calculateTax({TaxModel? taxModel}) {
    double tax = 0.0;
    if (taxModel != null && taxModel.statut == 'yes') {
      if (taxModel.type.toString() == "Fixed") {
        tax = double.parse(taxModel.value.toString());
      } else {
        tax = ((subTotalAmount.value - discountAmount.value) * double.parse(taxModel.value!.toString())) / 100;
      }
    }
    return tax;
  }

  double getTotalAmount() {
    // if (Constant.taxType == "Percentage") {
    //   taxAmount.value = Constant.taxValue != 0
    //       ? (subTotalAmount.value - discountAmount.value) *
    //           double.parse(Constant.taxValue.toString()) /
    //           100
    //       : 0.0;
    // } else {
    //   taxAmount.value = Constant.taxValue != 0
    //       ? double.parse(Constant.taxValue.toString())
    //       : 0.0;
    // }
    // if (paymentSettingModel.value.tax!.taxType == "percentage") {
    //   taxAmount.value = paymentSettingModel.value.tax!.taxAmount != null
    //       ? (subTotalAmount.value - discountAmount.value) *
    //           double.parse(
    //               paymentSettingModel.value.tax!.taxAmount.toString()) /
    //           100
    //       : 0.0;
    // } else {
    //   taxAmount.value = paymentSettingModel.value.tax!.taxAmount != null
    //       ? double.parse(paymentSettingModel.value.tax!.taxAmount.toString())
    //       : 0.0;
    // }

    // devlog("subTotalAmount $subTotalAmount");
    // devlog("subTotalAmount $discountAmount");
    // devlog("subTotalAmount $tipAmount.");
    // devlog("subTotalAmount $advanceAmount");
    // devlog("subTotalAmount $taxAmount");
    return (subTotalAmount.value - discountAmount.value) +
        tipAmount.value + /*advanceAmount.value +*/
        taxAmount.value;
  }

  UserModel? userModel;

  getUsrData() {
    userModel = Constant.getUserData();
  }

  var isLoading = true.obs;
  RxString selectedRadioTile = "".obs;
  RxString paymentMethodId = "".obs;

  Future<dynamic> walletDebitAmountRequest(Map<String, dynamic> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      log(bodyParams.toString());
      final response = await LoggingClient(http.Client()).post(Uri.parse(API.payRequestWallet), headers: API.header, body: jsonEncode(bodyParams));
      log(response.request.toString());
      log(response.body);

      Map<String, dynamic> responseBody = json.safeDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "Success") {
        ShowToastDialog.closeLoader();
        return responseBody;
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
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    ShowToastDialog.closeLoader();
    return null;
  }

  Future<dynamic> cashPaymentRequest(Map<String, dynamic> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await LoggingClient(http.Client()).post(Uri.parse(API.payRequestCash), headers: API.header, body: jsonEncode(bodyParams));

      Map<String, dynamic> responseBody = json.safeDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'].toString().toLowerCase() == "Success".toString().toLowerCase()) {
        // transactionAmountRequest();
        ShowToastDialog.closeLoader();
        return responseBody;
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
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    ShowToastDialog.closeLoader();
    return null;
  }

  Future<dynamic> transactionAmountRequest() async {
    List taxList = [];

    for (var v in Constant.taxList) {
      taxList.add(v.toJson());
    }
    Map<String, dynamic> bodyParams = {
      'id_ride': data.value.id.toString(),
      'id_driver': data.value.idConducteur.toString(),
      'id_user_app': data.value.idUserApp.toString(),
      'amount': subTotalAmount.value.toString(),
      'paymethod': selectedRadioTile.value,
      'discount': discountAmount.value.toString(),
      'tip': tipAmount.value.toString(),
      'tax': taxList,
      'transaction_id': DateTime.now().microsecondsSinceEpoch.toString(),
      'payment_status': "success",
      "coupon_id": selectedPromoId.value,
      "assign_id": selectedAssignId.value,
    };

    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await LoggingClient(http.Client()).post(Uri.parse(API.payRequestTransaction), headers: API.header, body: jsonEncode(bodyParams));
      log(bodyParams.toString());
      log(response.body);
      Map<String, dynamic> responseBody = json.safeDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "Success") {
        ShowToastDialog.closeLoader();
        return responseBody;
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
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    ShowToastDialog.closeLoader();
    return null;
  }
}
