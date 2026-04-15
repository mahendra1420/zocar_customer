import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../helpers/devlog.dart';
import '../../../service/api.dart';

/// Call this whenever a driver rejects a custom rental booking.
/// It triggers Razorpay refund via your backend API.
class CustomRentalRefundService {
  static Future<bool> initiateRefund({
    required String bookingId,
    required String paymentId, // Razorpay payment_id stored at booking time
    required double refundAmount,
  }) async {
    try {
      devlog('CustomRentalRefundService: initiating refund for bookingId=$bookingId');
      final body = jsonEncode({
        'booking_id': bookingId,
        'payment_id': paymentId,
        'amount': refundAmount, // in rupees — backend converts to paise
        'reason': 'Driver rejected custom rental booking',
      });
      final response = await LoggingClient(http.Client()).post(Uri.parse(API.initiateCustomRentalRefund), body: body, headers: API.header);

      final responseBody = json.safeDecode(response.body);
      devlog('CustomRentalRefundService: response = $responseBody');

      if (response.statusCode == 200 && responseBody['success'] == 'success') {
        devlog('CustomRentalRefundService: refund initiated successfully');
        return true;
      } else {
        devlogError('CustomRentalRefundService: refund failed = $responseBody');
        return false;
      }
    } catch (e) {
      devlogError('CustomRentalRefundService: exception = $e');
      return false;
    }
  }
}
