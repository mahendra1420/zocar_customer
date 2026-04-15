import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zocar/constant/constant.dart';
import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/controller/coupon_controller.dart';
import 'package:zocar/controller/home_controller.dart';
import 'package:zocar/helpers/loader.dart';
import 'package:zocar/helpers/size_ext.dart';
import 'package:zocar/helpers/booking_price_helper.dart';
import 'package:zocar/model/vehicle_category_model.dart';
import 'package:zocar/themes/constant_colors.dart';

import '../../helpers/devlog.dart';
import '../../model/coupan_code_model.dart';
import '../../service/active_user_checker.dart';
import '../all_rides/coupon_info_sheet.dart';
import 'date_time_picker_widget.dart';

String _normalizedTaxType(String? type) {
  final t = (type ?? '').trim().toLowerCase();
  if (t == 'amount' || t == 'fixed') return 'amount';
  return 'percentage';
}

Map<String, dynamic>? _activeTaxConfig() {
  final activeTaxes = Constant.taxList.where((tax) {
    final status = (tax.statut ?? '').trim().toLowerCase();
    return status == 'yes';
  }).toList();

  for (final tax in activeTaxes) {
    final name = (tax.libelle ?? '').trim().toLowerCase();
    if (name.contains('gst') ||
        name.contains('cgst') ||
        name.contains('sgst') ||
        name.contains('igst') ||
        name.contains('tax')) {
      return {
        'label': (tax.libelle ?? '').trim().isEmpty ? 'GST' : tax.libelle!.trim(),
        'type': _normalizedTaxType(tax.type),
        'value': double.tryParse(tax.value ?? '') ?? 0.0,
      };
    }
  }

  if (activeTaxes.isNotEmpty) {
    final tax = activeTaxes.first;
    return {
      'label': (tax.libelle ?? '').trim().isEmpty ? 'GST' : tax.libelle!.trim(),
      'type': _normalizedTaxType(tax.type),
      'value': double.tryParse(tax.value ?? '') ?? 0.0,
    };
  }
  return null;
}

double _gstAmountFor(double amount) {
  final tax = _activeTaxConfig();
  if (amount <= 0 || tax == null) return 0.0;
  final value = (tax['value'] as double?) ?? 0.0;
  if (value <= 0) return 0.0;
  if (tax['type'] == 'amount') return value;
  return (amount * value) / 100;
}

double _amountWithGst(double amount) {
  return amount + _gstAmountFor(amount);
}

