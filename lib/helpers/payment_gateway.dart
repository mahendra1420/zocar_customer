import 'dart:convert';

import 'package:zocar/controller/main_page_controller.dart';
import 'package:zocar/helpers/size_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../themes/constant_colors.dart';
import 'devlog.dart';

typedef PaymentCallback = Future<void> Function(PaymentSuccessResponse response);

Future<String> convertAssetImageToBase64(String assetPath) async {
  try {
    ByteData byteData = await rootBundle.load(assetPath);
    Uint8List bytes = byteData.buffer.asUint8List();
    String base64String = base64Encode(bytes);
    return base64String;
  } catch (e) {
    throw Exception("Error converting asset to Base64: $e");
  }
}

class PaymentGateway {
  PaymentGateway._();

  static PaymentGateway get instance => PaymentGateway._();

  final Razorpay _razorpay = Razorpay();

  /// RAZORPAY PAYMENT GATEWAY
  ///
  void openRazorPay({required num amount, required PaymentCallback onSuccess, VoidCallback? onFailure}) async {
    addListeners(onSuccess, onFailure);

    final isTestMode = false;

    // String key = "rzp_test_SSZYwBRuFiWZXV";
    String key = (isTestMode) ? "rzp_test_SSZYwBRuFiWZXV" : MainPageController.getPaymentSetting().razorpay?.key ?? "";
    devlog("kay : $key");
    devlog("amount : $amount");
    Map<String, dynamic> options = {
      'key': key,
      "currency": "INR",
      "amount": amount * 100,
    };
    _razorpay.open(options);
  }

  /// ADD LISTENERS
  ///
  void addListeners(PaymentCallback onSuccess, VoidCallback? onFailure) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (r) async => await _handlePaymentSuccess(r, onSuccess));
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (r) async => await _handlePaymentError(r, onFailure));
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  /// LISTENERS IMPL
  ///
  Future<void> _handlePaymentSuccess(
      PaymentSuccessResponse response,
      PaymentCallback onSuccess,
      ) async {
    // Do something when payment succeeds
    devlog("PAYMENT SUCCESS --> ");

    devlog("-->> ORDER ID : ${response.orderId}");
    devlog("-->> PAYMENT ID : ${response.paymentId}");
    devlog("-->> SIGNATURE : ${response.signature}");
    // devlog("-->> DATA : ${response.data}");

    _razorpay.clear();
    await onSuccess(response);
  }

  Future<void> _handlePaymentError(PaymentFailureResponse response, VoidCallback? onFailure) async {
    // Do something when payment fails
    devlog("PAYMENT FAILS --> ");

    devlog("-->> ERROR : ${response.error}");
    devlog("-->> MESSAGE : ${response.message}");
    devlog("-->> CODE : ${response.code}");

    _razorpay.clear();
    await showPaymentStatusDialog(isSuccess: false);
    if(onFailure != null)  onFailure();

  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
    devlog("PAYMENT EXTERNAL WALLET --> ");
    devlog("-->> WALLET NAME : ${response.walletName}");

    _razorpay.clear();
  }

  Future<bool?> showPaymentStatusDialog({required bool isSuccess, String? msg}) async {
    // return await Navigator.push(Get.context!, MaterialPageRoute(builder: (context) => _PaymentDialog(isSuccess, message: msg)));
    //
    return await showDialog<bool>(
      context: Get.context!,
      builder: (context) {
        return _PaymentDialog(isSuccess);
      },
    );
  }
}

class _PaymentDialog extends StatefulWidget {
  final bool isSuccess;
  final String? message;

  const _PaymentDialog(this.isSuccess, {this.message});

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  @override
  void initState() {
    super.initState();
    // widgetBinding((_) {
    //   SoundPlayer.instance.play(
    //     widget.isSuccess ? AssetSoundPlayerSource.payment_success_sound.source : AssetSoundPlayerSource.payment_failed_sound.source,
    //   );
    // });
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isSuccess ? Colors.green : Colors.red;
    return PopScope(
      canPop: true,
      child: Dialog(
        // color: Colors.white,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 3.h, horizontal: 4.w),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!widget.isSuccess) SizedBox(height:  4.h),
              // ZoomIn(child: CustomImage(url: widget.isSuccess ? AppIcons.payment_success_gif : AppIcons.payment_failed_gif, size: 90.w)),
              // LottieItem.payment_success.lottie(width: 80.w, height: 80.w),
              Icon(Icons.cancel, color: Colors.red, size: 20.w),
              if (!widget.isSuccess) SizedBox(height: 3.h),
              Text(widget.message ?? (widget.isSuccess ? "Payment Success" : "Payment Failed"), style: TextStyle(fontSize: widget.message != null ? 18 : 20, fontWeight: FontWeight.w600, color: color),),

              SizedBox(height: 4.h),
              ElevatedButton(
                  // color: AppColors.white(context),
                  // alignment: Alignment.center,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: ConstantColors.primary,
                  ),
                  onPressed: () {
                    // context.pop<bool>(true);
                    Navigator.pop<bool>(context, true);
                  },
                  // border: ButtonBorder(width: 1, color: color),
                  child: Text(
                    "CONTINUE",
                    style: TextStyle(color: Colors.white),
                    // fontSize: FontSize.normal,
                    // textColor: color,
                    // fontWeight: FontWeight.w600,
                  )).paddingSymmetric(horizontal: 10),
              SizedBox(height: 3.h)
            ],
          ),
        ),
      ),
    );
  }
}