import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../constant/constant.dart';
import '../../../constant/show_toast_dialog.dart';
import '../../../controller/coupon_controller.dart';
import '../../../controller/home_controller.dart';
import '../../../helpers/booking_price_helper.dart';
import '../../../helpers/payment_gateway.dart';
import '../../../model/coupan_code_model.dart';
import '../../../page/all_rides/coupon_info_sheet.dart';
import '../../../service/api.dart';
import '../../../themes/constant_colors.dart';
import '../../../utils/preferences.dart';
import 'custom_rental_booking_controller.dart';
import 'custom_rental_vehicle_model.dart';

String _customRentalTaxType(String? type) {
  final t = (type ?? '').trim().toLowerCase();
  if (t == 'amount' || t == 'fixed') return 'amount';
  return 'percentage';
}

double _customRentalTaxAmount(double baseAmount) {
  double taxTotal = 0.0;
  for (final tax in Constant.taxList) {
    if ((tax.statut ?? '').trim().toLowerCase() != 'yes') continue;
    final value = double.tryParse(tax.value ?? '') ?? 0.0;
    if (value <= 0) continue;
    final type = _customRentalTaxType(tax.type);
    taxTotal += type == 'amount' ? value : (baseAmount * value) / 100;
  }
  return taxTotal;
}

double _customRentalPriceWithTax(double baseAmount) {
  return baseAmount + _customRentalTaxAmount(baseAmount);
}

class CustomRentalBookingScreen extends StatefulWidget {
  final String latitude;
  final String longitude;
  final String departureName;

  const CustomRentalBookingScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.departureName,
  });

  @override
  State<CustomRentalBookingScreen> createState() => _CustomRentalBookingScreenState();
}

class _CustomRentalBookingScreenState extends State<CustomRentalBookingScreen> {
  final ctrl = Get.put(CustomRentalBookingController());
  late final CouponController couponCtr;
  final kmController = TextEditingController();
  final TextEditingController _pickupController = TextEditingController();
  bool _booking = false;
  bool _pickupLocLoading = false;

  @override
  void initState() {
    super.initState();
    couponCtr = Get.isRegistered<CouponController>() ? Get.find<CouponController>() : Get.put(CouponController());
    ctrl.latitude = widget.latitude;
    ctrl.longitude = widget.longitude;
    ctrl.departureName = widget.departureName;
    _pickupController.text = widget.departureName;
    WidgetsBinding.instance.addPostFrameCallback((_) => ctrl.loadVehicleCatalog());
  }

  @override
  void dispose() {
    kmController.dispose();
    _pickupController.dispose();
    Get.delete<CustomRentalBookingController>();
    super.dispose();
  }

  // ── Date/Time Pickers ─────────────────────────────────────────────────────

  Future<void> _pickDateTime({required bool isPickup}) async {
    final now = DateTime.now();
    final initial = isPickup ? (ctrl.pickupDateTime.value ?? now) : (ctrl.dropDateTime.value ?? (ctrl.pickupDateTime.value ?? now));

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;

    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    if (isPickup) {
      ctrl.pickupDateTime.value = dt;
      // If drop is before new pickup, reset it
      if (ctrl.dropDateTime.value != null && ctrl.dropDateTime.value!.isBefore(dt)) {
        ctrl.dropDateTime.value = null;
      }
    } else {
      if (ctrl.pickupDateTime.value != null && dt.isBefore(ctrl.pickupDateTime.value!)) {
        ShowToastDialog.showToast('Drop time must be after pickup time');
        return;
      }
      ctrl.dropDateTime.value = dt;
    }
  }

  void _validateAndBook() {
    if (_pickupController.text.trim().isEmpty) {
      ShowToastDialog.showToast('Please select pickup address');
      return;
    }
    if (ctrl.latitude.trim().isEmpty || ctrl.longitude.trim().isEmpty) {
      ShowToastDialog.showToast('Please select pickup location on map');
      return;
    }
    if (ctrl.pickupDateTime.value == null) {
      ShowToastDialog.showToast('Please select pickup date & time');
      return;
    }
    if (ctrl.dropDateTime.value == null) {
      ShowToastDialog.showToast('Please select drop date & time');
      return;
    }
    if (ctrl.totalKm.value <= 0) {
      ShowToastDialog.showToast('Please enter total kilometres');
      return;
    }
    if (ctrl.totalHours.value <= 0) {
      ShowToastDialog.showToast('Drop time must be after pickup time');
      return;
    }
    if (ctrl.selectedVehicle.value == null) {
      ShowToastDialog.showToast('Please select a vehicle category');
      return;
    }
    _onPaymentSuccess();
  }

