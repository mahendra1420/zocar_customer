import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as get_cord_address;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:zocar/constant/logdata.dart';
import 'package:zocar/controller/main_page_controller.dart';
import 'package:zocar/helpers/devlog.dart';
import 'package:zocar/helpers/booking_price_helper.dart';
import 'package:zocar/helpers/location_service.dart';
import 'package:zocar/helpers/payment_gateway.dart';
import 'package:zocar/helpers/widget_binding.dart';
import 'package:zocar/page/home_screens/date_time_picker_widget.dart';
import 'package:zocar/page/my_rental_booking/package_details_sheet.dart';
import 'package:zocar/themes/constant_colors.dart';

import '../../constant/constant.dart';
import '../../constant/show_toast_dialog.dart';
import '../../controller/coupon_controller.dart';
import '../../controller/home_controller.dart';
import '../../controller/my_rental_booking_controller.dart';
import '../../helpers/loader.dart';
import '../../service/active_user_checker.dart';
import '../../service/api.dart';
import '../../themes/custom_dialog_box.dart';
import '../../utils/preferences.dart';
import '../all_rides/coupon_info_sheet.dart';
import '../main_page.dart';
import 'custom_rental_booking/custom_rental_booking_screen.dart';

String _rentalTaxType(String? type) {
  final t = (type ?? '').trim().toLowerCase();
  if (t == 'amount' || t == 'fixed') return 'amount';
  return 'percentage';
}

double _rentalTaxAmount(double baseAmount) {
  double taxTotal = 0.0;
  for (final tax in Constant.taxList) {
    if ((tax.statut ?? '').trim().toLowerCase() != 'yes') continue;
    final value = double.tryParse(tax.value ?? '') ?? 0.0;
    if (value <= 0) continue;
    final type = _rentalTaxType(tax.type);
    taxTotal += type == 'amount' ? value : (baseAmount * value) / 100;
  }
  return taxTotal;
}

double _rentalPriceWithTax(double baseAmount) {
  return baseAmount + _rentalTaxAmount(baseAmount);
}

class MyRentalBookingScreen extends StatefulWidget {
  const MyRentalBookingScreen({super.key});

  @override
  State<MyRentalBookingScreen> createState() => _MyRentalBookingScreenState();
}

class _MyRentalBookingScreenState extends State<MyRentalBookingScreen> {
  final controller = Get.put(HomeController());
  final myRentalBookingController = Get.put(MyRentalBookingController());
  final couponCtr = Get.isRegistered<CouponController>() ? Get.find<CouponController>() : Get.put(CouponController());
  GoogleMapController? _controller;
  final Location currentLocation = Location();
  final LocationService locationService = LocationService();
  final RxInt selectedIndex = 0.obs;
  final RxInt selectedVehicleIndex = 0.obs;
  double percentAmount = 0;
  String selectedVehicleId = '';
  String selectedOptionId = "0";
  bool loading = false;
  DateTime dateTime = DateTime.now();
  ValueNotifier<bool> locationLoading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    // Automatically open the bottom sheet when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ShowToastDialog.showLoader("Getting data..");

      await getCurrentLocation(false);
      final ok = await ActiveChecker.check();
      if (!ok) {
        await ShowToastDialog.closeLoader();
        return;
      }

