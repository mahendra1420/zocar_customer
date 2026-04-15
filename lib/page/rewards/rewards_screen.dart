// ignore_for_file: prefer_const_constructors

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zocar/constant/constant.dart';
import 'package:zocar/controller/coupon_code_controller.dart';
import 'package:zocar/model/coupan_code_model.dart';
import 'package:zocar/themes/constant_colors.dart';

import '../all_rides/coupon_info_sheet.dart';


class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  @override
  Widget build(BuildContext context) {
    return GetX<CouponCodeController>(
        init: CouponCodeController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: ConstantColors.background,
            body: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(tabs: [
                    Tab(text: "Available"),
                    Tab(text: "Used/Expired"),
                  ]),
                  Expanded(
                    child: TabBarView(
                      children: [
                        buildTab(controller, context, "0"),
                        buildTab(controller, context, "1"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget buildTab(CouponCodeController controller, BuildContext context, String flag) {
    final usedList = controller.rewardCoupanCodeList.where((p0) => (p0.isUsed ?? false)).toList();
    final unusedList = controller.rewardCoupanCodeList.where((p0) => !(p0.isUsed ?? false)).toList();
    final usedExpired = flag == "1";
    final list = usedExpired ? usedList : unusedList;
    final MaterialColor? color = usedExpired ? Colors.grey : null;
    return RefreshIndicator(
      onRefresh: () => controller.getRewardCoupanCodeData(),
      child: controller.isLoading.value
          ? Constant.loader()
          : list.isEmpty
              ? Center(
                  child: Constant.emptyView(context, "No rewards available".tr, false),
                )
              : ListView.builder(
                  itemCount: list.length,
                  // shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return _buildCouponCard(context, list[index], color, usedExpired);
                  }),
    );
  }

  Widget _buildCouponCard(BuildContext context, CoupanCodeData promo, MaterialColor? color, bool usedExpired) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, color?.shade50 ?? Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (color ?? Colors.blue).withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative corner element
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [(color ?? Colors.blue).withOpacity(0.1), Colors.transparent],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(40),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Row(
              children: [
                // Left Icon Section
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [(color ?? Colors.blue).shade400, (color ?? Colors.blue).shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (color ?? Colors.blue).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.local_offer, color: Colors.white.withOpacity(0.3), size: 45),
                      Icon(Icons.local_offer, color: Colors.white, size: 35),
                    ],
                  ),
                ),

                SizedBox(width: 5),

                // Content Section
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              promo.discription.toString(),
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [(color ?? Colors.green).shade400, (color ?? Colors.green).shade600],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              promo.type == "Percentage" ? "${promo.discount}% OFF" : "${Constant().amountShow(amount: promo.discount.toString())} OFF",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 5),

                      // Coupon Code
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: InkWell(
                              onTap: () {
                                if (!usedExpired) {
                                  FlutterClipboard.copy(promo.code.toString());
                                }
                                // ScaffoldMessenger.of(context).showSnackBar(
                                //   SnackBar(
                                //     content: Row(
                                //       children: [
                                //         Icon(Icons.check_circle, color: Colors.white, size: 20),
                                //         SizedBox(width: 8),
                                //         Text("Code copied!".tr),
                                //       ],
                                //     ),
                                //     backgroundColor: Colors.green,
                                //     duration: Duration(seconds: 2),
                                //     behavior: SnackBarBehavior.floating,
                                //     shape: RoundedRectangleBorder(
                                //       borderRadius: BorderRadius.circular(10),
                                //     ),
                                //   ),
                                // );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: (color ?? Colors.blue).withOpacity(0.5),
                                    width: 1.5,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      promo.code.toString(),
                                      style: TextStyle(
                                        color: (color ?? Colors.blue)[700],
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    if(!usedExpired)
                                    Icon(
                                      Icons.content_copy,
                                      size: 14,
                                      color: (color ?? Colors.blue)[700],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 6),

                          // Info Button
                          if (!usedExpired)
                            InkWell(
                              onTap: () => showCouponInfoBottomSheet(context, promo),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.info_outline,
                                  color: Colors.blue[700],
                                  size: 22,
                                ),
                              ),
                            ),
                        ],
                      ),

                      SizedBox(height: 4),

                      // Additional Info
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Expanded(
                            child: Builder(builder: (context) {
                              String dateTimeString = "";
                              try {
                                final DateTime dateTime = DateFormat(
                                  'dd MMMM yyyy hh:mm a',
                                ).parse("${promo.expireAt}");

                                String formatted = DateFormat('dd MMM yyyy • hh:mm a').format(dateTime);
                                dateTimeString = formatted;
                              } catch (e) {
                                dateTimeString = "${promo.expireAt}";
                              }
                              return Text(
                                "${"Valid till".tr} ${dateTimeString}",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            }),
                          ),
                        ],
                      ),

                      if (promo.minimum_amount != null && int.tryParse(promo.minimum_amount.toString()) != null && int.tryParse(promo.minimum_amount.toString())! > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(
                            children: [
                              Icon(Icons.shopping_cart_outlined, size: 12, color: Colors.grey[600]),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  "${"Min:".tr} ${Constant().amountShow(amount: promo.minimum_amount.toString())}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
