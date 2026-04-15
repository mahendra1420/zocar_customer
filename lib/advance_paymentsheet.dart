// advance_payment_sheet.dart

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:zocar/page/all_rides/payment_selection_screen.dart';
import 'package:zocar/themes/constant_colors.dart';
import 'package:http/http.dart' as http;

import 'advance_payment_manager.dart';
import 'constant/constant.dart';
import 'constant/show_toast_dialog.dart';
import 'controller/main_page_controller.dart';
import 'controller/payment_controller.dart';
import 'controller/wallet_controller.dart';
import 'helpers/devlog.dart';
import 'model/razorpay_gen_orderid_model.dart';
import 'service/api.dart';

class AdvancePaymentSheet extends StatefulWidget {
  final PendingPayment pending;
   double? amount;
   Duration? remaining;
   String? rideId;
  static bool _isSheetShowing = false;

   AdvancePaymentSheet({super.key, required this.pending,   this.amount,
     this.remaining,
     this.rideId,});

  static Future<void> showIfNeeded(BuildContext context) async {
    if (_isSheetShowing) return; // prevent duplicate
    final pending = await AdvancePaymentManager.getPending();
    if (pending == null) return;
    if (!context.mounted) return;

    _isSheetShowing = true;
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AdvancePaymentSheet(pending: pending),
    ).whenComplete(() {
      _isSheetShowing = false;
    });
  }

  @override
  State<AdvancePaymentSheet> createState() => _AdvancePaymentSheetState();
}

class _AdvancePaymentSheetState extends State<AdvancePaymentSheet> {
  late Duration _remaining;
  late bool _timerEnabled;
  Timer? _countdownTimer;
  Timer? _autoCancel;
  String _selected = '';
  final walletController = Get.put(WalletController());
  final paymentController = Get.put(PaymentController());
  final Razorpay razorPayController = Razorpay();


