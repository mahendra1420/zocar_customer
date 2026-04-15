import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:zocar/constant/constant.dart';
import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/model/coupan_code_model.dart';
import 'package:zocar/service/api.dart';

import '../helpers/devlog.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Value object returned by [CouponController.evaluateForVehicle].
// ─────────────────────────────────────────────────────────────────────────────
class CouponEvalResult {
  /// Whether the currently selected coupon is applicable to this vehicle fare.
  final bool isApplicable;

  /// Discount amount in currency units (0 when not applicable).
  final int discountAmount;

  /// Final price after discount (equals [originalPrice] when not applicable).
  final int finalPrice;

  /// Human-readable reason why the coupon is NOT applicable (empty when it is).
  final String reason;

  const CouponEvalResult({
    required this.isApplicable,
    required this.discountAmount,
    required this.finalPrice,
    required this.reason,
  });

  /// Convenience: no coupon applied at all.
  factory CouponEvalResult.noCoupon(int price) => CouponEvalResult(
    isApplicable: false,
    discountAmount: 0,
    finalPrice: price,
    reason: '',
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// CouponController
// ─────────────────────────────────────────────────────────────────────────────
class CouponController extends GetxController {
  // ─── Coupon list ───────────────────────────────────────────────────────────
  var coupanCodeList = <CoupanCodeData>[].obs;

  // ─── Text controllers ──────────────────────────────────────────────────────
  TextEditingController couponCodeController = TextEditingController();

  // ─── Selected promo state ──────────────────────────────────────────────────
  /// Code string of the currently staged coupon (may not yet be "valid" for
  /// a specific vehicle — validity is computed per-vehicle via
  /// [evaluateForVehicle]).
  RxString selectedPromoCode  = "".obs;
  RxString selectedPromoValue = "".obs; // display string e.g. "10%" or "₹50"
  RxString selectedPromoId    = "".obs;
  RxString selectedAssignId   = "".obs;

  // ─── Staged coupon data (set when user picks a coupon) ────────────────────
  /// The raw [CoupanCodeData] that is staged. Null when nothing is selected.
  final Rx<CoupanCodeData?> _stagedCoupon = Rx<CoupanCodeData?>(null);

  // ─── Legacy amount fields (kept for payment controller compatibility) ──────
  /// Set this to the selected vehicle's price just before payment so that the
  /// payment flow can read the correct discount for that vehicle.
  RxDouble subTotalAmount = 0.0.obs;
  RxInt discountAmount = 0.obs; // updated whenever subTotalAmount changes
  RxDouble taxAmount      = 0.0.obs;

  // ──────────────────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    getCoupanCodeData();

    // Keep discountAmount in sync whenever subTotalAmount is updated (e.g.
    // just before payment). This preserves existing payment-flow behaviour.
    ever(subTotalAmount, (_) => _recalcDiscount());
  }

  @override
  void onClose() {
    couponCodeController.dispose();
    super.onClose();
  }

  // ─── Reset coupon selection ────────────────────────────────────────────────
  void clearCoupon() {
    selectedPromoCode.value  = "";
    selectedPromoValue.value = "";
    selectedPromoId.value    = "";
    selectedAssignId.value   = "";
    discountAmount.value     = 0;
    taxAmount.value          = 0.0;
    _stagedCoupon.value      = null;
    couponCodeController.clear();
  }

  // ─── Fetch coupon + reward-discount lists ──────────────────────────────────
  Future<void> getCoupanCodeData() async {
    try {
      final response  = await http.Client().get(
        Uri.parse(API.discountList),
        headers: API.header,
      );
      final response2 = await http.Client().get(
        Uri.parse(API.rewardDiscountList),
        headers: API.header,
      );

      final Map<String, dynamic> body1 = json.decode(response.body);
      final Map<String, dynamic> body2 = json.decode(response2.body);

      devlog("CouponController discountList ==> $body1");
      devlog("CouponController rewardDiscountList ==> $body2");

      if (response.statusCode == 200 && body1['success'] == "success") {
        coupanCodeList.value = CoupanCodeModel.fromJson(body1).data ?? [];
      } else if (response.statusCode == 200 && body1['success'] == "Failed") {
        coupanCodeList.clear();
      } else {
        ShowToastDialog.showToast('Something went wrong. Please try again later');
      }

      if (response2.statusCode == 200 && body2['success'] == "success") {
        final extra = CoupanCodeModel.fromJson(body2).data ?? [];
        coupanCodeList.value = [...coupanCodeList, ...extra];
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PUBLIC: Stage a coupon without requiring a vehicle price.
  //
  // The coupon is stored globally. Per-vehicle applicability is evaluated
  // lazily via [evaluateForVehicle].
  // ─────────────────────────────────────────────────────────────────────────

  /// Stage the coupon at [index] in [coupanCodeList].
  /// Always succeeds (no amount validation here).
  /// Returns true so callers can close the sheet.
  bool applyCouponByIndex(int index) {
    final coupon = coupanCodeList[index];
    _stageCoupon(coupon);
    ShowToastDialog.showToast("Coupon selected! 🎉");
    return true;
  }

  /// Stage the coupon matching [code].
  bool applyCouponByCode(String code) {
    final element = coupanCodeList.firstWhereOrNull(
          (e) => e.code?.trim().toUpperCase() == code.trim().toUpperCase(),
    );
    if (element == null) {
      ShowToastDialog.showToast("Coupon not found.");
      return false;
    }
    _stageCoupon(element);
    ShowToastDialog.showToast("Coupon selected! 🎉");
    return true;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PUBLIC: Evaluate the staged coupon against a specific vehicle price.
  //
  // Returns a [CouponEvalResult] — the caller decides how to render it.
  // No side-effects; safe to call from build / Obx.
  // ─────────────────────────────────────────────────────────────────────────
  CouponEvalResult evaluateForVehicle(double vehiclePrice) {
    final coupon = _stagedCoupon.value;

    // No coupon staged → just return original price.
    if (coupon == null || selectedPromoCode.value.isEmpty) {
      return CouponEvalResult.noCoupon(vehiclePrice.round());
    }

    // ── Minimum order amount check ────────────────────────────────────────
    final minAmount = double.tryParse(coupon.minimum_amount?.toString() ?? "0") ?? 0.0;
    if (minAmount > 0 && vehiclePrice < minAmount) {
      return CouponEvalResult(
        isApplicable: false,
        discountAmount: 0,
        finalPrice: vehiclePrice.round(),
        reason: "Min. order ${Constant().amountShow(amount: minAmount.toString())} required",
      );
    }

    // ── Compute raw discount ──────────────────────────────────────────────
    double rawDiscount;
    if (coupon.type == "Percentage") {
      final rate = (double.tryParse(coupon.discount?.toString() ?? "0") ?? 0.0) / 100.0;
      rawDiscount = vehiclePrice * rate;
    } else {
      rawDiscount = double.tryParse(coupon.discount?.toString() ?? "0") ?? 0.0;
    }

    // ── Maximum discount cap ──────────────────────────────────────────────
    // final maxDiscount = double.tryParse(coupon.maxDiscount?.toString() ?? "0") ?? 0.0;
    // if (maxDiscount > 0 && rawDiscount > maxDiscount) {
    //   rawDiscount = maxDiscount;
    // }

    // ── Discount must be less than the vehicle price ──────────────────────
    if (rawDiscount >= vehiclePrice) {
      return CouponEvalResult(
        isApplicable: false,
        discountAmount: 0,
        finalPrice: vehiclePrice.round(),
        reason: "Coupon exceeds fare",
      );
    }

    final finalPrice = (vehiclePrice - rawDiscount).clamp(0.0, double.infinity);

    return CouponEvalResult(
      isApplicable: true,
      discountAmount: rawDiscount.round(),
      finalPrice: finalPrice.round(),
      reason: '',
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Called just before payment — set subTotalAmount to the selected vehicle's
  // price so that discountAmount (read by payment controller) is correct.
  // ─────────────────────────────────────────────────────────────────────────
  void finalizeForPayment(double vehiclePrice) {
    subTotalAmount.value = vehiclePrice;
    // _recalcDiscount is triggered by the `ever` listener above.
  }

  // ─── Private helpers ───────────────────────────────────────────────────────

  void _stageCoupon(CoupanCodeData coupon) {
    _stagedCoupon.value      = coupon;
    selectedPromoCode.value  = coupon.code?.toString()     ?? "";
    selectedPromoId.value    = coupon.id?.toString()       ?? "";
    selectedAssignId.value   = coupon.assignId?.toString() ?? "";
    selectedPromoValue.value = coupon.type == "Percentage"
        ? "${coupon.discount}%"
        : Constant().amountShow(amount: coupon.discount.toString());
  }

  /// Recalculates [discountAmount] and [taxAmount] from [subTotalAmount].
  /// Called automatically by the `ever` listener and by [finalizeForPayment].
  void _recalcDiscount() {
    final coupon = _stagedCoupon.value;
    if (coupon == null || subTotalAmount.value <= 0) {
      discountAmount.value = 0;
      taxAmount.value      = 0.0;
      return;
    }

    final result = evaluateForVehicle(subTotalAmount.value);
    discountAmount.value = result.isApplicable ? result.discountAmount : 0;

    // Recalculate tax on discounted base.
    taxAmount.value = 0.0;
    for (final tax in Constant.taxList) {
      if (tax.statut == 'yes') {
        if (tax.type == "Fixed") {
          taxAmount.value += double.parse(tax.value.toString());
        } else {
          taxAmount.value +=
              ((subTotalAmount.value - discountAmount.value) *
                  double.parse(tax.value!.toString())) /
                  100;
        }
      }
    }
  }
}