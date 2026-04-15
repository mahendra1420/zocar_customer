/// customer app all rides - Modern UI

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:share_plus/share_plus.dart';
import 'package:zocar/constant/constant.dart';
import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/controller/all_rides_controller.dart';
import 'package:zocar/helpers/size_ext.dart';
import 'package:zocar/model/ride_model.dart';
import 'package:zocar/page/all_rides/review_added_sheet.dart';
import 'package:zocar/page/all_rides/ride_details_screen.dart';
import 'package:zocar/page/all_rides/route_view_screen.dart';
import 'package:zocar/page/complaint/add_complaint_screen.dart';
import 'package:zocar/page/review_screens/add_review_screen.dart';
import 'package:zocar/themes/constant_colors.dart';
import 'package:zocar/widget/star_rating.dart';

import '../../advance_payment_manager.dart';
import '../../advance_paymentsheet.dart';
import '../../controller/home_controller.dart';
import '../../controller/main_page_controller.dart';
import '../../helpers/devlog.dart';
import '../../helpers/loader.dart';
import '../../helpers/pending_payment_dialog.dart';
import '../../service/active_user_checker.dart';
import '../../utils/global_functions.dart';
import '../home_screens/search_page.dart';
import 'payment_selection_screen.dart';

class AllRidesScreen extends StatelessWidget {
  const AllRidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AllRidesController>(
      init: Get.put(AllRidesController()),
      builder: (controller) {
        return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                HomeController? controller;
                try {
                  controller = Get.find<HomeController>();
                } catch (e) {
                  controller = Get.put<HomeController>(HomeController());
                }
                Map<String, dynamic>? pendingPayment;
                showLoader(context);
                final ok = await ActiveChecker.check();
                if (!ok) {
                  hideLoader();
                  return;
                }
                pendingPayment = await controller.getUserPendingPayment();
                hideLoader();

                if (pendingPayment?['success'] == "success") {
                  if (pendingPayment?['data']?['amount'] != 0) {
                    pendingPaymentDialog(context);
                    return;
                  }
                }

                MainPageController? mainCtr;
                try {
                  mainCtr = Get.find<MainPageController>();
                } catch (e) {
                  mainCtr = Get.put<MainPageController>(MainPageController());
                }

                mainCtr.selectedDrawerIndex.value = 0;
                Get.to(SearchPage(), transition: Transition.fade, duration: Duration.zero);
              },
              label: Text("New Ride"),
              icon: Icon(Icons.add),
            ),
            body: Theme(
              data: ThemeData(
                tabBarTheme: TabBarThemeData(
                  indicatorColor: ConstantColors.primary,
                ),
              ),
              child: Column(children: [
                TabBar(
                  controller: controller.tabController,
                  isScrollable: false,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorColor: ConstantColors.primary,
                  indicatorWeight: 0.1,
                  labelPadding: const EdgeInsets.symmetric(vertical: 8),
                  dividerColor: Colors.transparent,
                  labelColor: ConstantColors.primary,
                  automaticIndicatorColorAdjustment: true,
                  labelStyle: TextStyle(fontFamily: AppThemeData.medium, fontSize: 16, color: ConstantColors.primary),
                  unselectedLabelStyle: TextStyle(fontFamily: AppThemeData.regular, fontSize: 16, color: AppThemeData.grey400),
                  tabs: [
                    Tab(text: 'New'.tr),
                    Tab(text: 'Completed'.tr),
                    Tab(text: 'Rejected'.tr),
                  ],
                ),
                Expanded(
                  child: TabBarView(controller: controller.tabController, children: [
                    SizedBox(
                      child: RefreshIndicator(
                        color: ConstantColors.primary,
                        onRefresh: () => controller.getAllRides(),
                        child: controller.isLoading.value
                            ? _buildModernLoader()
                            : controller.newRideList.isEmpty
                                ? Center(
                                    child: SingleChildScrollView(
                                        physics: AlwaysScrollableScrollPhysics(),
                                        child: Constant.emptyView(context, "You have not booked any trip.\n Please book a cab now", true)),
                                  )
                                : Scrollbar(
                                    child: ListView.builder(
                                        padding: EdgeInsets.only(top: 16, bottom: 8.h, left: 0, right: 0),
                                        itemCount: controller.newRideList.length,
                                        itemBuilder: (context, index) {
                                          return newRideWidgets(controller, context, controller.newRideList[index]);
                                        }),
                                  ),
                      ),
                    ),
                    SizedBox(
                      child: RefreshIndicator(
                        color: ConstantColors.primary,
                        onRefresh: () => controller.getAllRides(),
                        child: controller.isLoading.value
                            ? _buildModernLoader()
                            : controller.completedRideList.isEmpty
                                ? Constant.emptyView(context, "You have not completed any trip.", false)
                                : Scrollbar(
                                    child: ListView.builder(
                                        padding: EdgeInsets.only(top: 16, bottom: 8.h, left: 0, right: 0),
                                        itemCount: controller.completedRideList.length,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          return newRideWidgets(controller, context, controller.completedRideList[index]);
                                        }),
                                  ),
                      ),
                    ),
                    SizedBox(
                      child: RefreshIndicator(
                        color: ConstantColors.primary,
                        onRefresh: () => controller.getAllRides(),
                        child: controller.isLoading.value
                            ? _buildModernLoader()
                            : controller.rejectedRideList.isEmpty
                                ? Constant.emptyView(context, "You have not rejected any trip.", false)
                                : Scrollbar(
                                    child: ListView.builder(
                                        padding: EdgeInsets.only(top: 16, bottom: 8.h, left: 0, right: 0),
                                        itemCount: controller.rejectedRideList.length,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          return newRideWidgets(controller, context, controller.rejectedRideList[index]);
                                        }),
                                  ),
                      ),
                    ),
                  ]),
                )
              ]),
            ));
      },
    );
  }

  Widget _buildModernLoader() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ConstantColors.primary.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ConstantColors.primary),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading rides...'.tr,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget newRideWidgets(AllRidesController controller, BuildContext context, RideData data) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        overlayColor: WidgetStatePropertyAll(Colors.transparent),
        onTap: () async {
          if (data.isCompleted) {
            var isDone = await Get.to(const RideDetailsScreen(), arguments: {
              "rideData": data,
            });
            if (isDone != null) {
              controller.getAllRides();
            }
          } else {
            if (data.statut != "rejected") {
              var argumentData = {'type': data.statut.toString(), 'data': data};
              if (Constant.mapType == "inappmap") {
                Get.to(const RouteViewScreen(), arguments: argumentData);
              } else {
                Constant.redirectMap(
                  latitude: double.parse(data.latitudeArrivee!),
                  longLatitude: double.parse(data.longitudeArrivee!),
                  name: data.destinationName!,
                );
              }
            }
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
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
          child: Stack(
            children: [
              Padding(
                padding:  EdgeInsets.all(4.w),
                child: Column(
                  children: [
                    _buildRouteInfo(data),
                    if (data.rideType.toString() == "rental_ride" || data.type == "custom_rental_ride")
                      _buildRentalInfo(data),
                    Visibility(
                      visible: data.statut == "new" || data.statut == "accepted" || data.statut == "rejected",
                      child: _buildJourneyInfo(data),
                    ),
                    Visibility(
                      visible: data.statut == "confirmed" && Constant.rideOtp.toString().toLowerCase() == 'yes'.toLowerCase() && data.rideType != 'driver' ? true : false,
                      child: _buildOTPInfo(data),
                    ),
                    Visibility(
                      visible: data.advancePayment > 0,
                      child: _buildAdvancePaymentInfo(context,data),
                    ),

                    if (data.rideType.toString() == "normal") _buildRideStats(data),
                    data.driverPhone.toString().isEmpty ? SizedBox(height: 10) : SizedBox.shrink(),
                    if (data.statut == "rejected") SizedBox.shrink() else if (data.driverPhone.toString().isEmpty) _buildWaitingForDriver() else _buildDriverInfo(data),
                    const SizedBox(height: 16),
                    // Visibility(
                    //   visible: data.isCompleted,
                    //   child: Padding(
                    //     padding: const EdgeInsets.only(top: 8.0),
                    //     child: Row(
                    //       children: [
                    //         Expanded(
                    //             child: ButtonThem.buildButton(context,
                    //                 btnHeight: 40,
                    //                 title: data.isPaymentDone ? "Paid".tr : "Pay Now".tr,
                    //                 btnColor: data.isPaymentDone ? Colors.green : ConstantColors.primary,
                    //                 txtColor: Colors.white, onPress: () async {
                    //           if (data.isPaymentDone) {
                    //             controller.getAllRides();
                    //           } else {
                    //             devlog("fasdgfjhagsdf ==> ${data}");
                    //             var isDone = await Get.to(const RideDetailsScreen(), arguments: {
                    //               "rideData": data,
                    //             });
                    //             if (isDone != null) {
                    //               controller.getAllRides();
                    //             }
                    //           }
                    //         })),
                    //         const SizedBox(
                    //           width: 10,
                    //         ),
                    //         Expanded(
                    //             child: ButtonThem.buildBorderButton(
                    //           context,
                    //           title: (data.noteId == null) ? 'add_review'.tr : "Review Added",
                    //           btnWidthRatio: 0.8,
                    //           btnHeight: 40,
                    //           btnColor: Colors.white,
                    //           txtSize: 12,
                    //           txtColor: (data.noteId == null) ? ConstantColors.primary : Colors.grey,
                    //           btnBorderColor: (data.noteId == null) ? ConstantColors.primary : Colors.grey,
                    //           onPress: () async {
                    //             if (data.isReviewAdded) {
                    //               ShowToastDialog.showToast("Review already added.!");
                    //               return;
                    //             }
                    //             if (data.isPaymentDone) {
                    //               await Get.to(const AddReviewScreen(), arguments: {
                    //                 "data": data,
                    //                 "ride_type": "ride",
                    //               });
                    //             } else {
                    //               ShowToastDialog.showToast("Your payment is pending. Please complete the payment to submit your review.");
                    //             }
                    //           },
                    //         )),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 10),
                    // Visibility(
                    //   visible: data.isCompleted,
                    //   child: ButtonThem.buildBorderButton(
                    //     context,
                    //     title: 'add_complaint'.tr,
                    //     btnHeight: 40,
                    //     btnColor: Colors.white,
                    //     txtColor: ConstantColors.primary,
                    //     btnBorderColor: ConstantColors.primary,
                    //     onPress: () async {
                    //       Get.to(AddComplaintScreen(), arguments: {
                    //         "data": data,
                    //         "ride_type": "ride",
                    //       })!
                    //           .then((value) {
                    //         controller.getAllRides();
                    //       });
                    //     },
                    //   ),
                    // ),
                    _buildActionButtons(context, data, controller),
                    Visibility(
                        visible: data.isCompletedButPaymentAndReviewPending,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text("* ${!data.isPaymentDone ? "payment" : !data.isReviewAdded ? "review" : "something"} is pending"),
                          ),
                        )),
                  ],
                ),
              ),
              _buildStatusChip(data.statut!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, RideData data, AllRidesController controller) {
    return Column(
      children: [
        if (data.statut == "completed")
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: buildModernButton(
                      context: context,
                      label: data.paymentStatus == "yes" ? "Paid".tr : "Pay Now".tr,
                      icon: data.paymentStatus == "yes" ? Icons.check_circle : Icons.pending,
                      bgColor: data.paymentStatus == "yes" ? Colors.green : ConstantColors.primary,
                      onPressed: () async {
                        if (data.isPaymentDone) {
                          controller.getAllRides();
                        } else {
                          devlog("fasdgfjhagsdf ==> ${data}");
                          Get.to(PaymentSelectionScreen(), arguments: {
                            "rideData": data,
                          });
                          controller.getAllRides();
                        }
                      },
                    ),
                  ),
                  if (data.idConducteur.toString() != "null") ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: buildModernButton(
                        context: context,
                        label: (!data.isReviewAdded) ? 'add_review'.tr : "Review Added",
                        icon: (!data.isReviewAdded) ? Icons.star_outline : null,
                        bgColor: Colors.white,
                        textColor: (!data.isReviewAdded) ? ConstantColors.primary : Colors.grey.shade700,
                        borderColor: (!data.isReviewAdded) ? ConstantColors.primary : Colors.grey.shade700,
                        onPressed: () async {
                          if (data.isReviewAdded) {
                            ReviewAddedSheet.show(
                              context,
                              givenRating: num.tryParse(data.givenRating.toString()) ?? 0,
                              givenComment: data.givenComment ?? "-",
                              receivedRating: num.tryParse(data.receivedRating.toString()) ?? 0,
                              receivedComment: data.receivedComment ?? "-",
                            );
                            return;
                          }
                          if (data.isPaymentDone) {
                            await Get.to(const AddReviewScreen(), arguments: {
                              "data": data,
                              "ride_type": "ride",
                            });
                          } else {
                            ShowToastDialog.showToast("Your payment is pending. Please complete the payment to submit your review.");
                          }
                        },
                      ),
                    ),
                  ],
                ],
              ),
              if (data.idConducteur.toString() != "null") ...[
                const SizedBox(height: 12),
                buildModernButton(
                  context: context,
                  label: 'Add Complaint'.tr,
                  icon: Icons.report_outlined,
                  bgColor: Colors.white,
                  textColor: Colors.red[700]!,
                  borderColor: Colors.red[200]!,
                  onPressed: () async {
                    Get.to(AddComplaintScreen(), arguments: {
                      "data": data,
                      "ride_type": "ride",
                    })!
                        .then((value) {
                      controller.getAllRides();
                    });
                    Get.to(AddComplaintScreen(), arguments: {"data": data, "ride_type": "ride"});
                  },
                ),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    return Positioned(
      top: 0,
      right: 0,
      child: Transform.translate(
        offset: Offset(10, -10),
        child: Image.asset(
          status == "new"
              ? 'assets/images/new.png'
              : status == "accepted"
                  ? 'assets/images/accepted.png'
                  : status == "confirmed"
                  ? 'assets/images/conformed.png'
                  : status == "on ride"
                      ? 'assets/images/onride.png'
                      : status == "completed"
                          ? 'assets/images/completed.png'
                          : 'assets/images/rejected.png',
          height: 120,
          width: 120,
        ),
      ),
    );
  }

  Widget _buildRouteInfo(RideData data) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 5, 40, 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 12,
            bottom: 25,
            child: Container(
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
          ),
          Column(
            children: [
              _buildLocationRow(
                icon: Icons.location_on,
                iconColor: ConstantColors.yellow,
                text: data.departName.toString(),
              ),
              if (data.stops != null && data.stops!.isNotEmpty && data.type != "custom_rental_ride" || data.rideType != "rental_ride")
                ...data.stops!.asMap().entries.map((entry) {
                  return _buildLocationRow(
                    icon: Icons.location_on_outlined,
                    iconColor: Colors.orange,
                    text: entry.value.location.toString(),
                    label: String.fromCharCode(entry.key + 65),
                  );
                }).toList(),
              if (data.type != "custom_rental_ride"  && data.rideType != "rental_ride")
              _buildLocationRow(
                icon: Icons.trip_origin,
                iconColor: ConstantColors.primary,
                text: data.destinationName.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required String text,
    String? label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacityLike(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label != null)
                  Text(
                    'Stop $label',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRentalInfo(RideData data) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ConstantColors.primary.withOpacity(0.1), ConstantColors.primary.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, size: 20, color: ConstantColors.primary),
          const SizedBox(width: 8),
          if (data.type == "rental_ride" || data.type == "custom_rental_ride")
            Text(
              'Rental: ${data.type == "rental_ride"
                  ? data.packageDetails?.hours
                  : data.duree} Hr, ${data.type == "rental_ride"
                  ? data.packageDetails?.kilometers
                  : data.distance} KM',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ConstantColors.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildJourneyInfo(RideData data) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.event, size: 20, color: data.statut == "rejected" ? Colors.grey.shade600 : Colors.blue[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(data.statut != "rejected")
                Text(
                  'Journey:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Builder(builder: (context) {
                  String dateTimeString = "";
                  try {
                    final DateTime dateTime = DateFormat(
                      'dd MMM, yyyy HH:mm:ss',
                    ).parse("${data.dateRetour} ${data.heureRetour}");

                    String formatted = DateFormat('dd MMM yyyy • hh:mm a').format(dateTime);
                    dateTimeString = formatted;
                  } catch (e) {
                    dateTimeString = "${data.dateRetour} ${data.heureRetour}";
                  }
                  return Text(
                    dateTimeString,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: data.statut == "rejected" ? Colors.grey.shade600 : Colors.blue[700],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOTPInfo(RideData data) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock, size: 20, color: Colors.green[700]),
          const SizedBox(width: 8),
          Text(
            'OTP: ',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Text(
            data.otp.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideStats(RideData data) {
    return Hero(
      tag: 'stats_${data.id}',
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(2.w),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: 'assets/icons/car.png',
                    label: 'Vehicle'.tr,
                    value: data.vehicleTypeName.toString(),
                    color: ConstantColors.yellow,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: _buildStatCard(
                    iconText: Constant.currency.toString(),
                    label: 'Fare'.tr,
                    // value: Constant().amountShow(
                    //   amount: data.isCompleted ? data.totalAmount.toString() : data.montant.toString(),
                    // ),
                    value: Constant().amountShow(
                      amount: data.remainingPayment.toString(),
                    ),
                    color: ConstantColors.yellow,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: 'assets/icons/ic_distance.png',
                    label: 'Distance'.tr,
                    value: data.distance.toString().isNotEmpty
                        ? "${double.parse(data.distance.toString()).toStringAsFixed(int.parse(Constant.decimal!))} ${data.distanceUnit}"
                        : "0.00 Km",
                    color: ConstantColors.yellow,
                  ),
                ),
                const SizedBox(width: 5),
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
      constraints: BoxConstraints(minHeight: 100),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: Column(
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
          const SizedBox(height: 5),
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingForDriver() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.withOpacity(0.1), Colors.orange.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 40,
            width: 40,
            child: lottie.Lottie.asset('assets/lottie/vehicleSearch.json', width: 40, height: 40),
          ),
          SizedBox(width: 12),
          Text(
            "Waiting for Driver...".tr,
            style: TextStyle(
              color: Colors.orange[700],
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfo(RideData data) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.withOpacity(0.05), Colors.grey.withOpacity(0.02)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ConstantColors.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: ConstantColors.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: data.photoPath.toString(),
                height: 60,
                width: 60,
                fit: BoxFit.cover,
                placeholder: (context, url) => Constant.loader(),
                errorWidget: (context, url, error) => const Icon(Icons.person_2_outlined),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${data.prenomConducteur} ${data.nomConducteur}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                StarRating(
                  size: 16,
                  rating: double.parse(data.moyenne.toString()),
                  color: ConstantColors.yellow,
                ),
                const SizedBox(height: 4),
                Text(
                  data.dateRetour.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          if (data.isShowContact)
            Row(
              children: [
                InkWell(
                  onTap: () async {
                    ShowToastDialog.showLoader("Please wait");
                    final Location currentLocation = Location();
                    LocationData location = await currentLocation.getLocation();
                    ShowToastDialog.closeLoader();
                    await Share.share(
                      'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}',
                      subject: 'ZoCar',
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: ConstantColors.blueColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: ConstantColors.blueColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
                SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    Constant.makePhoneCall(data.driverPhone.toString());
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.call, color: Colors.white, size: 20),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAdvancePaymentInfo(BuildContext context,RideData data) {
    if (data.advancePayment == null || data.advancePayment == 0) {
      return const SizedBox();
    }
    final bool isPaid = data.advancePaymentStatus == 1;

    return InkWell(
      onTap: () {
        final advancePayment = int.tryParse(
          data.advancePayment.toString() ?? "0",
        ) ??
            0;
        debugPrint("Advance Payment: $advancePayment");
         AdvancePaymentManager.save(
          rideId:data.id ?? '',
          driverId:  '',
          amount: advancePayment,
          timeoutSeconds: 120,
             timerEnabled: (data.rideType == "rental_ride" || data.rideType == "custom_rental_ride")
                 ? false
                 : true
        );
        AdvancePaymentSheet.showIfNeeded(context);
      },
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isPaid
              ? Colors.green.withOpacity(0.05)
              : Colors.orange.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPaid
                ? Colors.green.withOpacity(0.3)
                : Colors.orange.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isPaid ? Icons.check_circle : Icons.pending,
              color: isPaid ? Colors.green : Colors.orange,
              size: 20,
            ),
            const SizedBox(width: 8),

            /// TEXT PART
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Advance Payment",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${Constant.currency}${data.advancePayment} • ${isPaid ? "Paid" : "Pending"}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isPaid ? Colors.green[700] : Colors.orange[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


}