      await myRentalBookingController.getPackagesData();
      var ride = myRentalBookingController.rideList.firstOrNull;
      if (ride != null) {
        await myRentalBookingController.getVehiclesByPackage(ride.id.toString());
        myRentalBookingController.rentalPackageId = ride.id.toString();
      }
      await ShowToastDialog.closeLoader();
      setState(() {});
    });
  }

  getCurrentLocation(bool isFetchForceNewLocation) async {
    if (locationLoading.value) return;
    try {
      controller.searchVisible.value = true;
      devlog("MyHomeScreen ==> Yes I am here in getCurrentLocation");

      devlog("MyHomeScreen ==> Yes I am here in isDepartureSet iF");
      Position? p = isFetchForceNewLocation ? null : controller.locationData;
      locationLoading.value = true;
      try {
        if (p == null) {
          final res = await locationService.handlePermission(context, true);
          if (!res) {
            devlog("location service returns false");
            p = controller.locationData;
            if (p != null) {
              myRentalBookingController.latitude = p.latitude.toString();
              myRentalBookingController.longitude = p.longitude.toString();
              setDepartureMarker(LatLng(p.latitude, p.longitude));
            }
            locationLoading.value = false;
            return;
          } else {
            devlog("location service returns true");
          }
          p = await Geolocator.getCurrentPosition();

          List<get_cord_address.Placemark> placeMarks = await get_cord_address.placemarkFromCoordinates(p.latitude, p.longitude);
          myRentalBookingController.latitude = p.latitude.toString();
          myRentalBookingController.longitude = p.longitude.toString();
          final address = (placeMarks.first.subLocality!.isEmpty ? '' : "${placeMarks.first.subLocality}, ") +
              (placeMarks.first.street!.isEmpty ? '' : "${placeMarks.first.street}, ") +
              (placeMarks.first.name!.isEmpty ? '' : "${placeMarks.first.name}, ") +
              (placeMarks.first.subAdministrativeArea!.isEmpty ? '' : "${placeMarks.first.subAdministrativeArea}, ") +
              (placeMarks.first.administrativeArea!.isEmpty ? '' : "${placeMarks.first.administrativeArea}, ") +
              (placeMarks.first.country!.isEmpty ? '' : "${placeMarks.first.country}, ") +
              (placeMarks.first.postalCode!.isEmpty ? '' : "${placeMarks.first.postalCode}, ");
          controller.departureController.text = address;
        }
        devlog("p is not null . set location");
        myRentalBookingController.latitude = p.latitude.toString();
        myRentalBookingController.longitude = p.longitude.toString();
        setDepartureMarker(LatLng(p.latitude, p.longitude));
      } catch (e) {
        devlogError("ereorieroi oej slkflsd :$e");
      }
      locationLoading.value = false;
      // });
    } catch (e) {
      showLog("neon -> error in get current location in my rental booking screen");
    }
  }

  setDepartureMarker(LatLng departure) {
    controller.markers.remove("Departure");
    controller.markers['Departure'] = Marker(
      markerId: const MarkerId('Departure'),
      infoWindow: const InfoWindow(title: "Departure"),
      position: departure,
      icon: controller.departureIcon!,
    );
    _controller!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(departure.latitude, departure.longitude), zoom: 14)));
  }

  // openBottomSheet(BuildContext c) {
  //   bool cpop = false;
  //   showModalBottomSheet(
  //     context: c,
  //     isScrollControlled: true,
  //     useSafeArea: true,
  //     isDismissible: false,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) => PopScope(
  //       canPop: cpop,
  //       onPopInvokedWithResult: (didPop, result) {
  //         devlog("result : $result");
  //         cpop = true;
  //         Navigator.pop(context);
  //         Navigator.pop(c);
  //       },
  //       child: sheetContent(),
  //     ),
  //   );
  // }

  Widget sheetContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 5),
        GestureDetector(
          onTap: () {
            Get.to(() => CustomRentalBookingScreen(
              latitude: myRentalBookingController.latitude,
              longitude: myRentalBookingController.longitude,
              departureName: controller.departureController.text,
            ));
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade500]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.tune, color: Colors.white),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Custom Booking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('Set your own km, date & time', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
              ],
            ),
          ),
        ),
        SizedBox(height: 5),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 10, top: 10),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.green),
                  SizedBox(width: 5),
                  Expanded(
                      child: InkWell(
                    onTap: () async {
                      await controller.placeSelectAPI(context).then((value) {
                        if (value != null) {
                          controller.departureController.text = value.result.formattedAddress.toString();
                          final latlng = LatLng(value.result.geometry!.location.lat, value.result.geometry!.location.lng);
                          controller.locationData = Position.fromMap({
                            "latitude": latlng.latitude,
                            "longitude": latlng.longitude,
                          });
                          myRentalBookingController.latitude = latlng.latitude.toString();
                          myRentalBookingController.longitude = latlng.longitude.toString();
                          setDepartureMarker(latlng);
                          myRentalBookingController.getVehiclesByPackage((myRentalBookingController.rentalPackageId));
                          setState(() {});
                        }
                      });
                    },
                    child: Text(
                      controller.departureController.text.toString(),
                    ),
                  )),
                  ValueListenableBuilder(
                      valueListenable: locationLoading,
                      builder: (context, v, _) {
                        return InkWell(
                          overlayColor: WidgetStatePropertyAll(Colors.transparent),
                          onTap: () async {
                            await getCurrentLocation(true);
                          },
                          child: v
                              ? CupertinoActivityIndicator(color: ConstantColors.primary)
                              : Image.asset(
                                  "assets/images/departure_icon.png",
                                  color: Colors.blue,
                                  height: 23,
                                  width: 23,
                                ),
                        );
                      }),
                  SizedBox(width: 5)
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 10, top: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Extra charges on exceeding package.', style: TextStyle(fontSize: 10)),
                          InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  useSafeArea: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  builder: (context) => const PackageDetailsBottomSheet(),
                                );
                              },
                              child: Text('View detail.', style: TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Expanded(
          child: GetBuilder<MyRentalBookingController>(builder: (_) {
            return SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(builder: (c) {
                    return SizedBox(
                        height: 80,
                        child: RepaintBoundary(
                          child: myRentalBookingController.isLoading.value
                              ? Constant.loader()
                              : myRentalBookingController.rideList.isEmpty
                                  ? Center(child: Text("No Data Found!"))
                                  : StatefulBuilder(builder: (context, update) {
                                      return Obx(() {
                                        return ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: myRentalBookingController.rideList.length,
                                          itemBuilder: (context, index) {
                                            var ride = myRentalBookingController.rideList[index];
                                            var isSelected = selectedOptionId == index.toString();

                                            return GestureDetector(
                                              onTap: () {
                                                widgetBinding((_) async {
                                                  await myRentalBookingController.getVehiclesByPackage(ride.id.toString());
                                                  myRentalBookingController.rentalPackageId = ride.id.toString();
                                                  setState(() {});
                                                });

                                                selectedIndex.value = index;
                                                selectedOptionId = index.toString();

                                                myRentalBookingController.selectedVehicle.value = "";
                                                myRentalBookingController.vehicleId = "";
                                                selectedVehicleId = "";
                                                update(() {});
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Material(
                                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                                  elevation: 5,
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                                    decoration: BoxDecoration(
                                                      color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                                                      borderRadius: BorderRadius.circular(10),
                                                      border: Border.all(
                                                        color: isSelected ? Colors.blue : Colors.transparent,
                                                        width: 2.0,
                                                      ),
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          "${ride.hours.toString()} Hr",
                                                          style: TextStyle(fontWeight: FontWeight.bold),
                                                        ),
                                                        Text("${ride.kilometers.toString()} KM"),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      });
                                    }),
                        ));
                  }),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: TripDateTimeSelector(onTripDetailsChanged: (dailyDateTime, isRoundTrip, startDateTime, endDateTime) {
                      this.dateTime = dailyDateTime;
                    }),
                  ),
                  SizedBox(height: 4),
                  Builder(builder: (c) {
                    return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: myRentalBookingController.isLoadingVehicle.value
                            ? Constant.loader()
                            : myRentalBookingController.vehiclesData.isEmpty
                                ? Center(child: Text("No Data Found!"))
                                : myRentalBookingController.vehiclesData.isEmpty
                                    ? Container(
                                        height: 160,
                                        child: Center(
                                            child: Text(
                                          "No vehicle Found for this Package...",
                                          style: TextStyle(fontSize: 12, color: ConstantColors.primary, fontWeight: FontWeight.bold),
                                        )),
                                      )
                                    : StatefulBuilder(builder: (context, update) {
                                        return Obx(() {
                                          return ListView.builder(
                                            scrollDirection: Axis.vertical,
                                            shrinkWrap: true,
                                            physics: NeverScrollableScrollPhysics(),
                                            itemCount: myRentalBookingController.vehiclesData.length,
                                            itemBuilder: (context, index) {
                                              var ride = myRentalBookingController.vehiclesData[index];

                                              return GestureDetector(
                                                onTap: () {
                                                  myRentalBookingController.selectedVehicle.value = ride.id.toString();
                                                  myRentalBookingController.vehicleId = ride.id.toString();
                                                  selectedVehicleId = ride.id.toString();
                                                  final selectedPrice = double.tryParse(ride.price?.toString() ?? "0") ?? 0.0;
                                                  couponCtr.finalizeForPayment(_rentalPriceWithTax(selectedPrice));
                                                  update(() {});
                                                },
                                                child: Card(
                                                  elevation: 5.0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    side: BorderSide(
                                                      color: selectedVehicleId == ride.id.toString() ? Colors.blue : Colors.transparent,
                                                      // Blue border if selected
                                                      width: 2.0,
                                                    ),
                                                  ),
                                                  child: ListTile(
                                                    leading: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius: BorderRadius.circular(5),
                                                          child: CachedNetworkImage(
                                                            imageUrl: ride.image.toString(),
                                                            height: 40,
                                                            width: 60,
                                                            fit: BoxFit.cover,
                                                            placeholder: (context, url) => Constant.loader(),
                                                            errorWidget: (context, url, error) => const Icon(Icons.car_repair_outlined),
                                                          ),
                                                        ),
                                                        Text(ride.distance.toString()),
                                                      ],
                                                    ),
                                                    title: Text(ride.libelle.toString(),
                                                        style: TextStyle(color: selectedVehicleId == ride.id.toString() ? Colors.blue : Colors.black)),
                                                    subtitle: Text(ride.description.toString()),
                                                    trailing: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Builder(builder: (_) {
                                                          final rawPrice = double.tryParse(ride.price?.toString() ?? "0") ?? 0.0;
                                                          final eval = couponCtr.evaluateForVehicle(rawPrice);
                                                          final pricing = buildBookingPriceBreakdown(
                                                            baseFare: rawPrice,
                                                            discount: eval.isApplicable ? eval.discountAmount.toDouble() : 0.0,
                                                          );

                                                          return Column(
                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                            children: [
                                                              if (eval.isApplicable)
                                                                Text(
                                                                  '₹${rawPrice.toStringAsFixed(0)}',
                                                                  style: const TextStyle(
                                                                    fontSize: 11,
                                                                    color: Colors.grey,
                                                                    decoration: TextDecoration.lineThrough,
                                                                  ),
                                                                ),
                                                              Text(
                                                                '₹${pricing.finalPrice.toStringAsFixed(0)}',
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: selectedVehicleId == ride.id.toString() ? Colors.blue : Colors.black,
                                                                ),
                                                              ),
                                                              InkWell(
                                                                onTap: () => _showRentalFareBreakdown(
                                                                  vehicleName: ride.libelle.toString(),
                                                                  imageUrl: ride.image.toString(),
                                                                  basePrice: rawPrice,
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
                                                            ],
                                                          );
                                                        }),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        });
                                      }));
                  }),
                  // Builder(builder: (c) {
                  //   final ride = myRentalBookingController.vehiclesData.where((p0) => p0.id?.toString() == myRentalBookingController.selectedVehicle.value).firstOrNull;
                  //   if (ride == null) return SizedBox();
                  //
                  //   percentAmount = controller.calculate30PercentageAmount(basePrice: ride.price?.toDouble() ?? 0);
                  //   if (percentAmount == 0) return SizedBox();
                  //
                  //   return AnimatedSize(
                  //     alignment: Alignment.topCenter,
                  //     duration: Duration(microseconds: 200),
                  //     child: Column(
                  //       children: [
                  //         Divider(),
                  //         Center(child: Text("Pay Advance ${Preferences.getInitialPaymentPercentage()} % is ${percentAmount}")),
                  //         Divider(),
                  //       ],
                  //     ),
                  //   );
                  // }),
                  const SizedBox(height: 8),
                  _buildCouponSection(),
                  SizedBox(height: 15),
                  StatefulBuilder(builder: (context, update) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          backgroundColor: ConstantColors.primary,
                        ),
                        onPressed: () async {
                          loading = true;
                          update(() {});
                          showLoader(context);
                          final ok = await ActiveChecker.check();
                          hideLoader();
                          if (!ok) return;
                          loading = false;
                          update(() {});
                          if (controller.departureController.text.toString().isEmpty) {
                            ShowToastDialog.showToast("Please get you current location for pickup.");
                          } else if (myRentalBookingController.rentalPackageId.toString().isEmpty) {
                            ShowToastDialog.showToast("Please select Vehicle Type.");
                          } else if (myRentalBookingController.selectedVehicle.isEmpty) {
                            ShowToastDialog.showToast("Please select Vehicle Type.");
                          } else {
                            await bookRental(dateTime);
                          }
                        },
                        child: loading
                            ? CupertinoActivityIndicator(color: Colors.white)
                            : Text(
                                'Book Now',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    );
                  }),
                  SizedBox(height: 20),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Future<dynamic> bookRental(DateTime dateTime) async {
    if (percentAmount == 0) {
      await onSuccessBookRental('', dateTime);
    } else {
      PaymentGateway.instance.openRazorPay(
        amount: percentAmount,
        onSuccess: (response) async {
          ShowToastDialog.showToast("Payment Success");
          final paymentId = response.paymentId;
          await onSuccessBookRental(paymentId, dateTime);
        },
        onFailure: () {
          Get.back();
        },
      );
    }
    return;
  }

  void _showRentalFareBreakdown({
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
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            height: 40,
                            width: 60,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Constant.loader(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.car_repair_outlined),
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
                    _buildPaymentRow(
                      label: '🎁 Surprise Fare',
                      value: Constant()
                          .amountShow(amount: basePrice.toStringAsFixed(2)),
                      isSubdued: true,
                    ),
                    if (hasCoupon)
                      _buildPaymentRow(
                        label: 'Coupon (${couponCtr.selectedPromoCode.value})',
                        value: "- ${Constant().amountShow(amount: eval.discountAmount.toString())}",
                        valueColor: Colors.green.shade700,
                        isSubdued: true,
                      ),
                    if (pricing.commission > 0)
                      _buildPaymentRow(
                        label: 'Admin Commission (${pricing.commissionType})',
                        value: Constant().amountShow(
                            amount: pricing.commission.toStringAsFixed(2)),
                        isSubdued: true,
                      ),
                    if (pricing.taxAmount > 0)
                      _buildPaymentRow(
                        label: 'GST / Tax',
                        value: Constant()
                            .amountShow(amount: pricing.taxAmount.toStringAsFixed(2)),
                        isSubdued: true,
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
                      child: _buildPaymentRow(
                        label: '💰 Surprise Amount',
                        value: Constant()
                            .amountShow(amount: pricing.finalPrice.toStringAsFixed(2)),
                        isBold: true,
                        valueColor: ConstantColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  onSuccessBookRental(String? paymentId, DateTime dateTime) async {
    try {
      final selectedRide = myRentalBookingController.vehiclesData
          .where((e) => e.id?.toString() == myRentalBookingController.vehicleId.toString())
          .firstOrNull;
      final selectedPrice = double.tryParse(selectedRide?.price?.toString() ?? "0") ?? 0.0;
      couponCtr.finalizeForPayment(_rentalPriceWithTax(selectedPrice));
      final pricing = buildBookingPriceBreakdown(
        baseFare: selectedPrice,
        discount: couponCtr.discountAmount.value.toDouble(),
      );

      Map<String, String?> bodyParams = {};
      bodyParams = {
        'user_id': Preferences.getInt(Preferences.userId).toString(),
        'rental_package_id': myRentalBookingController.rentalPackageId.toString(),
        'latitude': myRentalBookingController.latitude.toString(),
        'longitude': myRentalBookingController.longitude.toString(),
        'id_payment': paymentId,
        'depart_name': controller.departureController.text.toString(),
        'vehicle_id': myRentalBookingController.vehicleId.toString(),
        'date_retour': DateFormat("yyyy-MM-dd").format(dateTime),
        'heure_retour': DateFormat("HH:mm:ss").format(dateTime),
        'tax': "",
        'discount': couponCtr.discountAmount.value.toString(),
        'coupon_id': couponCtr.selectedPromoId.value,
        'assign_id': couponCtr.selectedAssignId.value,
        'base_fare': pricing.baseFare.toStringAsFixed(2),
        'admission_commision': pricing.commission.toStringAsFixed(2),
        'admin_commission': pricing.commission.toStringAsFixed(2),
        'commision_type': pricing.commissionType,
        'tax_amount': pricing.taxAmount.toStringAsFixed(2),
        'final_price': pricing.finalPrice.toStringAsFixed(2),
      };
      final response = await LoggingClient(http.Client()).post(Uri.parse(API.requestRegisterRentalBooking), body: jsonEncode(bodyParams), headers: API.header);

      Map<String, dynamic> responseBody = json.safeDecode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == true) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return CustomDialogBox(
                title: "",
                descriptions: "Your Rental booking has been sent successfully",
                onPress: () {
                  Get.back();
                  Get.back();
                  Get.back();
                  final MainPageController controller = Get.find<MainPageController>();
                  controller.selectedDrawerIndex.value = drawerItems.indexWhere((element) => element.isAllRides);
                },
                img: Image.asset('assets/images/green_checked.png'),
              );
            });
      } else if (response.statusCode == 200 && responseBody['success'] == "Failed") {
        ShowToastDialog.showToast('Something went wrong. Please try again later');
      } else {
        ShowToastDialog.showToast('Something went wrong. Please try again later');
        throw Exception('Something went wrong.!');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 1,
              child: Stack(
                children: [
                  GoogleMap(
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: true,
                    padding: const EdgeInsets.only(
                      top: 8.0,
                    ),
                    compassEnabled: false,
                    initialCameraPosition: CameraPosition(
                      tilt: 90,
                      target: controller.center,
                      zoom: 14.0,
                    ),
                    minMaxZoomPreference: const MinMaxZoomPreference(8.0, 20.0),
                    buildingsEnabled: false,
                    onMapCreated: (GoogleMapController ctr) async {
                      _controller = ctr;
                      final x = controller.locationData;
                      if (x != null) {
                        _controller!.moveCamera(CameraUpdate.newLatLngZoom(LatLng(x.latitude, x.longitude), 14));
                      } else {
                        final res = await locationService.handlePermission(context, false);
                        if (res) {
                          LocationData location = await currentLocation.getLocation();
                          _controller!.moveCamera(CameraUpdate.newLatLngZoom(LatLng(location.latitude ?? 0.0, location.longitude ?? 0.0), 14));
                        }
                      }
                    },
                    myLocationEnabled: true,
                    markers: controller.markers.values.toSet(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: InkWell(
                        borderRadius: BorderRadius.circular(40),
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.8)),
                          child: Icon(Icons.arrow_back_ios_new),
                        )),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: InkWell(
                        borderRadius: BorderRadius.circular(40),
                        onTap: () {
                          final m = controller.markers['Departure']?.position;
                          if (m != null) _controller?.moveCamera(CameraUpdate.newLatLng(m));
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.8)),
                          child: Icon(Icons.filter_center_focus),
                        )),
                  )
                ],
              ),
            ),
            Expanded(flex: 2, child: sheetContent())
          ],
        ),
      ),
    );
  }

  Widget _buildCouponSection() {
    return Obx(() {
      final isApplied = couponCtr.selectedPromoCode.value.isNotEmpty;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          elevation: 2,
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
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.close, size: 18, color: Colors.green.shade700),
                      ),
                    )
                  else
                    Icon(Icons.chevron_right, color: Colors.grey.shade500),
                ],
              ),
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
      builder: (_) => _RentalCouponSelectionSheet(couponCtr: couponCtr),
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
      padding: const EdgeInsets.symmetric(vertical: 2),
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

