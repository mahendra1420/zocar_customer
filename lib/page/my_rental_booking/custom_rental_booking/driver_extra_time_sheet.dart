import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:zocar/constant/logdata.dart';
import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/helpers/devlog.dart';
import 'package:zocar/service/api.dart';
import 'package:zocar/themes/constant_colors.dart';

import 'custom_rental_refund_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DRIVER EXTRA TIME BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────

/// Show this on the driver's side when they accept a custom rental booking.
/// They can add extra hours; the extra amount is shown to both parties.
class DriverExtraTimeSheet extends StatefulWidget {
  final String bookingId;
  final double baseAmount;
  final double extraRatePerHour; // ₹ per extra hour beyond booked hours
  final VoidCallback onConfirmed;

  const DriverExtraTimeSheet({
    super.key,
    required this.bookingId,
    required this.baseAmount,
    required this.extraRatePerHour,
    required this.onConfirmed,
  });

  static Future<void> show({
    required BuildContext context,
    required String bookingId,
    required double baseAmount,
    required double extraRatePerHour,
    required VoidCallback onConfirmed,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DriverExtraTimeSheet(
        bookingId: bookingId,
        baseAmount: baseAmount,
        extraRatePerHour: extraRatePerHour,
        onConfirmed: onConfirmed,
      ),
    );
  }

  @override
  State<DriverExtraTimeSheet> createState() => _DriverExtraTimeSheetState();
}

class _DriverExtraTimeSheetState extends State<DriverExtraTimeSheet> {
  int _extraHours = 0;
  bool _submitting = false;

  double get _extraCharge => _extraHours * widget.extraRatePerHour;
  double get _totalAmount => widget.baseAmount + _extraCharge;

  Future<void> _confirmAndSubmit() async {
    setState(() => _submitting = true);
    try {
      final body = jsonEncode({
        'booking_id': widget.bookingId,
        'extra_hours': _extraHours,
        'extra_charge': _extraCharge,
        'total_amount': _totalAmount,
      });
      final response = await LoggingClient(http.Client())
          .post(Uri.parse(API.addExtraTimeToCustomRental), body: body, headers: API.header);
      final responseBody = json.safeDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == 'success') {
        ShowToastDialog.showToast('Extra time added successfully');
        Get.back();
        widget.onConfirmed();
      } else {
        ShowToastDialog.showToast('Failed to add extra time. Please try again.');
      }
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Add Extra Time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text(
              'If the trip takes longer than booked hours, add extra time here.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Base amount info
            _infoRow('Booked amount', '₹${widget.baseAmount.toStringAsFixed(0 )}'),
            const SizedBox(height: 8),
            _infoRow('Extra rate', '₹${widget.extraRatePerHour.toStringAsFixed(0)} / hr'),
            const Divider(height: 24),

            // Extra hours stepper
            Row(
              children: [
                const Text('Extra hours', style: TextStyle(fontSize: 15)),
                const Spacer(),
                _stepperButton(Icons.remove, () {
                  if (_extraHours > 0) setState(() => _extraHours--);
                }),
                const SizedBox(width: 16),
                Text('$_extraHours', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                _stepperButton(Icons.add, () => setState(() => _extraHours++)),
              ],
            ),

            // Extra charge display
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: _extraHours > 0
                  ? Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.withOpacity(0.25)),
                    ),
                    child: Column(
                      children: [
                        _infoRow('Extra charge', '₹${_extraCharge.toStringAsFixed(0)}', highlight: true),
                        const SizedBox(height: 6),
                        _infoRow('New total', '₹${_totalAmount.toStringAsFixed(0)}', bold: true),
                      ],
                    ),
                  ),
                ],
              )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ConstantColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _submitting ? null : _confirmAndSubmit,
                child: _submitting
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : Text(
                  _extraHours > 0 ? 'Confirm Extra Time & Accept' : 'Accept Ride',
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _stepperButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool highlight = false, bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 15 : 13,
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            color: highlight ? Colors.orange.shade800 : Colors.black,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DRIVER BOOKING DECISION WIDGET
// ─────────────────────────────────────────────────────────────────────────────

/// Use this in the driver app's booking detail screen.
/// Handles accept (with optional extra time) and reject (with auto-refund).
class DriverBookingDecisionWidget extends StatefulWidget {
  final String bookingId;
  final String paymentId;
  final double baseAmount;
  final double advanceAmount;
  final double extraRatePerHour;
  final String customerName;
  final String pickupAddress;
  final String totalKm;
  final String totalHours;

  const DriverBookingDecisionWidget({
    super.key,
    required this.bookingId,
    required this.paymentId,
    required this.baseAmount,
    required this.advanceAmount,
    required this.extraRatePerHour,
    required this.customerName,
    required this.pickupAddress,
    required this.totalKm,
    required this.totalHours,
  });

  @override
  State<DriverBookingDecisionWidget> createState() => _DriverBookingDecisionWidgetState();
}

class _DriverBookingDecisionWidgetState extends State<DriverBookingDecisionWidget> {
  bool _processing = false;

  Future<void> _onAccept() async {
    // Show extra time sheet before confirming
    await DriverExtraTimeSheet.show(
      context: context,
      bookingId: widget.bookingId,
      baseAmount: widget.baseAmount,
      extraRatePerHour: widget.extraRatePerHour,
      onConfirmed: () {
        ShowToastDialog.showToast('Booking accepted!');
        // Navigate driver to tracking screen here
      },
    );
  }

  Future<void> _onReject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reject Booking?'),
        content: const Text(
          'If you reject this booking, the customer\'s advance payment will be automatically refunded. Are you sure?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _processing = true);
    ShowToastDialog.showLoader('Processing...');

    // 1. Update booking status to rejected on backend
    try {
      final body = jsonEncode({'booking_id': widget.bookingId, 'status': 'rejected'});
      await LoggingClient(http.Client())
          .post(Uri.parse(API.updateCustomRentalStatus), body: body, headers: API.header);
    } catch (_) {}

    // 2. Initiate refund automatically
    final refunded = await CustomRentalRefundService.initiateRefund(
      bookingId: widget.bookingId,
      paymentId: widget.paymentId,
      refundAmount: widget.advanceAmount,
    );

    ShowToastDialog.closeLoader();
    setState(() => _processing = false);

    if (refunded) {
      ShowToastDialog.showToast('Booking rejected. Customer refund initiated.');
    } else {
      ShowToastDialog.showToast('Booking rejected. Refund will be processed by admin.');
    }

    Get.back(); // Return to bookings list
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFB5D4F4),
                  child: Icon(Icons.person, color: Color(0xFF0C447C)),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.customerName,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    Text('Custom Rental Booking',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('New', style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(height: 20),

            // Booking details
            _detailRow(Icons.location_on_outlined, widget.pickupAddress),
            const SizedBox(height: 8),
            _detailRow(Icons.route_outlined, '${widget.totalKm} km · ${widget.totalHours} hrs'),
            const SizedBox(height: 8),
            _detailRow(Icons.currency_rupee, '₹${widget.baseAmount.toStringAsFixed(0)} total   |   ₹${widget.advanceAmount.toStringAsFixed(0)} advance paid'),
            const Divider(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onPressed: _processing ? null : _onReject,
                    child: const Text('Reject', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B6D11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onPressed: _processing ? null : _onAccept,
                    child: const Text('Accept', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
      ],
    );
  }
}