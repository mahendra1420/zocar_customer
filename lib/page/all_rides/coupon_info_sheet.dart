import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constant/constant.dart';
import '../../model/coupan_code_model.dart';

void showCouponInfoBottomSheet(BuildContext context, CoupanCodeData promo) {
  showModalBottomSheet(
    context: context,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    scrollControlDisabledMaxHeightRatio: 0.9,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_offer,
                    color: Colors.blue,
                    size: 28,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Coupon Details".tr,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoSection(
                      icon: Icons.title,
                      label: "Title".tr,
                      value: promo.discription?.toString() ?? "N/A",
                      isHighlighted: true,
                    ),
                    SizedBox(height: 16),
                    _buildInfoSection(
                      icon: Icons.description,
                      label: "Description".tr,
                      value: promo.title?.toString() ?? "N/A",
                    ),
                    SizedBox(height: 16),
                    _buildCouponCodeSection(context, promo),
                    SizedBox(height: 16),
                    _buildInfoSection(
                      icon: Icons.calendar_today,
                      label: "Valid Till".tr,
                      value: promo.expireAt?.toString() ?? "N/A",
                    ),
                    SizedBox(height: 16),
                    _buildInfoSection(
                      icon: Icons.discount,
                      label: "Discount".tr,
                      value: promo.type == "Percentage" ? "${promo.discount}%" : Constant().amountShow(amount: promo.discount.toString()),
                      valueColor: Colors.green,
                    ),
                    if (promo.minimum_amount != null && int.tryParse(promo.minimum_amount.toString()) != null && int.tryParse(promo.minimum_amount.toString())! > 0) ...[
                      SizedBox(height: 16),
                      _buildInfoSection(
                        icon: Icons.shopping_cart,
                        label: "Minimum Spend".tr,
                        value: Constant().amountShow(amount: promo.minimum_amount.toString()),
                      ),
                    ],
                    if (promo.remainingCount != null && promo.remainingCount != 0) ...[
                      SizedBox(height: 16),
                      _buildInfoSection(
                        icon: Icons.repeat,
                        label: "Remaining Usages".tr,
                        value: promo.remainingCount.toString(),
                        valueColor: (int.tryParse(promo.remainingCount ?? "0") ?? 0) > 5 ? Colors.green : Colors.orange,
                      ),
                    ],
                    SizedBox(height: 24),
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

Widget _buildInfoSection({
  required IconData icon,
  required String label,
  required String value,
  bool isHighlighted = false,
  Color? valueColor,
}) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isHighlighted ? Colors.blue.withOpacity(0.05) : Colors.grey[50],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isHighlighted ? Colors.blue.withOpacity(0.3) : Colors.grey[200]!,
        width: 1,
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: isHighlighted ? Colors.blue : Colors.grey[600],
          size: 20,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: valueColor ?? Colors.black87,
                  fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildCouponCodeSection(BuildContext context, CoupanCodeData promo) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue.shade50, Colors.blue.shade100],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
    ),
    child: Row(
      children: [
        Icon(Icons.confirmation_number, color: Colors.blue, size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Coupon Code".tr,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                promo.code?.toString() ?? "N/A",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue[900],
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            FlutterClipboard.copy(promo.code.toString());
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     content: Text("Coupon code copied!".tr),
            //     backgroundColor: Colors.green,
            //     duration: Duration(seconds: 2),
            //     behavior: SnackBarBehavior.floating,
            //   ),
            // );
          },
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.copy, color: Colors.white, size: 20),
          ),
        ),
      ],
    ),
  );
}