class _RentalCouponSelectionSheet extends StatelessWidget {
  const _RentalCouponSelectionSheet({required this.couponCtr});
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
                        TextButton(
                          onPressed: () => showCouponInfoBottomSheet(context, promo),
                          child: const Text('Info'),
                        ),
                        const SizedBox(width: 4),
                        ElevatedButton(
                          onPressed: () {
                            if (isApplied) {
                              couponCtr.clearCoupon();
                              ShowToastDialog.showToast('Coupon removed');
                              return;
                            }
                            final ok = couponCtr.applyCouponByIndex(index);
                            if (ok) Navigator.pop(context);
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
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for package options
Widget packageItem(String time, String distance) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 5),
    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(time, style: TextStyle(fontWeight: FontWeight.bold)),
        Text(distance),
      ],
    ),
  );
}

// Widget for car options
// Widget carOption(String type, String description, String price, String eta, bool isSelected) {
//   return GestureDetector(
//     onTap: (() {}), // Handle tap for selecting this option
//     child: Card(
//       elevation: 5.0, // Elevation based on selection
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//         side: BorderSide(
//           color: isSelected ? Colors.blue : Colors.transparent,
//           // Blue border if selected
//           width: 2.0,
//         ),
//       ),
//       child: ListTile(
//         leading: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.directions_car, color: isSelected ? Colors.blue : Colors.black),
//             Text(eta),
//           ],
//         ),
//         title: Text(type, style: TextStyle(color: isSelected ? Colors.blue : Colors.black)),
//         subtitle: Text(description),
//         trailing: Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(price, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.blue : Colors.black)),
//           ],
//         ),
//       ),
//     ),
//   );
// }
//
// // Widget for payment options
// Widget paymentOption(IconData icon, String label) {
//   return Row(
//     children: [
//       Icon(icon, size: 20),
//       SizedBox(width: 10),
//       Text(label),
//     ],
//   );
// }
