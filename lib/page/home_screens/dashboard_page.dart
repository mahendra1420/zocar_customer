import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart' as get_cord_address;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:zocar/constant/constant.dart';
import 'package:zocar/controller/home_controller.dart';
import 'package:zocar/helpers/devlog.dart';
import 'package:zocar/helpers/loader.dart';
import 'package:zocar/helpers/url_launcher_helper.dart';
import 'package:zocar/page/home_screens/search_page.dart';
import 'package:zocar/themes/constant_colors.dart';

import '../../helpers/location_service.dart';
import '../../helpers/pending_payment_dialog.dart';
import '../../service/active_user_checker.dart';
import '../my_rental_booking/my_rental_booking_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late HomeController controller;

  GoogleMapController? _controller;
  final Location currentLocation = Location();
  final LocationService locationService = LocationService();

  bool isShowing = true;

  final CarouselSliderController carouselController = CarouselSliderController();

  // var myAddress = <Data>[].obs;

  ValueNotifier<bool> locationLoading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    controller = Get.find<HomeController>();
    controller.selectedOptionIndex = 0;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      controller.confirmWidgetVisible.value = false;
      try {
        controller.addListener(_updateLocationDataListener);
        getCurrentLocation(false);
        controller.multiStopList.clear();
        controller.multiStopListNew.clear();
        controller.destinationController.clear();
        controller.razorpay.clear();
        controller.destinationLatLong = const LatLng(0.0, 0.0).obs;
      } catch (e) {
        devlog("neon -> home screen new widget binding error first part : $e");
      }

      // try {
      //   await getAddress();
      // } catch (e) {
      //   devlog("neon -> home screen new widget binding error second part : $e");
      // }
      devlog("neon -> home screen new widget binding end of laoding");
      setState(() {});
    });
  }

  void _updateLocationDataListener() {
    if (controller.locationDataSetFromMainCtr != null) {
      setState(() {});
      controller.locationDataSetFromMainCtr = null;
    }
  }

  @override
  void dispose() {
    controller.removeListener(_updateLocationDataListener);
    super.dispose();
  }

  Future<void> getCurrentLocation(bool showDialogOnDeniedForever) async {
    if (locationLoading.value) return;
    try {
      final res = await locationService.handlePermission(context, showDialogOnDeniedForever);
      if (!res) {
      locationLoading.value = false;
        return;
      }
      locationLoading.value = true;
      Position location = await Geolocator.getCurrentPosition();
      locationLoading.value = false;
      controller.locationData = location;
      List<get_cord_address.Placemark> placeMarks = await get_cord_address.placemarkFromCoordinates(location.latitude, location.longitude);
      final address = ((placeMarks.first.subLocality?.isEmpty ?? true) ? '' : "${placeMarks.first.subLocality}, ") +
          ((placeMarks.first.street?.isEmpty ?? true) ? '' : "${placeMarks.first.street}, ") +
          ((placeMarks.first.name?.isEmpty ?? true) ? '' : "${placeMarks.first.name}, ") +
          ((placeMarks.first.subAdministrativeArea?.isEmpty ?? true) ? '' : "${placeMarks.first.subAdministrativeArea}, ") +
          ((placeMarks.first.administrativeArea?.isEmpty ?? true) ? '' : "${placeMarks.first.administrativeArea}, ") +
          ((placeMarks.first.country?.isEmpty ?? true) ? '' : "${placeMarks.first.country}, ") +
          ((placeMarks.first.postalCode?.isEmpty ?? true) ? '' : "${placeMarks.first.postalCode}, ");
      controller.departureController.text = address;
      setDepartureMarker(LatLng(location.latitude, location.longitude));
    } catch (e) {
    }
  }

  // Future<void> getAddress() async {
  //   try {
  //     final response = await LoggingClient(http.Client()).post(Uri.parse(API.addressDetails), headers: API.headerSecond);
  //
  //     Map<String, dynamic> responseBody = json.safeDecode(response.body);
  //     if (response.statusCode == 200 && responseBody['success'] == "success") {
  //       MyAddressData model = MyAddressData.fromJson(responseBody);
  //       myAddress.value = model.data!;
  //       devlog("getAddress Response ==> ${myAddress.toString()}");
  //     } else if (response.statusCode == 200 && responseBody['success'] == "Failed") {
  //       ShowToastDialog.showToast(responseBody['error']?.toString() ?? 'Something went wrong. Please try again later');
  //     } else {
  //       ShowToastDialog.showToast(responseBody['error']?.toString() ?? 'Something went wrong. Please try again later');
  //       throw Exception(responseBody['error']?.toString() ?? 'Something went wrong. Please try again later');
  //     }
  //   } on TimeoutException catch (e) {
  //     ShowToastDialog.showToast(e.message.toString());
  //     devlog("neon -> error in get address : $e");
  //   } on SocketException catch (e) {
  //     ShowToastDialog.showToast(e.message.toString());
  //     devlog("neon -> error in get address : $e");
  //   } on Error catch (e) {
  //     ShowToastDialog.showToast(e.toString());
  //     devlog("neon -> error in get address : $e");
  //   } catch (e) {
  //     devlog("neon -> error in get address : $e");
  //     ShowToastDialog.showToast(e.toString());
  //   }
  //   return null;
  // }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.imageListHeader.isNotEmpty) {
        if (isShowing) {
          isShowing = false;
          _showImageCarouselDialog(context);
        }
      }
    });
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: ConstantColors.primary, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        // backgroundColor: ConstantColors.background,
        appBar: AppBar(
          elevation: 0,
          flexibleSpace: Container(
            decoration:
                BoxDecoration(image: DecorationImage(image: AssetImage(kImgWhiteBg), fit: BoxFit.cover, colorFilter: ColorFilter.mode(ConstantColors.primary, BlendMode.modulate))),
          ),
          centerTitle: true,
          // backgroundColor: ConstantColors.primary,
          title: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Hero(tag: "kImgZocar", child: Image.asset(kImgZocar, width: 100)),
            ),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(top: 3, left: 8),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: Colors.transparent,
                  padding: const EdgeInsets.all(10),
                  elevation: 0,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.asset(
                    "assets/icons/ic_side_menu.png",
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          actions: [
            ValueListenableBuilder(
                valueListenable: locationLoading,
                builder: (context, v, _) {
                  return Container(
                    margin: EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    child: IconButton(
                      onPressed: () async {
                        await getCurrentLocation(true);
                        setState(() {});
                      },
                      icon: v
                          ? CupertinoActivityIndicator(color: Colors.white)
                          : Icon(
                              Icons.my_location_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                    ),
                  );
                }),
          ],
        ),
        body: Stack(
          children: [
            GoogleMap(
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              padding: EdgeInsets.only(top: 50, bottom: 295),
              compassEnabled: false,
              initialCameraPosition: CameraPosition(target: controller.center, zoom: 14.0),
              minMaxZoomPreference: const MinMaxZoomPreference(8.0, 20.0),
              buildingsEnabled: false,
              onMapCreated: (GoogleMapController c) async {
                _controller = c;
                _controller!.moveCamera(CameraUpdate.newLatLngZoom(LatLng(controller.locationData?.latitude ?? 0.0, controller.locationData?.longitude ?? 0.0), 14));
              },
              myLocationEnabled: true,
              markers: controller.markers.values.toSet(),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
                  child: InkWell(
                    onTap: () async {
                      await controller.placeSelectAPI(context).then((value) {
                        if (value != null) {
                          controller.departureController.text = value.result.formattedAddress.toString();
                          final latlng= LatLng(value.result.geometry!.location.lat, value.result.geometry!.location.lng);
                          controller.locationData = Position.fromMap({
                            "latitude" : latlng.latitude,
                            "longitude": latlng.longitude,
                          });
                          setDepartureMarker(latlng);
                          setState(() {});
                        }
                      });
                    },
                    child: buildTextField(
                      title: "Departure".tr,
                      textController: controller.departureController,
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: bottomOptionsWithSearchBar(),
            ),
            if (controller.imageListFooter.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Dialog(
                  insetPadding: EdgeInsets.zero,
                  child: Container(
                    height: 63,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: CarouselSlider.builder(
                      carouselController: carouselController,
                      itemCount: controller.imageListFooter.length,
                      options: CarouselOptions(
                        autoPlay: true,
                        aspectRatio: 2.0,
                        enlargeCenterPage: true,
                        onPageChanged: (index, reason) {},
                      ),
                      itemBuilder: (context, index, realIdx) {
                        return GestureDetector(
                          onTap: () {
                            String imageUrl = controller.imageListFooter[index].url!;
                            launchURL(controller.imageListFooter[index].url!);
                            devlog("Clicked image URL: $imageUrl");
                          },
                          child: Container(
                            height: 55,
                            width: MediaQuery.of(context).devicePixelRatio * 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: controller.imageListFooter[index].image!,
                                progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
                                errorWidget: (context, url, error) => const Icon(Icons.image),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void launchURL(String url) async {
    UrlLauncher.launchNetworkUrl(url);
  }

  void _showImageCarouselDialog(BuildContext context) {
    int current = 0;
    final homeController = Get.put(HomeController());
    final CarouselSliderController controller = CarouselSliderController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey.shade50],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.campaign_rounded, color: Colors.blue, size: 20),
                              SizedBox(width: 8),
                              Text(
                                "Advertisement",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade100,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.close_rounded, size: 20),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        height: 200,
                        width: double.maxFinite,
                        child: Stack(
                          children: [
                            CarouselSlider.builder(
                              carouselController: controller,
                              itemCount: homeController.imageListHeader.length,
                              options: CarouselOptions(
                                autoPlay: true,
                                aspectRatio: 2.0,
                                enlargeCenterPage: true,
                                viewportFraction: 0.9,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    current = index;
                                  });
                                },
                              ),
                              itemBuilder: (context, index, realIdx) {
                                return GestureDetector(
                                  onTap: () {
                                    String imageUrl = homeController.imageListHeader[index].url!;
                                    launchURL(homeController.imageListHeader[index].url!);
                                    devlog("Clicked image URL: $imageUrl");
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 15,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: CachedNetworkImage(
                                        imageUrl: homeController.imageListHeader[index].image!,
                                        progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                                          child: CircularProgressIndicator(value: downloadProgress.progress),
                                        ),
                                        errorWidget: (context, url, error) => Icon(Icons.image),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 12.0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: homeController.imageListHeader.asMap().entries.map((entry) {
                                  return GestureDetector(
                                    onTap: () => controller.animateToPage(entry.key),
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      width: current == entry.key ? 24.0 : 8.0,
                                      height: 8.0,
                                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: current == entry.key ? Colors.blue : Colors.white.withOpacity(0.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  setDepartureMarker(LatLng departure) {
    controller.markers.remove("Departure");
    controller.markers['Departure'] = Marker(
      markerId: const MarkerId('Departure'),
      infoWindow: const InfoWindow(title: "Departure"),
      position: departure,
      icon: controller.departureIcon!,
    );
    controller.departureLatLong.value = departure;
    _controller!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(departure.latitude, departure.longitude), zoom: 14)));
  }

  setDestinationMarker(LatLng destination) {
    controller.markers['Destination'] = Marker(
      markerId: const MarkerId('Destination'),
      infoWindow: const InfoWindow(title: "Destination"),
      position: destination,
      icon: controller.destinationIcon!,
    );
    controller.destinationLatLong.value = destination;
  }

  Widget buildTextField({required title, required TextEditingController textController}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ConstantColors.yellow, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: textController,
        textInputAction: TextInputAction.done,
        style: TextStyle(
          color: ConstantColors.titleTextColor,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: title,
          prefixIcon: Container(
            padding: EdgeInsets.all(12.0),
            child: Image.asset(
              "assets/images/departure_icon.png",
              height: 24,
              width: 24,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.blue.shade300,
              width: 2.0,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        enabled: false,
      ),
    );
  }

  bottomOptionsWithSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            spreadRadius: 0,
            offset: Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          StatefulBuilder(builder: (context, setState) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _onButtonTap(0);
                      setState(() {});
                    },
                    child: _buildOptionButton('One Way', "assets/icons/daily.png", controller.selectedOptionIndex == 0),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onButtonTapRentals(context),
                    child: _buildOptionButton('Rentals', "assets/icons/rentals.png", controller.selectedOptionIndex == 2),
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () async {
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
                      Get.to(SearchPage(), transition: Transition.fade, duration: Duration.zero);
                    },
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade100, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.08),
                            blurRadius: 12,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.asset(
                              "assets/images/search_destination.png",
                              color: Colors.blue,
                              height: 25,
                              width: 25,
                            ),
                          ),
                          SizedBox(width: 14),
                          Text(
                            'Search Destination...',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String label, String icon, bool isSelected) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      height: 110,
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: isSelected ? 15 : 8,
            offset: Offset(0, isSelected ? 6 : 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.asset(
              icon,
              height: 36,
              width: 36,
            ),
          ),
          SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.grey.shade800,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              fontSize: 15,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  void _onButtonTap(int index) {
    controller.selectedOptionIndex = index;
  }
}

void _onButtonTapRentals(BuildContext context) async {
  await Get.to(() => MyRentalBookingScreen(), transition: Transition.downToUp);
  // showBottomSheet(context: context, builder: (context) => MyRentalBookingScreen());
}