  Future<void> _initiatePayment() async {
    setState(() => _booking = true);
    final advance = ctrl.advanceAmount;

    if (advance <= 0) {
      // await _onPaymentSuccess(null);
    } else {
      PaymentGateway.instance.openRazorPay(
        amount: advance,
        onSuccess: (response) async {
          ShowToastDialog.showToast('Payment successful');
          // await _onPaymentSuccess(response.paymentId);
        },
        onFailure: () {
          setState(() => _booking = false);
        },
      );
    }
  }

  Future<void> _onPaymentSuccess() async {
    try {
      final v = ctrl.selectedVehicle.value!;
      final pickup = ctrl.pickupDateTime.value!;
      final drop = ctrl.dropDateTime.value!;
      final baseFare = ctrl.selectedPrice;
      final pricing = buildBookingPriceBreakdown(
        baseFare: baseFare,
        discount: couponCtr.discountAmount.value.toDouble(),
      );

      // New rental booking API (as per provided curl)
      final body = jsonEncode({
        'user_id': Preferences.getInt(Preferences.userId),
        'vehicle_id': int.tryParse(v.id) ?? v.id,
        'pickup_date': DateFormat('yyyy-MM-dd').format(pickup),
        'pickup_time': DateFormat('HH:mm').format(pickup),
        'drop_date': DateFormat('yyyy-MM-dd').format(drop),
        'drop_time': DateFormat('HH:mm').format(drop),
        'pickup_address': _pickupController.text.trim(),
        'pickup_lat': ctrl.latitude,
        'pickup_lng': ctrl.longitude,
        'total_km': ctrl.totalKm.value.round(),
        'total_hours': ctrl.totalHours.value,
        'price': pricing.finalPrice,
        'discount': pricing.discount.toStringAsFixed(2),
        'coupon_id': couponCtr.selectedPromoId.value,
        'assign_id': couponCtr.selectedAssignId.value,
        'base_fare': pricing.baseFare.toStringAsFixed(2),
        'admission_commision': pricing.commission.toStringAsFixed(2),
        'admin_commission': pricing.commission.toStringAsFixed(2),
        'commision_type': pricing.commissionType,
        'tax_amount': pricing.taxAmount.toStringAsFixed(2),
        'final_price': pricing.finalPrice.toStringAsFixed(2),
      });

      final response = await LoggingClient(http.Client()).post(Uri.parse(API.rentalBooking), body: body, headers: API.header);

      final responseBody = json.safeDecode(response.body);
      final success = responseBody['success'] == 'success' ||
          responseBody['success'] == true ||
          responseBody['success']?.toString().toLowerCase() == 'success';
      if (response.statusCode == 200 && success) {
        _showSuccessDialog();
      } else {
        ShowToastDialog.showToast('Booking failed. Please try again.');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
    } finally {
      setState(() => _booking = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Image.asset('assets/images/green_checked.png', height: 80),
            const SizedBox(height: 16),
            const Text('Booking Sent!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Your custom rental booking has been sent. A driver will accept your ride shortly.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: ConstantColors.primary),
                onPressed: () {
                  Get.back();
                  Get.back();
                },
                child: const Text('Done', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Rental Booking'),
        backgroundColor: ConstantColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPickupSection(),
            const SizedBox(height: 16),
            _buildDateTimeSection(),
            const SizedBox(height: 16),
            _buildKmSection(),
            const SizedBox(height: 16),
            _buildCouponSection(),
            const SizedBox(height: 16),
            _buildVehicleSection(),
            const SizedBox(height: 16),
            _buildBookButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pickup address',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickupLocLoading
                  ? null
                  : () async {
                      HomeController homeCtr;
                      try {
                        homeCtr = Get.find<HomeController>();
                      } catch (_) {
                        homeCtr = Get.put(HomeController());
                      }

                      final value = await homeCtr.placeSelectAPI(context);
                      if (value == null) return;

                      final lat = value.result.geometry?.location.lat;
                      final lng = value.result.geometry?.location.lng;
                      final addr = value.result.formattedAddress?.toString() ?? '';

                      if (lat == null || lng == null || addr.isEmpty) return;

                      setState(() {
                        _pickupController.text = addr;
                      });
                      ctrl.departureName = addr;
                      ctrl.latitude = lat.toString();
                      ctrl.longitude = lng.toString();
                    },
              child: AbsorbPointer(
                child: TextField(
                  controller: _pickupController,
                  maxLines: 2,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Select pickup address',
                    prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                    suffixIcon: _pickupLocLoading
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CupertinoActivityIndicator(),
                          )
                        : IconButton(
                            tooltip: 'Use current location',
                            onPressed: () async {
                              if (_pickupLocLoading) return;
                              setState(() => _pickupLocLoading = true);
                              try {
                                final pos = await Geolocator.getCurrentPosition();
                                final placemarks = await geocoding.placemarkFromCoordinates(
                                  pos.latitude,
                                  pos.longitude,
                                );
                                final pm = placemarks.isNotEmpty ? placemarks.first : null;
                                final address = pm == null
                                    ? ''
                                    : [
                                        pm.name,
                                        pm.street,
                                        pm.subLocality,
                                        pm.locality,
                                        pm.administrativeArea,
                                        pm.postalCode,
                                        pm.country,
                                      ].where((e) => (e ?? '').toString().trim().isNotEmpty).join(', ');

                                if (address.isNotEmpty) {
                                  _pickupController.text = address;
                                  ctrl.departureName = address;
                                }
                                ctrl.latitude = pos.latitude.toString();
                                ctrl.longitude = pos.longitude.toString();
                              } catch (e) {
                                ShowToastDialog.showToast('Could not fetch current location');
                              } finally {
                                if (mounted) setState(() => _pickupLocLoading = false);
                              }
                            },
                            icon: const Icon(Icons.my_location),
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // const Text(
            //   'Tap to select Google address. Or use current location button.',
            //   style: TextStyle(fontSize: 11, color: Colors.grey),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Trip Duration', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _dateTimeButton(label: 'Pickup', isPickup: true)),
              const SizedBox(width: 10),
              Expanded(child: _dateTimeButton(label: 'Drop', isPickup: false)),
            ]),
            const SizedBox(height: 12),
            Obx(() {
              final hours = ctrl.totalHours.value;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: hours > 0 ? Colors.blue.withOpacity(0.08) : Colors.grey.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: hours > 0 ? Colors.blue.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Auto-calculated hours', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    Text(
                      hours > 0 ? '$hours hrs' : '—',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: hours > 0 ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _dateTimeButton({required String label, required bool isPickup}) {
    return Obx(() {
      final dt = isPickup ? ctrl.pickupDateTime.value : ctrl.dropDateTime.value;
      return GestureDetector(
        onTap: () => _pickDateTime(isPickup: isPickup),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: dt != null ? Colors.blue : Colors.grey.withOpacity(0.4),
              width: dt != null ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(
                dt != null ? DateFormat('dd MMM, HH:mm').format(dt) : 'Select',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: dt != null ? Colors.black : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildKmSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Total Kilometres', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Enter expected total km for this trip', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            TextField(
              controller: kmController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'e.g. 120',
                suffixText: 'km',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              onChanged: (val) {
                ctrl.totalKm.value = double.tryParse(val) ?? 0;
              },
            ),
            const SizedBox(height: 8),
            const Text(
              '• Extra km beyond this will be charged separately by the driver.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleSection() {
    return Obx(() {
      final canShow = ctrl.totalKm.value > 0 && ctrl.totalHours.value > 0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Choose Vehicle', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (!canShow)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('Enter km & select dates to see vehicle prices', style: TextStyle(color: Colors.grey, fontSize: 13), textAlign: TextAlign.center),
              ),
            )
          else if (ctrl.isLoadingVehicles.value)
            const Center(child: CircularProgressIndicator())
          else if (ctrl.vehicles.isEmpty)
            const Center(child: Text('No vehicles available'))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ctrl.vehicles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _vehicleCard(ctrl.vehicles[i]),
            ),

          // Advance payment info
          // if (ctrl.selectedVehicle.value != null) ...[
          //   const SizedBox(height: 12),
          //   Container(
          //     width: double.infinity,
          //     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          //     decoration: BoxDecoration(
          //       color: Colors.blue.withOpacity(0.08),
          //       borderRadius: BorderRadius.circular(8),
          //       border: Border.all(color: Colors.blue.withOpacity(0.25)),
          //     ),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Text(
          //           'Pay advance (${Preferences.getInitialPaymentPercentage()}%)',
          //           style: const TextStyle(fontSize: 13, color: Colors.grey),
          //         ),
          //         Text(
          //           '₹${ctrl.advanceAmount.toStringAsFixed(0)}',
          //           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
          //         ),
          //       ],
          //     ),
          //   ),
          // ],
        ],
      );
    });
  }

  Widget _vehicleCard(CustomRentalVehicle v) {
    return Obx(() {
      final isSelected = ctrl.selectedVehicle.value?.id == v.id;
      final price = ctrl.priceFor(v);
      final eval = couponCtr.evaluateForVehicle(price);
      final pricing = buildBookingPriceBreakdown(
        baseFare: price,
        discount: eval.isApplicable ? eval.discountAmount.toDouble() : 0.0,
      );
      return GestureDetector(
        onTap: () {
          ctrl.selectedVehicle.value = v;
          couponCtr.finalizeForPayment(_customRentalPriceWithTax(price));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.withOpacity(0.06) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.25),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Vehicle image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  v.image,
                  height: 50,
                  width: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 50,
                    width: 70,
                    color: Colors.grey.withOpacity(0.15),
                    child: const Icon(Icons.directions_car_outlined, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(v.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.blue : Colors.black,
                        )),
                    Text(v.description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 2),
                    if (v.serverTotalPrice != null &&
                        v.quoteTotalHours != null &&
                        v.quoteTotalKm != null)
                      Text(
                        '${v.quoteTotalHours!.toStringAsFixed(0)} hrs · ${v.quoteTotalKm!.toStringAsFixed(0)} km (quoted)',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      )
                    else
                      Text('₹${v.ratePerKm}/km · ₹${v.ratePerHour}/hr', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (eval.isApplicable)
                    Text(
                      '₹${price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Text(
                    '₹${pricing.finalPrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.blue : Colors.black,
                    ),
                  ),
                  if (eval.isApplicable)
                    Text(
                      '-₹${eval.discountAmount}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  InkWell(
                    onTap: () => _showCustomRentalFareBreakdown(
                      vehicleName: v.name,
                      imageUrl: v.image,
                      basePrice: price,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline, size: 12, color: Colors.blue),
                          SizedBox(width: 2),
                          Text(
                            'Fare',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // const Text('total', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showCustomRentalFareBreakdown({
    required String vehicleName,
    required String imageUrl,
    required double basePrice,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Obx(() {
            final eval = couponCtr.evaluateForVehicle(basePrice);
            final hasCoupon =
                couponCtr.selectedPromoCode.value.isNotEmpty && eval.isApplicable;
            final pricing = buildBookingPriceBreakdown(
              baseFare: basePrice,
              discount: eval.isApplicable ? eval.discountAmount.toDouble() : 0.0,
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
                        const Text(
                          '🟡 ZoCar Surprise Fare',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            height: 40,
                            width: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 40,
                              width: 60,
                              color: Colors.grey.withOpacity(0.15),
                              child: const Icon(Icons.directions_car_outlined,
                                  color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            vehicleName,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 6),
                    _fareRow(
                      '🎁 Surprise Fare',
                      Constant()
                          .amountShow(amount: basePrice.toStringAsFixed(2)),
                    ),
                    if (hasCoupon)
                      _fareRow(
                        'Coupon (${couponCtr.selectedPromoCode.value})',
                        '- ${Constant().amountShow(amount: eval.discountAmount.toString())}',
                        color: Colors.green.shade700,
                      ),
                    if (pricing.commission > 0)
                      _fareRow(
                        'Admin Commission (${pricing.commissionType})',
                        Constant().amountShow(
                            amount: pricing.commission.toStringAsFixed(2)),
                      ),
                    if (pricing.taxAmount > 0)
                      _fareRow(
                        'GST / Tax',
                        Constant()
                            .amountShow(amount: pricing.taxAmount.toStringAsFixed(2)),
                      ),
                    const SizedBox(height: 8),
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: ConstantColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: ConstantColors.primary.withOpacity(0.25),
                        ),
                      ),
                      child: _fareRow(
                        '💰 Surprise Amount',
                        Constant()
                            .amountShow(amount: pricing.finalPrice.toStringAsFixed(2)),
                        bold: true,
                        color: ConstantColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  Widget _fareRow(String label, String value, {Color? color, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: bold ? 16 : 14,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 18 : 15,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ConstantColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _booking ? null : _validateAndBook,
        child: _booking
            ? const CupertinoActivityIndicator(color: Colors.white)
            : const Text('Pay Advance & Book', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildCouponSection() {
    return Obx(() {
      final isApplied = couponCtr.selectedPromoCode.value.isNotEmpty;
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _openCouponSheet,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.local_offer_outlined, color: isApplied ? Colors.green : Colors.blue),
                const SizedBox(width: 10),
                Expanded(
                  child: isApplied
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '"${couponCtr.selectedPromoCode.value}" applied',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Saves ${couponCtr.selectedPromoValue.value}',
                              style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                            ),
                          ],
                        )
                      : Text(
                          'Apply Coupon',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                ),
                if (isApplied)
                  GestureDetector(
                    onTap: couponCtr.clearCoupon,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(Icons.close, size: 18, color: Colors.green.shade700),
                    ),
                  )
                else
                  Icon(Icons.chevron_right, color: Colors.grey.shade500),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _openCouponSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CustomRentalCouponSelectionSheet(couponCtr: couponCtr),
    );
  }
}

class _CustomRentalCouponSelectionSheet extends StatelessWidget {
  const _CustomRentalCouponSelectionSheet({required this.couponCtr});
  final CouponController couponCtr;

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
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: couponCtr.couponCodeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Enter coupon code',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    final code = couponCtr.couponCodeController.text.trim();
                    if (code.isEmpty) {
                      ShowToastDialog.showToast('Please enter a coupon code');
                      return;
                    }
                    final ok = couponCtr.applyCouponByCode(code);
                    if (ok) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ConstantColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ),
          Flexible(
            child: Obx(
              () => ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                shrinkWrap: true,
                itemCount: couponCtr.coupanCodeList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, index) {
                  final promo = couponCtr.coupanCodeList[index];
                  return _CustomRentalCouponTile(
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

class _CustomRentalCouponTile extends StatelessWidget {
  const _CustomRentalCouponTile({
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isApplied ? Colors.green : Colors.grey.shade300),
          color: isApplied ? Colors.green.withOpacity(0.06) : Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promo.code?.toUpperCase() ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    promo.discription?.toString().isNotEmpty == true
                        ? promo.discription.toString()
                        :
                    'Tap to apply this coupon',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            TextButton(onPressed: onInfo, child: const Text('Info')),
            const SizedBox(width: 4),
            ElevatedButton(
              onPressed: () {
                if (isApplied) {
                  couponCtr.clearCoupon();
                  ShowToastDialog.showToast('Coupon removed');
                  return;
                }
                final idx = couponCtr.coupanCodeList.indexOf(promo);
                final ok = couponCtr.applyCouponByIndex(idx);
                if (ok) onApplied();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isApplied ? Colors.grey.shade300 : ConstantColors.primary,
                foregroundColor: isApplied ? Colors.black87 : Colors.white,
              ),
              child: Text(isApplied ? 'Applied' : 'Apply'),
            ),
          ],
        ),
      );
    });
  }
}