String _gstBreakdownLabel() {
  final tax = _activeTaxConfig();
  if (tax == null) return 'GST';
  final label = (tax['label'] as String?) ?? 'GST';
  final type = (tax['type'] as String?) ?? 'percentage';
  final value = (tax['value'] as double?) ?? 0.0;
  if (type == 'amount') {
    return '$label (${Constant().amountShow(amount: value.toString())})';
  }
  return '$label (${value.toStringAsFixed(0)}%)';
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper — open the sheet from anywhere with a single call.
// ─────────────────────────────────────────────────────────────────────────────
void showChooseVehicleBottomSheet({
  required BuildContext context,
  required VehicleCategoryModel vehicleCategoryModel,
  required DateTime dailyDateTime,
  required DateTime osStartDateTime,
  required DateTime osEndDateTime,
  required bool isRoundTrip,
  required GlobalKey<TripDateTimeSelectorState> tripDateTimeKey,
  required String type,
}) {
  showModalBottomSheet(
    context: context,
    isDismissible: false,
    isScrollControlled: true,
    enableDrag: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChooseVehicleBottomSheet(
      vehicleCategoryModel: vehicleCategoryModel,
      initialDailyDateTime: dailyDateTime,
      initialOsStartDateTime: osStartDateTime,
      initialOsEndDateTime: osEndDateTime,
      initialIsRoundTrip: isRoundTrip,
      tripDateTimeKey: tripDateTimeKey,
      type: type,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// The bottom sheet widget
// ─────────────────────────────────────────────────────────────────────────────
class ChooseVehicleBottomSheet extends StatefulWidget {
  const ChooseVehicleBottomSheet({
    super.key,
    required this.vehicleCategoryModel,
    required this.initialDailyDateTime,
    required this.initialOsStartDateTime,
    required this.initialOsEndDateTime,
    required this.initialIsRoundTrip,
    required this.tripDateTimeKey,
    required this.type,
  });

  final VehicleCategoryModel vehicleCategoryModel;
  final DateTime initialDailyDateTime;
  final DateTime initialOsStartDateTime;
  final DateTime initialOsEndDateTime;
  final bool initialIsRoundTrip;
  final GlobalKey<TripDateTimeSelectorState> tripDateTimeKey;
  final String type;

  @override
  State<ChooseVehicleBottomSheet> createState() =>
      _ChooseVehicleBottomSheetState();
}

class _ChooseVehicleBottomSheetState extends State<ChooseVehicleBottomSheet> {
  late final HomeController homeCtr;
  late final CouponController couponCtr;

  late DateTime dailyDateTime;
  late DateTime osStartDateTime;
  late DateTime osEndDateTime;
  late bool isRoundTrip;

  @override
  void initState() {
    super.initState();
    homeCtr   = Get.find<HomeController>();
    couponCtr = Get.find<CouponController>();

    dailyDateTime   = widget.initialDailyDateTime;
    osStartDateTime = widget.initialOsStartDateTime;
    osEndDateTime   = widget.initialOsEndDateTime;
    isRoundTrip     = widget.initialIsRoundTrip;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _bookNow() async {
    showLoader(context);
    final ok = await ActiveChecker.check();
    hideLoader();
    if (!ok) return;

    homeCtr.searchVisible.value = true;

    if (homeCtr.selectedVehicle.value.isEmpty) {
      ShowToastDialog.showToast("Please select Vehicle Type".tr);
      return;
    }

    // Finalize discount for the selected vehicle's actual price before payment.
    final selectedPrice = homeCtr.vehicleData?.advanceAmount ?? 0.0;
    couponCtr.finalizeForPayment(selectedPrice);

    await homeCtr.razorPayPayment(
      isOutstation: homeCtr.selectedOptionIndex == 1,
      dailyDateTime: dailyDateTime,
      isRoundTrip: isRoundTrip,
      osStartDateTime: osStartDateTime,
      osEndDateTime: osEndDateTime,
      couponId: couponCtr.selectedPromoId.value,
      assignId: couponCtr.selectedAssignId.value,
      discount: couponCtr.discountAmount.value,
    );
  }

  void _openCouponSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CouponSelectionSheet(couponCtr: couponCtr),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(3.w, 16, 3.w, 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLocationCard(),
                      SizedBox(height: 1.h),
                      _buildDateTimeSelector(),
                      const SizedBox(height: 10),
                      _buildDistanceDurationCard(),
                      const SizedBox(height: 10),
                      _buildCouponListTile(),
                      const SizedBox(height: 10),
                      _buildVehicleListSection(),
                      const SizedBox(height: 10),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Location card ─────────────────────────────────────────────────────────

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildLocationRow(
            icon: Icons.trip_origin,
            iconColor: Colors.green,
            text: homeCtr.departureController.text,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Container(
                  width: 2,
                  height: 15,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade300, Colors.blue.shade300],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildLocationRow(
            icon: Icons.location_on,
            iconColor: Colors.red,
            text: homeCtr.destinationController.text,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ── DateTime selector ─────────────────────────────────────────────────────

  Widget _buildDateTimeSelector() {
    return TripDateTimeSelector(
      key: widget.tripDateTimeKey,
      isOutstation: homeCtr.selectedOptionIndex == 1,
      onTripDetailsChanged:
          (newDailyDateTime, newIsRoundTrip, startDateTime, endDateTime) {
        setState(() {
          dailyDateTime   = newDailyDateTime;
          isRoundTrip     = newIsRoundTrip;
          osStartDateTime = startDateTime;
          osEndDateTime   = endDateTime ?? DateTime.now();
        });
        if (newIsRoundTrip) {
          homeCtr.distance.value      = homeCtr.distanceSavedForRoundTrip.value * 2;
          homeCtr.durationFloat.value = homeCtr.durationFloatSavedForRoundTrip.value * 2;
        } else {
          homeCtr.distance.value      = homeCtr.distanceSavedForRoundTrip.value;
          homeCtr.durationFloat.value = homeCtr.durationFloatSavedForRoundTrip.value;
        }
        homeCtr.duration.value = homeCtr.formatDuration(homeCtr.durationFloat.value);
        devlog("dailyDateTime: $dailyDateTime | osStartDateTime: $osStartDateTime");
      },
      onOkPressed: () async {
        showLoader(context);
        final ok = await ActiveChecker.check();
        hideLoader();
        if (!ok) return;
        homeCtr.searchVisible.value = true;
        if (homeCtr.selectedVehicle.value.isEmpty) {
          ShowToastDialog.showToast("Please select Vehicle Type".tr);
          return;
        }
        final selectedPrice = homeCtr.vehicleData?.advanceAmount ?? 0.0;
        couponCtr.finalizeForPayment(selectedPrice);
        await homeCtr.razorPayPayment(
          isOutstation: homeCtr.selectedOptionIndex == 1,
          dailyDateTime: dailyDateTime,
          isRoundTrip: isRoundTrip,
          osStartDateTime: osStartDateTime,
          osEndDateTime: osEndDateTime,
          couponId: couponCtr.selectedPromoId.value,
          assignId: couponCtr.selectedAssignId.value,
          discount: couponCtr.discountAmount.value,
        );
      },
    );
  }

  // ── Distance / Duration card ──────────────────────────────────────────────

  Widget _buildDistanceDurationCard() {
    return Obx(
          () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.route, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Distance".tr,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blue.shade700),
                ),
                const Spacer(),
                Text(
                  "${homeCtr.distance.value.toStringAsFixed(2)} ${Constant.distanceUnit}",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.timelapse, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Duration".tr,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blue.shade700),
                ),
                const Spacer(),
                Text(
                  homeCtr.duration.value,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blue.shade700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Coupon list tile ──────────────────────────────────────────────────────

  /// Single tappable row. Opens [_CouponSelectionSheet] on tap.
  /// No amount validation — coupon is staged globally and evaluated per-vehicle.
  Widget _buildCouponListTile() {
    return Obx(() {
      if (couponCtr.coupanCodeList.isEmpty) return const SizedBox.shrink();

      final isApplied = couponCtr.selectedPromoCode.value.isNotEmpty;

      return InkWell(
        onTap: _openCouponSheet,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: isApplied ? Colors.green.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isApplied ? Colors.green.shade300 : Colors.grey.shade300,
              width: isApplied ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isApplied ? Colors.green.shade100 : Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isApplied ? Icons.check_circle : Icons.local_offer_outlined,
                  color: isApplied ? Colors.green.shade700 : Colors.blue.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: isApplied
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "\"${couponCtr.selectedPromoCode.value}\" ${"applied!".tr}",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${"Saves".tr} ${couponCtr.selectedPromoValue.value} ${"per eligible vehicle".tr}",
                      style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                    ),
                  ],
                )
                    : Text(
                  "Apply Coupon".tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
              if (isApplied)
                GestureDetector(
                  onTap: () => couponCtr.clearCoupon(),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(Icons.close, size: 18, color: Colors.green.shade700),
                  ),
                )
              else
                Icon(Icons.chevron_right, color: Colors.grey.shade500, size: 22),
            ],
          ),
        ),
      );
    });
  }

  // ── Vehicle list ──────────────────────────────────────────────────────────

  Widget _buildVehicleListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Available Vehicles".tr,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        StatefulBuilder(builder: (context, setVehicleState) {
          return ListView.builder(
            itemCount: widget.vehicleCategoryModel.data!.length,
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, index) {
              final item = widget.vehicleCategoryModel.data![index];
              final basePrice = Constant().sanitizePrice(
                Constant().amountShow(
                  amount: "${homeCtr.calculateTripPrice(
                    distance: homeCtr.distance.value,
                    deliveryCharges: double.parse(item.deliveryCharges!),
                    minimumDeliveryCharges: double.parse(item.minimumDeliveryCharges!),
                    minimumDeliveryChargesWithin: double.parse(item.minimumDeliveryChargesWithin!),
                    outstation_radius: double.parse(item.outstation_radius!),
                    outstation_delivery_charge_per_km: double.parse(item.outstation_delivery_charge_per_km!),
                  )}",
                ),
              );
              final parsedBase = double.tryParse(basePrice) ?? 0.0;
              item.advanceAmount = _amountWithGst(parsedBase);

              return _VehicleCard(
                vehicleData: item,
                homeCtr: homeCtr,
                couponCtr: couponCtr,
                onSelected: () => setVehicleState(() {}),
                onInfoTap: () => _showPriceBreakdown(item),
              );
            },
          );
        }),
      ],
    );
  }

  // ── Action buttons ────────────────────────────────────────────────────────

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: ElevatedButton.icon(
            onPressed: _bookNow,
            icon: const Icon(Icons.check_circle, size: 18),
            label: Text("Book Now".tr),
            style: OutlinedButton.styleFrom(
              foregroundColor: ConstantColors.primary,
              side: BorderSide(color: ConstantColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: OutlinedButton.icon(
            onPressed: () => widget.tripDateTimeKey.currentState?.openDateTimePicker(),
            label: Text("Book Schedule".tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: ConstantColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  // ── Price breakdown sheet trigger ─────────────────────────────────────────

  void _showPriceBreakdown(VehicleData vehicleData) {
    final distance                 = homeCtr.distance.value;
    final deliveryCharges          = double.parse(vehicleData.deliveryCharges!);
    final minimumDeliveryCharges   = double.parse(vehicleData.minimumDeliveryCharges!);
    final minimumDeliveryChargesWithin = double.parse(vehicleData.minimumDeliveryChargesWithin!);
    final outstationRadius         = double.parse(vehicleData.outstation_radius!);
    final outstationChargePerKm    = double.parse(vehicleData.outstation_delivery_charge_per_km!);

    final num    basePrice   = minimumDeliveryChargesWithin;
    final double rawExtra    = distance - minimumDeliveryCharges;
    final double newDistance = rawExtra.isNegative ? 0 : rawExtra;
    final num    perKm       = newDistance <= outstationRadius ? deliveryCharges : outstationChargePerKm;
    final num    total       = basePrice + (newDistance.round() * perKm);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _PriceBreakdownSheet(
        vehicleData: vehicleData,
        total: total,
        newDistance: newDistance,
        perKm: perKm,
        homeCtr: homeCtr,
        couponCtr: couponCtr,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Coupon selection bottom sheet
// Coupon is staged globally — no vehicle price check here.
// ─────────────────────────────────────────────────────────────────────────────
class _CouponSelectionSheet extends StatefulWidget {
  const _CouponSelectionSheet({required this.couponCtr});
  final CouponController couponCtr;

  @override
  State<_CouponSelectionSheet> createState() => _CouponSelectionSheetState();
}

class _CouponSelectionSheetState extends State<_CouponSelectionSheet> {
  CouponController get couponCtr => widget.couponCtr;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
            child: Row(
              children: [
                const Icon(Icons.local_offer, size: 22, color: Colors.black87),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Apply Coupon".tr,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black87),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.black54),
                ),
              ],
            ),
          ),

          // Manual code entry
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: couponCtr.couponCodeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: "Enter coupon code".tr,
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                      prefixIcon: Icon(Icons.confirmation_number_outlined,
                          color: Colors.blue.shade400, size: 20),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    final code = couponCtr.couponCodeController.text.trim();
                    if (code.isEmpty) {
                      ShowToastDialog.showToast("Please enter a coupon code".tr);
                      return;
                    }
                    final ok = couponCtr.applyCouponByCode(code);
                    if (ok) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ConstantColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text("Apply".tr,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),

          Divider(color: Colors.grey.shade200, height: 1),

          // Coupon list
          Flexible(
            child: Obx(
                  () => ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                shrinkWrap: true,
                itemCount: couponCtr.coupanCodeList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) {
                  final promo = couponCtr.coupanCodeList[index];
                  return _CouponTile(
                    promo: promo,
                    couponCtr: couponCtr,
                    onApplied: () => Navigator.pop(context),
                    onInfo: () => showCouponInfoBottomSheet(context, promo),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single coupon tile — stages coupon without amount validation.
// ─────────────────────────────────────────────────────────────────────────────
class _CouponTile extends StatelessWidget {
  const _CouponTile({
    required this.promo,
    required this.couponCtr,
    required this.onApplied,
    required this.onInfo,
  });

  final CoupanCodeData promo;
  final CouponController couponCtr;
  final VoidCallback onApplied;
  final VoidCallback onInfo;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isApplied = couponCtr.selectedPromoCode.value == promo.code;

      return Container(
        decoration: BoxDecoration(
          color: isApplied ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isApplied ? Colors.green.shade300 : Colors.grey.shade200,
            width: isApplied ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: icon + description + discount badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isApplied
                            ? [Colors.green.shade400, Colors.green.shade600]
                            : [Colors.blue.shade400, Colors.blue.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isApplied ? Icons.check_circle : Icons.local_offer,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      promo.discription.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.green.shade400, Colors.green.shade600]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      promo.type == "Percentage"
                          ? "${promo.discount}% OFF"
                          : "${Constant().amountShow(amount: promo.discount.toString())} OFF",
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Code row + info + Apply/Remove
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      FlutterClipboard.copy(promo.code.toString());
                      ShowToastDialog.showToast("Code copied!");
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: (isApplied ? Colors.green : Colors.blue).withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            promo.code.toString(),
                            style: TextStyle(
                              color: isApplied ? Colors.green[700] : Colors.blue[700],
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.content_copy,
                              size: 13,
                              color: isApplied ? Colors.green[700] : Colors.blue[700]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: onInfo,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isApplied ? Colors.green : Colors.blue).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.info_outline,
                          color: isApplied ? Colors.green[700] : Colors.blue[700], size: 18),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      if (isApplied) {
                        couponCtr.clearCoupon();
                      } else {
                        final idx = couponCtr.coupanCodeList.indexOf(promo);
                        final ok  = couponCtr.applyCouponByIndex(idx);
                        if (ok) onApplied();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isApplied ? Colors.red.shade50 : ConstantColors.primary,
                      foregroundColor: isApplied ? Colors.red.shade600 : Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                            color: isApplied ? Colors.red.shade200 : Colors.transparent),
                      ),
                    ),
                    child: Text(
                      isApplied ? "Remove".tr : "Apply".tr,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Expiry
              Row(
                children: [
                  Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Builder(builder: (_) {
                      String label;
                      try {
                        final dt = DateFormat('dd MMMM yyyy hh:mm a')
                            .parse("${promo.expireAt}");
                        label = DateFormat('dd MMM yyyy • hh:mm a').format(dt);
                      } catch (_) {
                        label = "${promo.expireAt}";
                      }
                      return Text(
                        "${"Valid till".tr} $label",
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    }),
                  ),
                ],
              ),

              // Min order
              if (promo.minimum_amount != null &&
                  int.tryParse(promo.minimum_amount.toString()) != null &&
                  int.tryParse(promo.minimum_amount.toString())! > 0) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.shopping_cart_outlined,
                        size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      "${"Min. order:".tr} ${Constant().amountShow(amount: promo.minimum_amount.toString())}",
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ],

              // Max discount cap
              // if (promo.maxDiscount != null &&
              //     double.tryParse(promo.maxDiscount.toString()) != null &&
              //     double.tryParse(promo.maxDiscount.toString())! > 0) ...[
              //   const SizedBox(height: 4),
              //   Row(
              //     children: [
              //       Icon(Icons.price_check, size: 12, color: Colors.grey.shade500),
              //       const SizedBox(width: 4),
              //       Text(
              //         "${"Max discount:".tr} ${Constant().amountShow(amount: promo.maxDiscount.toString())}",
              //         style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              //       ),
              //     ],
              //   ),
              // ],
            ],
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vehicle card
//
// Three price-column states:
//   1. No coupon staged          → plain price
//   2. Coupon staged, applicable → strikethrough + discounted + "Save X" chip
//   3. Coupon staged, not valid  → plain price + orange "Not applicable" chip
// ─────────────────────────────────────────────────────────────────────────────
class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.vehicleData,
    required this.homeCtr,
    required this.couponCtr,
    required this.onSelected,
    required this.onInfoTap,
  });

  final VehicleData vehicleData;
  final HomeController homeCtr;
  final CouponController couponCtr;
  final VoidCallback onSelected;
  final VoidCallback onInfoTap;

  double _rawPrice() {
    final formatted = Constant().amountShow(
      amount: "${homeCtr.calculateTripPrice(
        distance: homeCtr.distance.value,
        deliveryCharges: double.parse(vehicleData.deliveryCharges!),
        minimumDeliveryCharges: double.parse(vehicleData.minimumDeliveryCharges!),
        minimumDeliveryChargesWithin: double.parse(vehicleData.minimumDeliveryChargesWithin!),
        outstation_radius: double.parse(vehicleData.outstation_radius!),
        outstation_delivery_charge_per_km:
        double.parse(vehicleData.outstation_delivery_charge_per_km!),
      )}",
    );
    return double.tryParse(Constant().sanitizePrice(formatted)) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = homeCtr.selectedVehicle.value == vehicleData.id.toString();
      final couponStaged = couponCtr.selectedPromoCode.value.isNotEmpty;

      final eval = couponCtr.evaluateForVehicle(_rawPrice());
      final pricing = buildBookingPriceBreakdown(
        baseFare: _rawPrice(),
        discount: eval.isApplicable ? eval.discountAmount.toDouble() : 0.0,
      );

      final originalPriceWithGst = _amountWithGst(_rawPrice());
      final discountedPriceWithGst = _amountWithGst(eval.finalPrice.toDouble());

      final originalPriceStr  = Constant().amountShow(amount: "$originalPriceWithGst");
      final discountedPriceStr = Constant().amountShow(amount: "$discountedPriceWithGst");
      final savingStr = Constant()
          .amountShow(amount: "${eval.discountAmount.toStringAsFixed(2)}");

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () {
            homeCtr.selectVehicle(vehicleData);
            onSelected();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? ConstantColors.primary.withOpacity(0.02)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? ConstantColors.primary : Colors.grey.shade300,
                width: isSelected ? 2.0 : 1.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Image
                  Container(
                    width: 70,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: vehicleData.image.toString(),
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Constant.loader(),
                        errorWidget: (_, __, ___) =>
                            Icon(Icons.directions_car, color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicleData.libelle.toString(),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? ConstantColors.primary : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (vehicleData.distance != "0") ...[
                              Icon(Icons.access_time,
                                  size: 12, color: Colors.green.shade600),
                              const SizedBox(width: 4),
                            ],
                            Flexible(
                              child: Text(
                                vehicleData.distance == "0"
                                    ? "No nearby driver available"
                                    : "ETA ${vehicleData.distance ?? '--'}",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: vehicleData.distance == "0"
                                      ? Colors.grey.shade700
                                      : Colors.green.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Info icon (selected only)
                  if (isSelected) ...[
                    InkWell(onTap: onInfoTap, child: Image.asset(kImgInfo, width: 20)),
                    const SizedBox(width: 10),
                  ],

                  // ── Price column ────────────────────────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!couponStaged) ...[
                        // ① No coupon — plain price
                        Text(
          Constant().amountShow(amount: pricing.finalPrice.toStringAsFixed(2)),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? ConstantColors.primary : Colors.black87,
                          ),
                        ),
                      ] else if (eval.isApplicable) ...[
                        // ② Coupon applicable — strikethrough + discounted + save chip
                        Text(
                          originalPriceStr,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade500,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.grey.shade500,
                            decorationThickness: 1.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$discountedPriceStr',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? ConstantColors.primary
                                : Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            "${"Save".tr} $savingStr",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ] else ...[
                        // ③ Coupon staged but not applicable — plain price + orange note
                        Text(
                          'Surprise Amount $originalPriceStr',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? ConstantColors.primary : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Text(
                            eval.reason.isNotEmpty ? eval.reason : "Not applicable",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Price breakdown sheet
// Uses evaluateForVehicle — stays reactive to coupon changes.
// ─────────────────────────────────────────────────────────────────────────────
class _PriceBreakdownSheet extends StatelessWidget {
  const _PriceBreakdownSheet({
    required this.vehicleData,
    required this.total,
    required this.newDistance,
    required this.perKm,
    required this.homeCtr,
    required this.couponCtr,
  });

  final VehicleData vehicleData;
  final num total;
  final double newDistance;
  final num perKm;
  final HomeController homeCtr;
  final CouponController couponCtr;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final eval       = couponCtr.evaluateForVehicle(total.toDouble());
      final hasCoupon  = couponCtr.selectedPromoCode.value.isNotEmpty && eval.isApplicable;
      final discountAmount = eval.isApplicable ? eval.discountAmount.toDouble() : 0.0;
      final pricing = buildBookingPriceBreakdown(
        baseFare: total.toDouble(),
        discount: discountAmount,
      );

      return SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('🟡 ZoCar Surprise Fare',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Vehicle info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: vehicleData.image.toString(),
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Constant.loader(),
                          errorWidget: (_, __, ___) =>
                              Icon(Icons.directions_car, color: Colors.grey.shade400),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(vehicleData.libelle.toString(),
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600)),
                          Text('${homeCtr.distance.value.toStringAsFixed(2)} km',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Divider(color: Colors.grey.shade300),
              const SizedBox(height: 5),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    // Base fare
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('🎁 Surprise Fare',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 2),
                            Text('(Total distance included)',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ),
                        Text(
                          Constant().amountShow(amount: "$total"),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: hasCoupon
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: Colors.grey.shade500,
                            decorationThickness: 1.8,
                            color: hasCoupon ? Colors.grey.shade500 : Colors.black87,
                          ),
                        ),
                      ],
                    ),

                    // Per-km extra
                    if (newDistance > 0) ...[
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Extra Kilometer Charge\nAfter included distance',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text("${Constant().amountShow(amount: "$perKm")}/-",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],

                    // Coupon discount row
                    if (hasCoupon) ...[
                      const SizedBox(height: 10),
                      Divider(color: Colors.green.shade100),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.local_offer,
                                  size: 14, color: Colors.green.shade600),
                              const SizedBox(width: 6),
                              Text(
                                "${"Coupon".tr} (${couponCtr.selectedPromoCode.value})",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "- ${Constant().amountShow(amount: "${eval.discountAmount}")}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (pricing.commission > 0) ...[
                      const SizedBox(height: 10),
                      Divider(color: Colors.grey.shade200),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Admin Commission (${pricing.commissionType})',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            Constant().amountShow(amount: pricing.commission.toStringAsFixed(2)),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (pricing.taxAmount > 0) ...[
                      const SizedBox(height: 10),
                      Divider(color: Colors.grey.shade200),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _gstBreakdownLabel(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            Constant().amountShow(amount: pricing.taxAmount.toStringAsFixed(2)),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // "Not applicable" note in breakdown
                    if (couponCtr.selectedPromoCode.value.isNotEmpty && !eval.isApplicable) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                size: 14, color: Colors.orange.shade700),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                eval.reason.isNotEmpty
                                    ? eval.reason
                                    : "Coupon not applicable to this vehicle",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.orange.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 5),
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 5),

                    // Total
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ConstantColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: ConstantColors.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('💰 Surprise Amount',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            Constant().amountShow(amount: pricing.finalPrice.toStringAsFixed(2)),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ConstantColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('* ',
                        style: TextStyle(
                            fontSize: 14, color: ConstantColors.primary)),
                    const Expanded(
                      child: Text('Toll & Parking Charges Extra',
                          style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    });
  }
}