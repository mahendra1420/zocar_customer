import 'package:zocar/constant/constant.dart';
import 'package:zocar/utils/preferences.dart';

class BookingPriceBreakdown {
  final double baseFare;
  final double discount;
  final double commission;
  final String commissionType;
  final double taxAmount;
  final double finalPrice;

  const BookingPriceBreakdown({
    required this.baseFare,
    required this.discount,
    required this.commission,
    required this.commissionType,
    required this.taxAmount,
    required this.finalPrice,
  });

  Map<String, dynamic> toPayload() {
    return {
      'base_fare': baseFare.toStringAsFixed(2),
      'admission_commision': commission.toStringAsFixed(2),
      'admin_commission': commission.toStringAsFixed(2),
      'commision_type': commissionType,
      'discount': discount.toStringAsFixed(2),
      'tax_amount': taxAmount.toStringAsFixed(2),
      'final_price': finalPrice.toStringAsFixed(2),
    };
  }
}

String _taxType(String? type) {
  final value = (type ?? '').trim().toLowerCase();
  if (value == 'amount' || value == 'fixed') return 'amount';
  return 'percentage';
}

double _calculateTax(double amount) {
  double totalTax = 0.0;
  for (final tax in Constant.taxList) {
    if ((tax.statut ?? '').trim().toLowerCase() != 'yes') continue;
    final taxValue = double.tryParse(tax.value ?? '') ?? 0.0;
    if (taxValue <= 0) continue;

    if (_taxType(tax.type) == 'amount') {
      totalTax += taxValue;
    } else {
      totalTax += (amount * taxValue) / 100;
    }
  }
  return totalTax;
}

BookingPriceBreakdown buildBookingPriceBreakdown({
  required double baseFare,
  required double discount,
}) {
  final safeBaseFare = baseFare < 0 ? 0.0 : baseFare;
  final safeDiscount = discount < 0 ? 0.0 : discount;
  final subtotal = (safeBaseFare - safeDiscount).clamp(0.0, double.infinity);

  final commissionValue = double.tryParse(Preferences.getString(Preferences.admincommission)) ?? 0.0;
  final commissionType = Preferences.getString(Preferences.adminCommissionType).trim().isEmpty
      ? 'Fixed'
      : Preferences.getString(Preferences.adminCommissionType).trim();

  final isPercentage = commissionType.toLowerCase() == 'percentage';
  final commission = isPercentage ? (subtotal * commissionValue) / 100 : commissionValue;

  final taxableAmount = subtotal + commission;
  final taxAmount = _calculateTax(taxableAmount);
  final finalPrice = taxableAmount + taxAmount;

  return BookingPriceBreakdown(
    baseFare: safeBaseFare,
    discount: safeDiscount,
    commission: commission,
    commissionType: commissionType,
    taxAmount: taxAmount,
    finalPrice: finalPrice,
  );
}