  @override
  void initState() {
    super.initState();
    _remaining = widget.pending.remaining;
    _timerEnabled = widget.pending.timerEnabled;
    if (_timerEnabled) {
      _startTimers();
    }

    // Add these three lines
    razorPayController.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorPayController.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWaller);
    razorPayController.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  void _startTimers() {
    // Prevent multiple timers running in parallel
    _countdownTimer?.cancel();
    _autoCancel?.cancel();

    // Tick every second for the countdown UI
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remaining -= const Duration(seconds: 1);
      });
    });

    // Fire once when time actually runs out
    _autoCancel = Timer(_remaining, _onExpired);
  }

  void _onExpired() async {
    await AdvancePaymentManager.clear();
    if (!mounted) return;
    Navigator.of(context).pop();
    // TODO: call your cancel ride API here
    ShowToastDialog.showToast('Ride cancelled due to payment timeout');
  }

  void _onPay() async {
    if (_selected.isEmpty) {
      ShowToastDialog.showToast('Select a payment method');
      return;
    }

    _countdownTimer?.cancel();
    _autoCancel?.cancel();

    final amount = widget.pending.amount.toString();
    final rideId = widget.pending.rideId.toString();

    if (_selected == "RazorPay") {
      startRazorpayAdvancePayment(
        amount: amount,
        rideId: rideId,
      );
    }
    else if (_selected == "Wallet") {
      try {
        devlog("👉 Wallet Payment Started for rideId: $rideId");

        ShowToastDialog.showLoader("Please wait");

        final url = '${API.baseUrl}payments/advancePaymentByWallet';
        final paymentId = MainPageController.getPaymentSetting().myWallet?.idPaymentMethod?.toString() ?? '';
        final requestBody = {
          'ride_id': rideId,
          'payment_id': paymentId,
        };

        devlog("🌐 API URL: $url");
        devlog("📤 Request Body: $requestBody");

        // Use the same headers (apikey + accesstoken) as the rest of the app.
        final client = LoggingClient(http.Client());
        http.Response response = await client.post(
          Uri.parse(url),
          headers: API.header,
          body: jsonEncode(requestBody),
        );

        // Some servers route only with a trailing slash. Retry once on 404.
        if (response.statusCode == 404) {
          response = await client.post(
            Uri.parse('$url/'),
            headers: API.header,
            body: jsonEncode(requestBody),
          );
        }

        devlog("📥 Status Code: ${response.statusCode}");
        devlog("📥 Raw Response: ${response.body}");

        final body = json.safeDecode(response.body);

        devlog("📦 Decoded Response: $body");

        if (response.statusCode == 200 &&
            (body['success'] == true ||
                body['success']?.toString().toLowerCase() == 'success' ||
                body['status'] == true)) {

          devlog("✅ Wallet Payment SUCCESS");

          await AdvancePaymentManager.clear();

          ShowToastDialog.closeLoader();
          ShowToastDialog.showToast('Advance payment completed by wallet');

          if (mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }

        } else {
          devlog("❌ Wallet Payment FAILED");
          devlog("⚠️ Error Message: ${body['error']}");

          ShowToastDialog.closeLoader();

          ShowToastDialog.showToast(
            body['error']?.toString() ??
                body['message']?.toString() ??
                'Wallet payment failed, try another method',
          );

          if (_timerEnabled) {
            _startTimers();
          }
        }

      } catch (e, stackTrace) {
        devlog("🔥 EXCEPTION in Wallet Payment: $e");
        devlog("📛 StackTrace: $stackTrace");

        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast('Wallet payment failed: $e');

        if (_timerEnabled) {
          _startTimers();
        }
      }
    }  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _autoCancel?.cancel();
    razorPayController.clear(); // Add this
    super.dispose();
  }

  String get _timeLabel {
    final m = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color get _timerColor {
    if (_remaining.inSeconds > 60) return Colors.green;
    if (_remaining.inSeconds > 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),

            // Timer row
            Row(
              children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Advance Payment Required',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                      _timerEnabled
                          ? 'Pay now or your ride will be cancelled'
                          : 'Please complete advance payment to continue',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ]),
                ),
                if (_timerEnabled)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _timerColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _timerColor.withOpacity(0.4)),
                    ),
                    child: Row(children: [
                      Icon(Icons.timer, size: 16, color: _timerColor),
                      const SizedBox(width: 4),
                      Text(_timeLabel,
                          style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.bold, color: _timerColor)),
                    ]),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Amount + wallet balance
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Amount due',
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                      Text('₹${widget.pending.amount}',
                          style: const TextStyle(fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Wallet balance',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 13)),
                          Text(
                            '₹${walletController.walletAmount.value.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: walletController.walletAmount.value >=
                                      widget.pending.amount
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Payment options
            _option('Wallet',  Icons.account_balance_wallet),
            _option('RazorPay',Icons.credit_card),
            const SizedBox(height: 20),

            // Pay button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _onPay,
                style: ElevatedButton.styleFrom(
                    backgroundColor: ConstantColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text('PAY NOW',
                    style: TextStyle(color: Colors.white,
                        fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _option(String value, IconData icon) {
    final bool sel = _selected == value;
    return GestureDetector(
      onTap: () => setState(() => _selected = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: sel ? ConstantColors.primary.withOpacity(0.07) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: sel ? ConstantColors.primary : Colors.grey.shade200,
              width: sel ? 1.5 : 1),
        ),
        child: Row(children: [
          Icon(icon, size: 20,
              color: sel ? ConstantColors.primary : Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(child: Text(value,
              style: TextStyle(fontWeight: FontWeight.w600,
                  color: sel ? ConstantColors.primary : Colors.black87))),
          if (sel) Icon(Icons.check_circle,
              color: ConstantColors.primary, size: 18),
        ]),
      ),
    );
  }

  startRazorpayAdvancePayment({required String amount,required String rideId}) {
    log("startRazorpayPayment amount" + double.parse(amount).toStringAsFixed(0));
    log("startRazorpayPayment amount" + amount);

    try {
      List taxList = [];

      for (var v in Constant.taxList) {
        taxList.add(v.toJson());
      }
      Map<String, dynamic> bodyParams = {
        'id_ride': rideId,
        // 'id_driver': paymentController.data.value.idConducteur.toString(),
        // 'id_user_app': paymentController.data.value.idUserApp.toString(),
        // // 'amount': paymentController.subTotalAmount.value.toString(),
        // 'paymethod': paymentController.selectedRadioTile.value,
        // 'discount': paymentController.discountAmount.value.toString(),
        // 'tip': paymentController.tipAmount.value.toString(),
        // 'tax': taxList,
        // 'transaction_id': DateTime.now().microsecondsSinceEpoch.toString(),
        // 'payment_status': "success",
        // "coupon_id": paymentController.selectedPromoId.value,
        // "assign_id": paymentController.selectedAssignId.value,
      };
      walletController.advancePaymentRazorPay(amount: int.parse(double.parse(amount).toStringAsFixed(0)), extraData: bodyParams).then((value) {
        if (value != null) {
          CreateRazorPayOrderModel result = value;
          openCheckout(
            amount: double.tryParse(amount)?.roundToDouble() ?? 0,
            orderId: result.id,
          );
        } else {
          Get.back();
          showSnackBarAlert(
            message: "Something went wrong, please contact admin.".tr,
            color: Colors.red.shade400,
          );
        }
      });
    } catch (e) {
      Get.back();
      showSnackBarAlert(
        message: e.toString(),
        color: Colors.red.shade400,
      );
    }
  }

  void openCheckout({required amount, required orderId}) async {
    final isTestMode = false;
    String key = (isTestMode) ? "rzp_test_SSZYwBRuFiWZXV" : MainPageController.getPaymentSetting().razorpay?.key ?? "";
    // String key = "rzp_test_SSZYwBRuFiWZXV";
    final mobile = Constant.getUserData().data?.phone;
    final email = Constant.getUserData().data?.email;
    var options = {
      'key': key,
      'amount': amount * 100,
      'name': 'ZoCar',
      if (!key.startsWith("rzp_test")) 'order_id': orderId,
      "currency": "INR",
      'description': 'ZoCar Payment',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {'contact': mobile, 'email': email},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      razorPayController.open(options);
    } catch (e) {
      log('Error: $e');
    }
  }

  // void _handlePaymentSuccess(PaymentSuccessResponse response) {
  //   Get.back();
  //   transactionAPI();
  // }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Stop all timers for this sheet
    _countdownTimer?.cancel();
    _autoCancel?.cancel();

    // Clear any persisted pending advance payment so it won't reopen
    AdvancePaymentManager.clear();

    // Close the bottom sheet safely
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    ShowToastDialog.showToast("Advance payment completed".tr);
    transactionAPI();
    // TODO: call your advance payment success API here if needed
  }

  void _handleExternalWaller(ExternalWalletResponse response) {
    Get.back();
    showSnackBarAlert(
      message: "Payment Processing Via\n${response.walletName!}",
      color: Colors.blue.shade400,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Don't close the sheet — let user retry or timer expire
    try {
      final desc = jsonDecode(response.message!)['error']['description'];
      showSnackBarAlert(message: "Payment Failed: $desc", color: Colors.red.shade400);
    } catch (_) {
      showSnackBarAlert(message: "Payment failed", color: Colors.red.shade400);
    }
    // Restart timers so user can retry
    _startTimers();
  }

  showSnackBarAlert({required String message, Color color = Colors.green}) {
    return Get.showSnackbar(GetSnackBar(
      isDismissible: true,
      message: message,
      backgroundColor: color,
      duration: const Duration(seconds: 8),
    ));
  }
  transactionAPI() {
    paymentController.transactionAmountRequest().then((value) {
      if (value != null) {
        ShowToastDialog.showToast("Payment successfully completed".tr);
        Get.back(result: true);
        Get.back(result: true);
      } else {
        ShowToastDialog.closeLoader();
      }
    });
  }



}