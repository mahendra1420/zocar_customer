import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zocar/constant/constant.dart';
import 'package:zocar/controller/payment_controller.dart';
import 'package:zocar/helpers/size_ext.dart';
import 'package:zocar/model/tax_model.dart';
import 'package:zocar/page/all_rides/payment_selection_screen.dart';
import 'package:zocar/page/all_rides/review_added_sheet.dart';
import 'package:zocar/page/chats_screen/conversation_screen.dart';
import 'package:zocar/page/review_screens/add_review_screen.dart';
import 'package:zocar/themes/button_them.dart';
import 'package:zocar/themes/constant_colors.dart';
import 'package:zocar/widget/star_rating.dart';

import '../../constant/show_toast_dialog.dart';

class RideDetailsScreen extends StatelessWidget {
  const RideDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<PaymentController>(
      init: PaymentController(),
      builder: (controller) {
        final data = controller.data.value;
        return Scaffold(
          backgroundColor: ConstantColors.background,
          appBar: AppBar(
              backgroundColor: ConstantColors.background,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              toolbarHeight: kToolbarHeight + 10,
              title: Column(
                children: [Image.asset(kImgZocar, width: 30.w), Text("Ride Details".tr, style: TextStyle(fontSize: 12, height: 1, color: Colors.grey.shade800))],
              ),
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.black,
                        ),
                      )),
                ),
              )),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Route Card - Enhanced
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Positioned(
                              top: 20,
                              left: 15,
                              bottom: 30,
                              child: Row(
                                children: [
                                  Container(
                                    width: 2,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          ConstantColors.yellow.withOpacity(0.3),
                                          Colors.grey.withOpacity(0.3),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(children: [
                              // Pickup Location
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: ConstantColors.yellow.withOpacityLike(0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Image.asset(
                                            "assets/icons/location.png",
                                            height: 20,
                                            color: ConstantColors.yellow,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Pickup Location".tr,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            data.departName.toString(),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              height: 1.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Stops
                              if (data.stops != null && data.stops!.isNotEmpty)
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: data.stops!.length,
                                  itemBuilder: (context, int index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                color: Colors.grey[300]!,
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                String.fromCharCode(index + 65),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Stop ${String.fromCharCode(index + 65)}",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  data.stops![index].location.toString(),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.3,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),

                              // Vertical Line before destination
                              // if (data.stops != null && data.stops!.isNotEmpty)
                              //   Padding(
                              //     padding: const EdgeInsets.only(left: 18, bottom: 8),
                              //     child: Row(
                              //       children: [
                              //         Container(
                              //           width: 2,
                              //           height: 20,
                              //           decoration: BoxDecoration(
                              //             gradient: LinearGradient(
                              //               begin: Alignment.topCenter,
                              //               end: Alignment.bottomCenter,
                              //               colors: [
                              //                 Colors.grey.withOpacityLike(0.3),
                              //                 ConstantColors.primary.withOpacityLike(0.3),
                              //               ],
                              //             ),
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ),

                              // Destination
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: ConstantColors.primary.withOpacityLike(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Image.asset(
                                      "assets/icons/round.png",
                                      height: 18,
                                      color: ConstantColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Destination".tr,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          data.destinationName.toString(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ]),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Divider(color: Colors.grey.shade100),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: ConstantColors.primary.withOpacityLike(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Image.asset(
                                "assets/icons/time.png",
                                height: 18,
                                color: ConstantColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Date & Time".tr,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    data.dateRetour.toString() + " " + data.heureRetour.toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(color: Colors.grey.shade100),
                        // Trip Stats - Enhanced Grid
                        Hero(
                          tag: 'stats_${data.id}',
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,        // ✅ add this
                                mainAxisAlignment: MainAxisAlignment.center, 
                              children: [
                                Flexible(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatCard(
                                          icon: 'assets/icons/car.png',
                                          label: 'Vehicle'.tr,
                                          value: data.vehicleTypeName.toString(),
                                          color: ConstantColors.yellow,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      // Expanded(
                                      //   child: _buildStatCard(
                                      //     icon: null,
                                      //     iconText: Constant.currency.toString(),
                                      //     label: 'Fare'.tr,
                                      //     value: Constant().amountShow(
                                      //       amount: (data.statut == "completed")
                                      //           ? (num.parse(data.advancePayment.toString()) + num.parse(controller.getTotalAmount().toString())).toString()
                                      //           : data.montant,
                                      //     ),
                                      //     color: ConstantColors.yellow,
                                      //   ),
                                      // ),
                                      Expanded(
                                        child: _buildStatCard(
                                          icon: null,
                                          iconText: Constant.currency.toString(),
                                          label: 'Fare'.tr,
                                          value: Constant().amountShow(amount: data.remainingPayment.toString()),
                                          color: ConstantColors.yellow,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                        icon: 'assets/icons/ic_distance.png',
                                        label: 'Distance'.tr,
                                        value: "${double.parse(data.distance.toString()).toStringAsFixed(int.parse(Constant.decimal!))} ${data.distanceUnit}",
                                        color: ConstantColors.yellow,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _buildStatCard(
                                        icon: 'assets/icons/time.png',
                                        label: 'Duration'.tr,
                                        value: data.duree.toString(),
                                        color: ConstantColors.yellow,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // Driver Info - Enhanced
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.grey[50]!,
                                Colors.white,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: CachedNetworkImage(
                                    imageUrl: data.photoPath.toString(),
                                    height: 70,
                                    width: 70,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Constant.loader(),
                                    errorWidget: (context, url, error) => Container(
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.person, size: 35),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Your Driver".tr,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${data.prenomConducteur.toString()} ${data.nomConducteur.toString()}",
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    StarRating(
                                      size: 16,
                                      rating: data.moyenne != "null" ? double.parse(data.moyenne.toString()) : 0.0,
                                      color: ConstantColors.yellow,
                                    ),
                                  ],
                                ),
                              ),
                              if (data.isShowContact)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildActionButton(
                                          icon: 'assets/icons/chat_icon.png',
                                          onTap: () {
                                            Get.to(ConversationScreen(), arguments: {
                                              'receiverId': int.parse(data.idConducteur.toString()),
                                              'orderId': int.parse(data.id.toString()),
                                              'receiverName': "${data.prenomConducteur} ${data.nomConducteur}",
                                              'receiverPhoto': data.photoPath
                                            });
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        _buildActionButton(
                                          icon: 'assets/icons/call_icon.png',
                                          onTap: () {
                                            Constant.makePhoneCall(data.driverPhone.toString());
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      data.dateRetour.toString(),
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Payment Breakdown - Enhanced
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Payment Breakdown".tr,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildPaymentRow(
                          label: "Sub Total".tr,
                          value: Constant().amountShow(amount: data.farePrice),
                          isSubdued: true,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: Colors.grey[200], height: 1),
                        ),

                        if (data.advancePayment.toString() != "0")
                          _buildPaymentRow(
                            label: "Advance Amount".tr,
                            value: Constant().amountShow(amount: data.advancePayment.toString()),
                            isSubdued: true,
                          ),
                        if (data.extraKmCharge.toString() != "0.00")
                          _buildPaymentRow(
                            label: "Extra Distance Charge".tr,
                            value: Constant().amountShow(amount: data.extraKmCharge.toString()),
                            isSubdued: true,
                          ),
                        if (data.extraMinCharge.toString() != "0.00")
                          _buildPaymentRow(
                            label: "Extra Time Charge".tr,
                            value: Constant().amountShow(amount: data.extraMinCharge.toString()),
                            isSubdued: true,
                          ),
                        if (data.tollParkingCharge.toString() != "0.00")
                          _buildPaymentRow(
                            label: "Toll & Parking".tr,
                            value: Constant().amountShow(amount: data.tollParkingCharge.toString()),
                            isSubdued: true,
                          ),
                        if (data.tollParkingCharge.toString() != "0.00")
                          _buildPaymentRow(
                            label: "Admin Commission".tr,
                            value: Constant().amountShow(amount: data.adminCommission.toString()),
                            isSubdued: true,
                          ),
                        if (data.tollParkingCharge.toString() != "0.00")
                          _buildPaymentRow(
                            label: "Tax Amount".tr,
                            value: Constant().amountShow(amount: data.taxAmount.toString()),
                            isSubdued: true,
                          ),


                        _buildPaymentRow(
                          label: "Discount".tr,
                          value: "(-${Constant().amountShow(amount: controller.discountAmount.value.toString())})",
                          valueColor: Colors.green[600]!,
                          isSubdued: true,
                        ),
                        // if (((data.paymentStatus == "yes" ? data.taxModel : Constant.taxList) as List).isNotEmpty)
                        //   Padding(
                        //     padding: const EdgeInsets.symmetric(vertical: 12),
                        //     child: Divider(color: Colors.grey[200], height: 1),
                        //   ),

                        // Taxes
                        // ListView.builder(
                        //   itemCount: data.paymentStatus == "yes" ? data.taxModel?.length ?? 0 : Constant.taxList.length,
                        //   shrinkWrap: true,
                        //   padding: EdgeInsets.zero,
                        //   physics: const NeverScrollableScrollPhysics(),
                        //   itemBuilder: (context, index) {
                        //     TaxModel taxModel = data.paymentStatus == "yes" ? data.taxModel![index] : Constant.taxList[index];
                        //     final calculatedTax = controller.calculateTax(taxModel: taxModel);
                        //     return Column(
                        //       children: [
                        //         _buildPaymentRow(
                        //           label: '${taxModel.libelle.toString()} (${taxModel.type == "Fixed" ? Constant().amountShow(amount: taxModel.value) : "${taxModel.value}%"})',
                        //           value: Constant().amountShow(amount: calculatedTax.toString()),
                        //           isSubdued: true,
                        //         ),
                        //         if (index < (data.paymentStatus == "yes" ? (data.taxModel?.length ?? 0) - 1 : Constant.taxList.length - 1))
                        //           Padding(
                        //             padding: const EdgeInsets.symmetric(vertical: 12),
                        //             child: Divider(color: Colors.grey[200], height: 1),
                        //           ),
                        //       ],
                        //     );
                        //   },
                        // ),

                        if (controller.tipAmount.value != 0) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: Colors.grey[200], height: 1),
                          ),
                          _buildPaymentRow(
                            label: "Driver Tip".tr,
                            value: Constant().amountShow(amount: controller.tipAmount.value.toString()),
                            isSubdued: true,
                          ),
                        ],

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Divider(color: Colors.grey[300], thickness: 2, height: 1),
                        ),

                        // Total
                        // _buildPaymentRow(
                        //   label: "Total Amount".tr,
                        //   // value: Constant().amountShow(
                        //   //   // amount: (controller.getTotalAmount() + ((data.statut == "completed") ? data.advancePayment : 0)).toString(),
                        //   //   amount: (controller.getTotalAmount() + data.advancePayment).toString(),
                        //   // ),
                        //   value: Constant().amountShow(amount: data.montant),
                        //   isBold: true,
                        //   valueColor: ConstantColors.primary,
                        // ),

                        _buildPaymentRow(
                          label: "Total Amount".tr,
                          // value: Constant().amountShow(
                          //   // amount: (controller.getTotalAmount() + ((data.statut == "completed") ? data.advancePayment : 0)).toString(),
                          //   amount: (controller.getTotalAmount() + data.advancePayment).toString(),
                          // ),
                          value: Constant().amountShow(amount: data.remainingPayment.toString()),
                          isBold: true,
                          valueColor: ConstantColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: ButtonThem.buildButton(
                        context,
                        btnHeight: 45,
                        title: data.paymentStatus == "yes" ? "Paid".tr : "Pay Now".tr,
                        btnColor: data.paymentStatus == "yes" ? Colors.green : ConstantColors.primary,
                        txtColor: Colors.white,
                        onPress: () {
                          if (data.paymentStatus == "yes") {
                            // Already paid
                          } else {
                            Get.to(PaymentSelectionScreen(), arguments: {
                              "rideData": data,
                            });
                          }
                        },
                      ),
                    ),
                    if (data.paymentStatus == "yes")
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: ButtonThem.buildBorderButton(
                            context,
                            title: (!data.isReviewAdded) ? 'Add Review'.tr : "Review Added",
                            btnWidthRatio: 0.8,
                            btnHeight: 45,
                            txtSize: 14,
                            btnColor: Colors.white,
                            txtColor: (!data.isReviewAdded)  ? ConstantColors.primary : Colors.grey,
                            btnBorderColor: (!data.isReviewAdded)  ? ConstantColors.primary : Colors.grey,
                            onPress: () async {
                              if (data.isReviewAdded)  {
                                ReviewAddedSheet.show(
                                  context,
                                  givenRating: num.tryParse(data.givenRating.toString()) ?? 0,
                                  givenComment: data.givenComment ?? "-",
                                  receivedRating: num.tryParse(data.receivedRating.toString()) ?? 0,
                                  receivedComment: data.receivedComment ?? "-",
                                );
                                return;
                              }
                              Get.to(const AddReviewScreen(), arguments: {
                                "data": data,
                                "ride_type": "ride",
                              });
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    String? icon,
    String? iconText,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Image.asset(icon, height: 22, width: 22, color: color)
          else if (iconText != null)
            Text(
              iconText,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Image.asset(
          icon,
          height: 20,
          width: 20,
        ),
      ),
    );
  }

  Widget _buildPaymentRow({
    required String label,
    required String value,
    bool isSubdued = false,
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                letterSpacing: 0,
                color: isSubdued ? Colors.grey[600] : Colors.black87,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                fontSize: isBold ? 16 : 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              letterSpacing: 0,
              color: valueColor ?? (isSubdued ? Colors.black87 : Colors.black),
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
              fontSize: isBold ? 18 : 15,
            ),
          ),
        ],
      ),
    );
  }
}
