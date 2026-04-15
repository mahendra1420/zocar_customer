// ignore_for_file: empty_catches

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as devlo;
import 'dart:io';
import 'dart:math';

import 'package:zocar/constant/constant.dart';
import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/helpers/devlog.dart';
import 'package:zocar/model/paystack_url_model.dart';
import 'package:zocar/model/payment_method_model.dart';
import 'package:zocar/model/payment_setting_model.dart';
import 'package:zocar/model/razorpay_gen_orderid_model.dart';
import 'package:zocar/model/transaction_model.dart';
import 'package:zocar/service/api.dart';
import 'package:zocar/utils/preferences.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class WalletController extends GetxController {
  RxString ref = "".obs;

  RxDouble walletAmount = 0.0.obs;
  var walletList = <TransactionData>[].obs;
  var paymentMethodList = <PaymentMethodData>[].obs;

  var isLoading = true.obs;

  RxString? selectedRadioTile;

  var paymentSettingModel = PaymentSettingModel().obs;

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
    getAmount();
    getTransaction();
    setFlutterwaveRef();
    getPaymentMethod();
    selectedRadioTile = "".obs;
    paymentSettingModel.value = Constant.getPaymentSetting();
    super.onInit();
  }

  setFlutterwaveRef() {
    Random numRef = Random();
    int year = DateTime.now().year;
    int refNumber = numRef.nextInt(20000);
    if (Platform.isAndroid) {
      ref.value = "AndroidRef$year$refNumber";
    } else if (Platform.isIOS) {
      ref.value = "IOSRef$year$refNumber";
    }
  }

  Future<dynamic> getPaymentMethod() async {
    try {
      isLoading.value = true;
      final response = await LoggingClient(http.Client()).get(Uri.parse(API.getPaymentMethod), headers: API.header);

      Map<String, dynamic> responseBody = json.safeDecode(response.body);
      print("MyPaymentMethod responseBody ==> ${responseBody.toString()}");
      devlo.log(responseBody.toString());
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        isLoading.value = false;
        PaymentMethodModel model = PaymentMethodModel.fromJson(responseBody);
        paymentMethodList.value = model.data!;
      } else if (response.statusCode == 200 && responseBody['success'] == "failed") {
        ShowToastDialog.showToast('Something went wrong. Please try again later');
        paymentMethodList.clear();
        isLoading.value = false;
      } else {
        isLoading.value = false;
        paymentMethodList.clear();
        ShowToastDialog.showToast('Something went wrong. Please try again later');
        throw Exception('Something went wrong.!');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
      print("MyPaymentMethod responseBody ==> ${e.message.toString()}");
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
      print("MyPaymentMethod responseBody ==> ${e.message.toString()}");
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
      print("MyPaymentMethod responseBody ==> ${e.toString()}");
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
      print("MyPaymentMethod responseBody ==> ${e.toString()}");
    }
    return null;
  }

  Future<dynamic> getTransaction() async {
    try {
      isLoading.value = true;
      final response = await LoggingClient(http.Client()).get(Uri.parse("${API.transaction}?id_user_app=${Preferences.getInt(Preferences.userId)}"), headers: API.header);
      Map<String, dynamic> responseBody = json.safeDecode(response.body);
      devlo.log(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "success") {
        isLoading.value = false;
        TransactionModel model = TransactionModel.fromJson(responseBody);
        walletList.value = model.data!;
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

  Future<dynamic> getAmount() async {
    try {
      final response = await LoggingClient(http.Client()).get(Uri.parse("${API.wallet}?id_user=${Preferences.getInt(Preferences.userId)}&user_cat=user_app"), headers: API.header);
      Map<String, dynamic> responseBody = json.safeDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == "success") {
        walletAmount.value = responseBody['data']['amount'] != null ? double.parse(responseBody['data']['amount'].toString()) : 0;
      } else if (response.statusCode == 200 && responseBody['success'] == "failed") {
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

  Future<dynamic> setAmount(String amount) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      Map<String, dynamic> bodyParams = {
        'id_user': Preferences.getInt(Preferences.userId),
        'cat_user': "user_app",
        'amount': amount,
        'transaction_id': DateTime.now().microsecondsSinceEpoch.toString(),
        'paymethod': selectedRadioTile!.value,
      };
      final response = await LoggingClient(http.Client()).post(Uri.parse(API.amount), headers: API.header, body: jsonEncode(bodyParams));
      Map<String, dynamic> responseBody = json.safeDecode(response.body);
      print("MyRazorPay ==> ${responseBody}");
      if (response.statusCode == 200 && responseBody['success'] == "success") {
        ShowToastDialog.closeLoader();
        return responseBody;
      } else if (response.statusCode == 200 && responseBody['success'] == "failed") {
        ShowToastDialog.closeLoader();
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

  ///razorPay
  Future<CreateRazorPayOrderModel?> createOrderRazorPay({required int amount, bool isTopup = false, required Map<String, dynamic>? extraData}) async {
    final String orderId = "${Preferences.getInt(Preferences.userId)}_${DateTime.now().microsecondsSinceEpoch}";

    const url = "${API.baseUrl}payments/razorpay/newcreateorder";

    // try {
      final response = await LoggingClient(http.Client()).post(
        Uri.parse(url),
        headers: {
          'apikey': API.apiKey,
          'accesstoken': Preferences.getString(Preferences.accesstoken),
        },
        body: {
          "amount": (amount * 100).toString(),
          "receipt_id": orderId,
          "currency": "INR",
          "razorpaykey": paymentSettingModel.value.razorpay!.key,
          "razorPaySecret": paymentSettingModel.value.razorpay!.secretKey,
          "isSandBoxEnabled": paymentSettingModel.value.razorpay!.isSandboxEnabled,
          "extra": jsonEncode(extraData),
        },
      );
      final responseBody = json.safeDecode(response.body);

      devlog("msg : $responseBody");

      if (response.statusCode == 200 && responseBody['id'] != null) {
        isLoading.value = false;
        return CreateRazorPayOrderModel.fromJson(responseBody);
      } else if (response.statusCode == 200 && responseBody['id'] == null) {
        isLoading.value = false;
        ShowToastDialog.showToast(responseBody?['error']?.toString() ?? 'Something went wrong. Please try again later');
      } else {
        isLoading.value = false;
        ShowToastDialog.showToast(responseBody?['error']?.toString() ?? 'Something went wrong. Please try again later');

      }
    // } on TimeoutException catch (e) {
    //   devlogError("error 354353462erw $e");
    //   isLoading.value = false;
    //   ShowToastDialog.showToast(e.message.toString());
    // } on SocketException catch (e) {
    //   devlogError("error 354353462sf $e");
    //   isLoading.value = false;
    //   ShowToastDialog.showToast(e.message.toString());
    // } on Error catch (e) {
    //   devlogError("error 354353462 $e");
    //   isLoading.value = false;
    //   ShowToastDialog.showToast(e.toString());
    // } catch (e) {
    //   devlogError("error 35435346 $e");
    //   ShowToastDialog.closeLoader();
    //   ShowToastDialog.showToast(e.toString());
    // }
    return null;

    //
    //
    // final response = await LoggingClient(http.Client()).post(
    //   Uri.parse(url),
    //   body: {
    //     "amount": (amount * 100).toString(),
    //     "receipt_id": orderId,
    //     "currency": "INR",
    //     "razorpaykey": "rzp_test_0iHc1FA4UBP0H3",
    //     "razorPaySecret": "Y79h9H1l4qLTKvgXFDei9pA5",
    //     "isSandBoxEnabled": true,
    //   },
    // );
    //
    //
    // if (response.statusCode == 500) {
    //   return null;
    // } else {
    //   final data = jsonDecode(response.body);
    //
    //
    //   return CreateRazorPayOrderModel.fromJson(data);
    // }
    //
  }
  Future<CreateRazorPayOrderModel?> advancePaymentRazorPay({required int amount, bool isTopup = false, required Map<String, dynamic>? extraData}) async {
    final String orderId = "${Preferences.getInt(Preferences.userId)}_${DateTime.now().microsecondsSinceEpoch}";

    const url = "${API.baseUrl}payments/razorpay/advancePaymentOrderId";

    // try {
      final response = await LoggingClient(http.Client()).post(
        Uri.parse(url),
        headers: {
          'apikey': API.apiKey,
          'accesstoken': Preferences.getString(Preferences.accesstoken),
        },
        body: {
          "amount": (amount * 100).toString(),
          "receipt_id": orderId,
          "currency": "INR",
          "razorpaykey": paymentSettingModel.value.razorpay!.key,
          "razorPaySecret": paymentSettingModel.value.razorpay!.secretKey,
          "isSandBoxEnabled": paymentSettingModel.value.razorpay!.isSandboxEnabled,
          "extra": jsonEncode(extraData),
        },
      );
      final responseBody = json.safeDecode(response.body);

      devlog("msg : $responseBody");

      if (response.statusCode == 200 && responseBody['id'] != null) {
        isLoading.value = false;
        return CreateRazorPayOrderModel.fromJson(responseBody);
      } else if (response.statusCode == 200 && responseBody['id'] == null) {
        isLoading.value = false;
        ShowToastDialog.showToast(responseBody?['error']?.toString() ?? 'Something went wrong. Please try again later');
      } else {
        isLoading.value = false;
        ShowToastDialog.showToast(responseBody?['error']?.toString() ?? 'Something went wrong. Please try again later');

      }
    // } on TimeoutException catch (e) {
    //   devlogError("error 354353462erw $e");
    //   isLoading.value = false;
    //   ShowToastDialog.showToast(e.message.toString());
    // } on SocketException catch (e) {
    //   devlogError("error 354353462sf $e");
    //   isLoading.value = false;
    //   ShowToastDialog.showToast(e.message.toString());
    // } on Error catch (e) {
    //   devlogError("error 354353462 $e");
    //   isLoading.value = false;
    //   ShowToastDialog.showToast(e.toString());
    // } catch (e) {
    //   devlogError("error 35435346 $e");
    //   ShowToastDialog.closeLoader();
    //   ShowToastDialog.showToast(e.toString());
    // }
    return null;

    //
    //
    // final response = await LoggingClient(http.Client()).post(
    //   Uri.parse(url),
    //   body: {
    //     "amount": (amount * 100).toString(),
    //     "receipt_id": orderId,
    //     "currency": "INR",
    //     "razorpaykey": "rzp_test_0iHc1FA4UBP0H3",
    //     "razorPaySecret": "Y79h9H1l4qLTKvgXFDei9pA5",
    //     "isSandBoxEnabled": true,
    //   },
    // );
    //
    //
    // if (response.statusCode == 500) {
    //   return null;
    // } else {
    //   final data = jsonDecode(response.body);
    //
    //
    //   return CreateRazorPayOrderModel.fromJson(data);
    // }
    //
  }

  ///payStack
  Future<dynamic> payStackURLGen({required String amount, required secretKey}) async {
    const url = "https://api.paystack.co/transaction/initialize";

    try {
      final response = await LoggingClient(http.Client()).post(Uri.parse(url), body: {
        "email": "demo@email.com",
        "amount": (double.parse(amount) * 100).toString(),
        "currency": "NGN",
      }, headers: {
        "Authorization": "Bearer $secretKey",
      });

      final responseBody = json.safeDecode(response.body);

      if (response.statusCode == 200 && responseBody['status'] == true) {
        isLoading.value = false;
        return PayStackUrlModel.fromJson(responseBody);
      } else if (response.statusCode == 200 && responseBody['status'] == null) {
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

    final response = await LoggingClient(http.Client()).post(Uri.parse(url), body: {
      "email": "demo@email.com",
      "amount": (double.parse(amount) * 100).toString(),
      "currency": "NGN",
    }, headers: {
      "Authorization": "Bearer $secretKey",
    });

    final data = jsonDecode(response.body);

    if (!data["status"]) {
      return null;
    }
    return PayStackUrlModel.fromJson(data);
  }

  Future<bool> payStackVerifyTransaction({
    required String reference,
    required String secretKey,
    required String amount,
  }) async {
    final url = "https://api.paystack.co/transaction/verify/$reference";
    var response = await LoggingClient(http.Client()).get(Uri.parse(url), headers: {
      "Authorization": "Bearer $secretKey",
    });

    final data = jsonDecode(response.body);
    if (data["status"] == true) {
      if (data["message"] == "Verification successful") {}
    }

    return data["status"];

    //PayPalClientSettleModel.fromJson(data);
  }

  ///Stripe
  createStripeIntent({required String amount}) async {
    try {
      Map<String, dynamic> body = {
        'amount': ((double.parse(amount) * 100).round()).toString(),
        'currency': "USD",
        'payment_method_types[]': 'card',
        "description": "${Preferences.getInt(Preferences.userId)} Wallet Topup",
        "shipping[name]": "${Preferences.getInt(Preferences.userId)} ${Preferences.getInt(Preferences.userId)}",
        "shipping[address][line1]": "510 Townsend St",
        "shipping[address][postal_code]": "98140",
        "shipping[address][city]": "San Francisco",
        "shipping[address][state]": "CA",
        "shipping[address][country]": "US",
      };
      var stripeSecret = paymentSettingModel.value.strip!.secretKey;
      var response = await LoggingClient(http.Client()).post(Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body, headers: {'Authorization': 'Bearer $stripeSecret', 'Content-Type': 'application/x-www-form-urlencoded'});

      return jsonDecode(response.body);
    } catch (e) {}
  }

  ///paytm
  Future verifyCheckSum({required String checkSum, required double amount, required orderId}) async {
    String getChecksum = "${API.baseUrl}payments/validatechecksum";
    final response = await LoggingClient(http.Client()).post(
        Uri.parse(
          getChecksum,
        ),
        body: {
          "mid": paymentSettingModel.value.paytm!.merchantId,
          "order_id": orderId,
          "key_secret": paymentSettingModel.value.paytm!.merchantKey,
          "checksum_value": checkSum,
        });
    final data = jsonDecode(response.body);
    log(data);

    return data['status'];
  }
}
