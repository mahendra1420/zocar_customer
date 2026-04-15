// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:zocar/constant/constant.dart';
import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/helpers/booking_price_helper.dart';
import 'package:zocar/helpers/devlog.dart';
import 'package:zocar/model/driver_location_update.dart';
import 'package:zocar/model/driver_model.dart';
import 'package:zocar/model/payment_method_model.dart';
import 'package:zocar/model/user_model.dart';
import 'package:zocar/model/vehicle_category_model.dart';
import 'package:zocar/service/api.dart';
import 'package:zocar/utils/preferences.dart';

import '../model/Image_model.dart';
import '../model/payment_setting_model.dart';
import '../page/global_functions.dart';
import '../page/main_page.dart';
import '../themes/custom_dialog_box.dart';
import 'main_page_controller.dart';

class HomeController extends GetxController {
  //for Choose your Rider

  // final passengerController = TextEditingController(text: "1");
  final TextEditingController departureController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  Rx<LatLng> destinationLatLong = const LatLng(0.0, 0.0).obs;
  Rx<LatLng> departureLatLong = const LatLng(0.0, 0.0).obs;
  bool onceShownOnMainPage = false;

  // BuildContext context = Get.context!;
  RxString selectPaymentMode = "Payment Method".obs;

  // List<AddChildModel> addChildList = [AddChildModel(editingController: TextEditingController())];
  List<AddStopModel> multiStopList = [];
  List<AddStopModel> multiStopListNew = [];
  RxBool searchVisible = true.obs;
  RxInt razorPayAmount = 0.obs;
  int selectedOptionIndex = 0;
  RxString selectedVehicle = "".obs;
  RxString selectedVehicleItem = "".obs;
  VehicleData? vehicleData;
  late PaymentMethodData? paymentMethodData;

  RxBool confirmWidgetVisible = false.obs;
  RxBool saveAddress = false.obs;

  // RxString tripOptionCategory = "General".obs;
  RxString paymentMethodType = "Select Method".obs;
  RxString paymentMethodId = "".obs;
  RxDouble distance = 0.0.obs, totalAmount = 0.0.obs;
  RxString duration = "".obs;
  RxDouble durationFloat = 0.0.obs;

  RxDouble distanceSavedForRoundTrip = 0.0.obs;
  RxDouble durationFloatSavedForRoundTrip = 0.0.obs;

  var paymentSettingModel = PaymentSettingModel().obs;

  LatLng get center => LatLng(locationData?.latitude ?? 22.23224, locationData?.longitude ?? 70.4656);

  RxBool cash = false.obs;
  RxBool wallet = false.obs;
  RxBool stripe = false.obs;
  RxBool razorPay = false.obs;
  RxBool payTm = false.obs;
  RxBool paypal = false.obs;
  RxBool payStack = false.obs;
  RxBool flutterWave = false.obs;
  RxBool mercadoPago = false.obs;
  RxBool payFast = false.obs;
  Razorpay razorpay = Razorpay();
  List<ImageModelData> imageList = [];
  List<ImageModelData> imageListHeader = [];
  List<ImageModelData> imageListFooter = [];

  Position? locationData;

  bool? locationDataSetFromMainCtr;

  @override
  void onInit() {
    super.onInit();

    confirmWidgetVisible.listen((value) {
      devlog("confirmWidgetVisible changed to: $value");
    });

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      paymentSettingModel.value = Constant.getPaymentSetting();
      multiStopList.clear();
      razorpay.clear();
      multiStopListNew.clear();
      destinationController.clear();
      // controller.addChildList.clear();
      destinationLatLong = const LatLng(0.0, 0.0).obs;
      multiStopList.clear();
      multiStopListNew.clear();
      setIcons();
      // getBanner();
      getTaxiData();
      update();
    });
  }

  // void selectVehicle(VehicleData? vehicledata) {
  //   if (vehicledata == null) return;
  //   vehicleData = vehicledata;
  //   selectedVehicle.value = vehicledata.id.toString();
  //
  //   if (distance.value <= (double.parse(vehicleData!.minimumDeliveryCharges!))) {
  //     advancePayAmount.value = double.parse(vehicleData!.minimumDeliveryChargesWithin!);
  //   } else {
  //     double newDistance = distance.value - (double.parse(vehicleData!.minimumDeliveryCharges!));
  //
  //     if (newDistance <= double.parse(vehicleData!.outstation_radius!)) {
  //       advancePayAmount.value = (newDistance * double.parse(vehicleData!.deliveryCharges!)) + double.parse(vehicleData!.minimumDeliveryChargesWithin!);
  //     } else {
  //       double outstationCost = newDistance * double.parse(vehicleData!.outstation_delivery_charge_per_km!);
  //       advancePayAmount.value = double.parse(vehicleData!.minimumDeliveryChargesWithin!) + outstationCost;
  //     }
  //   }
  // }

  void selectVehicle(VehicleData? vehicledata) {
    if (vehicledata == null) {
      vehicleData = null;
      selectedVehicle.value = "";
      totalAmount.value = 0;
      return;
    }

    vehicleData = vehicledata;
    selectedVehicle.value = vehicledata.id.toString();

    final double totalDistance = distance.value;
    final double minimumKm = double.tryParse(vehicleData?.minimumDeliveryCharges ?? "") ?? 0.0;
    final double minimumAmount = double.tryParse(vehicleData?.minimumDeliveryChargesWithin ?? "") ?? 0.0;
    final double perKmCharge = double.tryParse(vehicleData?.deliveryCharges ?? "") ?? 0.0;
    final double outstationRadius = double.tryParse(vehicleData?.outstation_radius ?? "") ?? 0.0;
    final double outstationPerKm = double.tryParse(vehicleData?.outstation_delivery_charge_per_km ?? "") ?? 0.0;

    double total = 0.0;

    if (totalDistance <= minimumKm) {
      total = minimumAmount;
    } else {
      double newDistance = totalDistance - minimumKm;
      double chargeableDistance = newDistance.round().toDouble();

      if (newDistance <= outstationRadius) {
        total = (chargeableDistance * perKmCharge) + minimumAmount;
      } else {
        double outstationCost = chargeableDistance * outstationPerKm;
        total = minimumAmount + outstationCost;
      }
    }

    totalAmount.value = total;
  }

  double calculateTripPrice({
    required double distance,
    required double minimumDeliveryChargesWithin,
    required double minimumDeliveryCharges,
    required double deliveryCharges,
    required double outstation_radius,
    required double outstation_delivery_charge_per_km,
  }) {
    double cout = 0.0;

    if (distance <= minimumDeliveryCharges) {
      cout = minimumDeliveryChargesWithin;
    } else {
      double newDistance = distance - minimumDeliveryCharges;

      if (newDistance <= outstation_radius) {
        cout = (newDistance.round() * deliveryCharges) + minimumDeliveryChargesWithin;
      } else {
        double outstationCost = newDistance.round() * outstation_delivery_charge_per_km;
        cout = minimumDeliveryChargesWithin + outstationCost;
      }
    }
    return cout;
  }

  // Future<dynamic> getBanner() async {
  //   try {
  //     final response = await LoggingClient(http.Client()).get(Uri.parse(API.getBannerAdvertisement), headers: API.header);
  //     log("Parcel Details: 123 ${response.body}");
  //     Map<String, dynamic> responseBody = json.safeDecode(response.body);
  //     if (response.statusCode == 200 && responseBody['success'] == "success") {
  //       devlog("MyImageData ==> ${responseBody['data']}");
  //       ImageModel model = ImageModel.fromJson(responseBody);
  //       imageList = model.data!;
  //       for (int i = 0; i < imageList.length; i++) {
  //         if (imageList[i].banner_type == "header") {
  //           imageListHeader.add(imageList[i]);
  //         } else {
  //           imageListFooter.add(imageList[i]);
  //         }
  //       }
  //     } else if (response.statusCode == 200 && responseBody['success'] == "Failed") {
  //     } else {
  //       ShowToastDialog.showToast('Something went wrong. Please try again later');
  //       throw Exception('Something went wrong.!');
  //     }
  //   } catch (e) {
  //     // ShowToastDialog.closeLoader();
  //   }
  //   return null;
  // }

  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;
  BitmapDescriptor? taxiIcon;
  BitmapDescriptor? stopIcon;

  final Map<String, Marker> markers = {};

  setIcons() async {
    BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(10, 10)), "assets/icons/pickup.png").then((value) {
      departureIcon = value;
    });

    BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(10, 10)), "assets/icons/dropoff.png").then((value) {
      destinationIcon = value;
    });

    BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(10, 10)), "assets/icons/ic_taxi.png").then((value) {
      taxiIcon = value;
    });

    BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(10, 10)), "assets/icons/location.png").then((value) {
      stopIcon = value;
    });
  }

  addStops() async {
    // ShowToastDialog.showLoader("Please wait");
    multiStopList.add(AddStopModel(editingController: TextEditingController(), latitude: "", longitude: ""));
    multiStopListNew = List<AddStopModel>.generate(
      multiStopList.length,
      (int index) => AddStopModel(editingController: multiStopList[index].editingController, latitude: multiStopList[index].latitude, longitude: multiStopList[index].longitude),
    );
    // ShowToastDialog.closeLoader();
    update();
  }

  removeStops(int index) {
    // ShowToastDialog.showLoader("Please wait");
    multiStopList.removeAt(index);
    multiStopListNew = List<AddStopModel>.generate(
      multiStopList.length,
      (int index) => AddStopModel(editingController: multiStopList[index].editingController, latitude: multiStopList[index].latitude, longitude: multiStopList[index].longitude),
    );
    // ShowToastDialog.closeLoader();
    update();
  }

  clearData() {
    selectedVehicle.value = "";
    selectPaymentMode.value = "Payment Method";
    paymentMethodType = "Select Method".obs;
    paymentMethodId = "".obs;
    distance = 0.0.obs;
    duration = "".obs;
    multiStopList.clear();
    multiStopListNew.clear();
  }

  RxList<DriverLocationModel> driverLocationList = <DriverLocationModel>[].obs;

  Future getTaxiData() async {
    totalAmount.value = 0.0;
    selectedVehicle.value = "";
    Constant.driverLocationUpdateCollection.where("active", isEqualTo: true).snapshots().listen((event) {
      for (var element in event.docs) {
        DriverLocationModel driverLocationUpdate = DriverLocationModel.fromJson(element.data() as Map<String, dynamic>);
        driverLocationList.add(driverLocationUpdate);
        driverLocationList.forEach((element) {
          markers[element.driverId.toString()] = Marker(
            markerId: MarkerId(element.driverId.toString()),
            rotation: double.parse(element.rotation.toString()),
            // infoWindow: InfoWindow(title: element.prenom.toString(), snippet: "${element.brand},${element.model},${element.numberplate}"),
            position: LatLng(double.parse(element.driverLatitude.toString().isNotEmpty ? element.driverLatitude.toString() : "0.0"),
                double.parse(element.driverLongitude.toString().isNotEmpty ? element.driverLongitude.toString() : "0.0")),
            icon: taxiIcon!,
          );
        });
      }
    });
  }

/*  Future<dynamic> getDurationDistance(
      LatLng departureLatLong, LatLng destinationLatLong) async {
    ShowToastDialog.showLoader("Please wait");
    double originLat, originLong, destLat, destLong;
    originLat = departureLatLong.latitude;
    originLong = departureLatLong.longitude;
    destLat = destinationLatLong.latitude;
    destLong = destinationLatLong.longitude;

    String url = 'https://maps.googleapis.com/maps/api/distancematrix/json';
    http.Response restaurantToCustomerTime = await LoggingClient(http.Client()).get(Uri.parse(
        '$url?units=metric&origins=$originLat,'
        '$originLong&destinations=$destLat,$destLong&key=${Constant.kGoogleApiKey}'));

    var decodedResponse = jsonDecode(restaurantToCustomerTime.body);

    if (decodedResponse['status'] == 'OK' &&
        decodedResponse['rows'].first['elements'].first['status'] == 'OK') {
      ShowToastDialog.closeLoader();
      devlog("MyLogData DurationDistance ==> $decodedResponse");
      return decodedResponse;
      //   estimatedTime = decodedResponse['rows'].first['elements'].first['distance']['value'] / 1000.00;
      //   if (selctedOrderTypeValue == "Delivery") {
      //     setState(() => deliveryCharges = (estimatedTime! * double.parse(deliveryCost)).toString());
      //   }
    }
    ShowToastDialog.closeLoader();
    return null;
  }*/

  Future<dynamic> getDurationDistance(LatLng departureLatLong, LatLng destinationLatLong, List<LatLng> stopMarkers) async {
    double originLat, originLong, destLat, destLong;
    originLat = departureLatLong.latitude;
    originLong = departureLatLong.longitude;
    destLat = destinationLatLong.latitude;
    destLong = destinationLatLong.longitude;
    getDurationDistanceNew(departureLatLong, destinationLatLong, stopMarkers);
    String url = 'https://maps.googleapis.com/maps/api/distancematrix/json';
    devlog("responseeeeeeeeeeeeeeeeeeeeeee dfsd");
    http.Response restaurantToCustomerTime = await LoggingClient(http.Client()).get(Uri.parse('$url?units=metric&origins=$originLat,'
        '$originLong&destinations=$destLat,$destLong&key=${Constant.kGoogleApiKey}'));
    devlog("responseeeeeeeeeeeeeeeeeeeeeee ajhatjh");

    var decodedResponse = jsonDecode(restaurantToCustomerTime.body);

    if (decodedResponse['status'] == 'OK' && decodedResponse['rows'].first['elements'].first['status'] == 'OK') {
      return decodedResponse;
    }

    return null;
  }

  Future<Map<String, dynamic>> getDurationDistanceNew(LatLng departureLatLong, LatLng destinationLatLong, List<LatLng> stopMarkers) async {
    ShowToastDialog.showLoader("Please wait");

    double totalDistance = 0.0;
    double totalDuration = 0.0;
    devlog("MyDistanceCount ==> stopMarkers $stopMarkers");
    // Prepare the list of waypoints, including departure, stop markers, and destination
    List<LatLng> waypoints = [departureLatLong, ...stopMarkers, destinationLatLong];
    devlog("MyDistanceCount ==> waypoints $waypoints");
    String url = 'https://maps.googleapis.com/maps/api/distancematrix/json';
    String apiKey = Constant.kGoogleApiKey!;

    for (int i = 0; i < waypoints.length - 1; i++) {
      double originLat = waypoints[i].latitude;
      double originLong = waypoints[i].longitude;
      double destLat = waypoints[i + 1].latitude;
      double destLong = waypoints[i + 1].longitude;

      String requestUrl = '$url?units=metric&origins=$originLat,$originLong&destinations=$destLat,$destLong&key=$apiKey';
      http.Response response = await LoggingClient(http.Client()).get(Uri.parse(requestUrl));

      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(response.body);

        if (decodedResponse['status'] == 'OK' && decodedResponse['rows'].first['elements'].first['status'] == 'OK') {
          var element = decodedResponse['rows'].first['elements'].first;
          totalDistance += element['distance']['value'];
          totalDuration += element['duration']['value'];
        } else {
          ShowToastDialog.closeLoader();
          return {
            'status': 'ERROR',
            'message': 'Error calculating route segment',
          };
        }
      } else {
        ShowToastDialog.closeLoader();
        return {
          'status': 'ERROR',
          'message': 'Failed to get response from Google API',
        };
      }
    }
    devlog("MyDistanceCount ==> totalDistance $totalDistance");
    devlog("MyDistanceCount ==> totalDuration ${totalDistance / 1000.0}");
    ShowToastDialog.closeLoader();
    distance.value = totalDistance / 1000.0;
    distanceSavedForRoundTrip.value = totalDistance / 1000.0;
    duration.value = formatDuration(totalDuration);
    durationFloat.value = totalDuration;
    durationFloatSavedForRoundTrip.value = totalDuration;
    devlog("798765468761368463513684512348845456 aaa");
    return {
      'status': 'OK',
      'total_distance': totalDistance,
      'total_duration': totalDuration,
    };
  }

  String formatDuration(double totalSeconds) {
    int hours = (totalSeconds ~/ 3600);
    int minutes = ((totalSeconds % 3600) ~/ 60);
    int seconds = (totalSeconds % 60).round();

    if (seconds >= 30) {
      minutes += 1;
    }

    if (minutes >= 60) {
      hours += minutes ~/ 60;
      minutes = minutes % 60;
    }

    if (hours == 0) return "$minutes mins";

    return "$hours hrs $minutes mins";
  }

  // Position? _position;

  Future<PlacesDetailsResponse?> placeSelectAPI(context) async {
    // Get the current location
    // if (_position == null) {
    //   await showLoader("Loading..");
    //   _position = await _determinePosition();
    //   await hideLoader();
    // }
    // Position position = _position ?? await _determinePosition();
    // Show input autocomplete with selected mode
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: Constant.kGoogleApiKey,
        mode: Mode.overlay,
        onError: (response) {
          log("MyResponse -->${response.status}");
          log("MyResponse -->${response.errorMessage}");
        },
        language: 'en',
        resultTextStyle: Theme.of(context).textTheme.titleMedium,
        types: [],
        strictbounds: false,
        logo: Text(""),
        components: [Component(Component.country, 'in')],
        // location: Location(lat: position.latitude, lng: position.longitude),
        radius: 10000,
        hint: "Search location..",
        // textDecoration: InputDecoration(border: OutlineInputBorder(
        //   borderRadius: BorderRadius.circular(10),
        //   borderSide: BorderSide(color: ConstantColors.primary, width: 1),
        // ))
        overlayBorderRadius: BorderRadius.circular(10));

    return displayPrediction(p);
  }

  // Future<Position> _determinePosition() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;
  //
  //   // Check if location services are enabled
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     // Location services are not enabled, you could show a dialog and return.
  //     return Future.error('Location services are disabled.');
  //   }
  //
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       // Permissions are denied, next time you could try requesting permissions again.
  //       return Future.error('Location permissions are denied');
  //     }
  //   }
  //
  //   if (permission == LocationPermission.deniedForever) {
  //     // Permissions are denied forever, handle appropriately.
  //     return Future.error('Location permissions are permanently denied, we cannot request permissions.');
  //   }
  //
  //   // When permissions are granted, get the position of the device.
  //   return await Geolocator.getCurrentPosition();
  // }

  // Future<PlacesDetailsResponse?> placeSelectAPI(BuildContext context) async {
  //   // show input autocomplete with selected mode
  //   // then get the Prediction selected
  //   Prediction? p = await PlacesAutocomplete.show(
  //     context: context,
  //     apiKey: Constant.kGoogleApiKey,
  //     mode: Mode.overlay,
  //     onError: (response) {
  //       log("MyResponse -->${response.status}");
  //     },
  //     language: 'en',
  //     resultTextStyle: Theme.of(context).textTheme.titleMedium,
  //     types: [],
  //     strictbounds: false,
  //     components: [Component(Component.country, 'in')],
  //   );
  //   return displayPrediction(p!);
  // }

  Future<PlacesDetailsResponse?> displayPrediction(Prediction? p) async {
    if (p != null) {
      GoogleMapsPlaces? places = GoogleMapsPlaces(
        apiKey: Constant.kGoogleApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders(),
      );
      PlacesDetailsResponse? detail = await places.getDetailsByPlaceId(p.placeId.toString());

      return detail;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserPendingPayment() async {
    try {
      Map<String, dynamic> bodyParams = {'user_id': Preferences.getInt(Preferences.userId)};
      final response = await LoggingClient(http.Client()).post(Uri.parse(API.userPendingPayment), headers: API.header, body: jsonEncode(bodyParams));

      Map<String, dynamic> responseBody = json.safeDecode(response.body);
      devlog("MyLogData UserPendingPayment ==> ${responseBody}");
      if (response.statusCode == 200) {
        return responseBody;
      } else {
        ShowToastDialog.showToast('Something went wrong. Please try again later');
        throw Exception('Something went wrong.!');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
      devlog("MyLogData TimeoutException ==> ${e.message.toString()}");
    } on SocketException catch (e) {
      ShowToastDialog.showToast(e.message.toString());
      devlog("MyLogData SocketException ==> ${e.message.toString()}");
    } on Error catch (e) {
      ShowToastDialog.showToast(e.toString());
      devlog("MyLogData Error catch ==> ${e.toString()}");
    } catch (e) {
      ShowToastDialog.showToast(e.toString());
      devlog("MyLogData catch ==> ${e.toString()}");
    }
    return null;
  }

  Future<VehicleCategoryModel?> getVehicleCategory() async {
    try {
      ShowToastDialog.showLoader("Please wait");
      devlog("responseeeeeeeeeeeeeeeeeeeeeee");
      final data = {
        "latitude": departureLatLong.value.latitude,
        "longitude": departureLatLong.value.longitude,
      };
      // final response = await LoggingClient(http.Client()).get(Uri.parse(API.getVehicleCategory), headers: API.header);
      final response = await LoggingClient(http.Client()).post(Uri.parse(API.getVehicleCategory), body: jsonEncode(data), headers: API.header);

      Map<String, dynamic> responseBody = json.safeDecode(response.body);

      if (response.statusCode == 200) {
        update();
        ShowToastDialog.closeLoader();
        return VehicleCategoryModel.fromJson(responseBody);
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast('Something went wrong. Please try again later');
        throw Exception('Something went wrong.!');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  Future<DriverModel?> getDriverDetails(String typeVehicle, String lat1, String lng1) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await LoggingClient(http.Client()).get(Uri.parse("${API.driverDetails}?type_vehicle=$typeVehicle&lat1=$lat1&lng1=$lng1"), headers: API.header);
      log(response.request.toString());
      devlog("token ==> ${Preferences.getString(Preferences.accesstoken)}");
      Map<String, dynamic> responseBody = json.safeDecode(response.body);
      devlog("MyLogData DriverDetails ==> $responseBody");
      devlog("MyLogData typeVehicle ==> $typeVehicle");
      devlog("MyLogData typeVehicle ==> ${Uri.parse("${API.driverDetails}?type_vehicle=$typeVehicle&lat1=$lat1&lng1=$lng1")}");
      devlog("MyLogData lat1 ==> $lat1");
      devlog("MyLogData lng1 ==> $lng1");
      log(responseBody.toString());
      if (response.statusCode == 200) {
        ShowToastDialog.closeLoader();
        return DriverModel.fromJson(responseBody);
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast('Something went wrong. Please try again later');
        throw Exception('Something went wrong.!');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
      devlog("MyLogData TimeoutException ==> ${e.message.toString()}");
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
      devlog("MyLogData SocketException ==> ${e.message.toString()}");
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
      devlog("MyLogData Error catch ==> ${e.toString()}");
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
      devlog("MyLogData catch ==> ${e.toString()}");
    }
    return null;
  }

  Future<dynamic> setFavouriteRide(Map<String, String> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await LoggingClient(http.Client()).post(Uri.parse(API.setFavouriteRide), headers: API.header, body: jsonEncode(bodyParams));
      Map<String, dynamic> responseBody = json.safeDecode(response.body);

      if (response.statusCode == 200) {
        ShowToastDialog.closeLoader();
        return responseBody;
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast('Something went wrong. Please try again later');
        throw Exception('Something went wrong.!');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
    }
  }

  Future<dynamic> bookRide(Map<String, dynamic> bodyParams) async {
    try {
      ShowToastDialog.showLoader("Please wait");
      final response = await LoggingClient(http.Client()).post(Uri.parse(API.bookRides), headers: API.header, body: jsonEncode(bodyParams));
      devlog("bookRide ==> bodyParams ${bodyParams.toString()}");
      devlog("bookRide ==> Response ${response.body.toString()}");
      Map<String, dynamic> responseBody = json.safeDecode(response.body);

      if (response.statusCode == 200) {
        ShowToastDialog.closeLoader();
        return responseBody;
      } else {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast('Something went wrong. Please try again later');
        throw Exception('Something went wrong.!');
      }
    } on TimeoutException catch (e) {
      ShowToastDialog.closeLoader();

      ShowToastDialog.showToast(e.message.toString());
    } on SocketException catch (e) {
      ShowToastDialog.closeLoader();

      ShowToastDialog.showToast(e.message.toString());
    } on Error catch (e) {
      ShowToastDialog.closeLoader();

      ShowToastDialog.showToast(e.toString());
    } catch (e) {
      ShowToastDialog.closeLoader();

      ShowToastDialog.showToast(e.toString());
    }
    return null;
  }

  // double calculate30PercentageAmount({required double basePrice}) {
  //   return double.parse(((basePrice * Preferences.getInitialPaymentPercentage()) / 100).toStringAsFixed(2));
  //   // return ((basePrice * Constant.initialPaymentPercentage) / 100).round();
  // }

  Future<void> razorPayPayment({
    bool isOutstation = false,
    required DateTime dailyDateTime,
    required DateTime osStartDateTime,
    required bool isRoundTrip,
    required DateTime osEndDateTime,
    required String? couponId,
    required String? assignId,
    required int? discount,
  }) async {
    devlog("razorPayPayment started");

    final startTimeForCompare = isOutstation ? osStartDateTime : dailyDateTime;
    devlog("startTimeForCompare calculated: $startTimeForCompare");

    final bool canSearchDriver = (startTimeForCompare.difference(DateTime.now()).inMinutes < 5);
    devlog("canSearchDriver calculated: $canSearchDriver");

    devlog("isOutstation: $isOutstation");
    devlog("startTimeForCompare.difference(DateTime.now()).inMinutes: ${startTimeForCompare.difference(DateTime.now()).inMinutes}");

    // int initialPaymentPercentage = Preferences.getInitialPaymentPercentage();
    // devlog("Initial Payment Percentage: $initialPaymentPercentage");

    // if (initialPaymentPercentage != 0) {
    //   devlog("Initial payment percentage is not zero, proceeding with Razorpay payment");
    //
    //   // MainPageController.getPaymentSetting() might be async? If yes, await it.
    //   MainPageController.getPaymentSetting();
    //   devlog("Payment settings fetched");
    //
    //   UserModel userModel = Constant.getUserData();
    //   devlog("User data fetched: ${userModel.data}");
    //
    //   int? amount = calculate30PercentageAmount(basePrice: advancePayAmount.value * 100).round();
    //   devlog("Calculated payment amount: $amount");
    //
    //   final isTestMode = false;
    //   devlog("Is Test Mode: $isTestMode");
    //
    //   String key = (isTestMode) ? "rzp_test_SSZYwBRuFiWZXV" : MainPageController.getPaymentSetting().razorpay?.key ?? "";
    //   // String key = "rzp_test_SSZYwBRuFiWZXV";
    //   devlog("Razorpay key: $key");
    //
    //   var options = {
    //     'key': key,
    //     'amount': amount,
    //     'name': 'ZoCar',
    //     'description': '$initialPaymentPercentage % Advance Payment',
    //     'retry': {'enabled': true, 'max_count': 1},
    //     'send_sms_hash': true,
    //     'prefill': {
    //       'contact': '${userModel.data?.phone}',
    //       'email': '${userModel.data?.email}',
    //     },
    //     'external': {
    //       'wallets': ['paytm'],
    //     }
    //   };
    //   devlog("Razorpay options prepared: $options");
    //
    //   razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    //   devlog("Set payment error handler");
    //
    //   razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) {
    //     devlog("Payment success event triggered with response: $response");
    //     _handlePaymentSuccess(
    //       response: response,
    //       searchDriver: canSearchDriver,
    //       isOutstation: isOutstation,
    //       dailyDateTime: dailyDateTime,
    //       isRoundTrip: isRoundTrip,
    //       osStartDateTime: osStartDateTime,
    //       osEndDateTime: osEndDateTime,
    //     );
    //   });
    //   devlog("Set payment success handler");
    //
    //   razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWaller);
    //   devlog("Set external wallet handler");
    //
    //   devlog("Opening Razorpay checkout");
    //   razorpay.open(options);
    //   devlog("Razorpay checkout opened");
    // } else if (initialPaymentPercentage == 0) {
    devlog("Initial payment percentage is zero, skipping Razorpay and handling success directly");
    _handlePaymentSuccess(
      searchDriver: canSearchDriver,
      isOutstation: isOutstation,
      dailyDateTime: dailyDateTime,
      isRoundTrip: isRoundTrip,
      osStartDateTime: osStartDateTime,
      osEndDateTime: osEndDateTime,
      assignId: assignId,
      couponId: couponId,
      discount: discount,
    );
    devlog("Handled payment success directly");
    // }

    devlog("razorPayPayment function ended");
  }

  bool loadingx = false;

  Future<void> _handlePaymentSuccess({
    PaymentSuccessResponse? response,
    bool searchDriver = true,
    bool isOutstation = false,
    required DateTime dailyDateTime,
    required DateTime osStartDateTime,
    required bool isRoundTrip,
    required DateTime osEndDateTime,
    required String? couponId,
    required String? assignId,
    required int? discount,
  }) async {
    List stopsList = [];
    // bool rideAccepted = false;
    // ValueNotifier<bool> rideAccepted = ValueNotifier(false);

    if (loadingx) return;

    loadingx = true;

    for (var stop in multiStopListNew) {
      stopsList.add({
        "latitude": stop.latitude.toString(),
        "longitude": stop.longitude.toString(),
        "location": stop.editingController.text.toString(),
      });
    }

    final now = DateTime.now();
    DateTime dateTime = isOutstation ? osStartDateTime : dailyDateTime;
    final DateTime? returnDateTime = (isOutstation && isRoundTrip) ? osEndDateTime : null;
    if (dateTime.isBefore(now)) {
      dateTime = now;
    }

    // 🔥 Get delay from API
    final rideSettings = Preferences.rideSettings;
    final int delayMinutes = rideSettings?.scheduleRideStartDelay ?? 0;

    final bool isScheduledRide =
        dateTime.difference(now) >= Duration(minutes: delayMinutes);
    final bookingPricing = buildBookingPriceBreakdown(
      baseFare: totalAmount.value,
      discount: (discount ?? 0).toDouble(),
    );

    Map<String, dynamic> bodyParams = {
      'user_id': Preferences.getInt(Preferences.userId).toString(),
      'lat1': departureLatLong.value.latitude.toString(),
      'lng1': departureLatLong.value.longitude.toString(),
      'lat2': destinationLatLong.value.latitude.toString(),
      'lng2': destinationLatLong.value.longitude.toString(),
      'cout': totalAmount.value.toString(),
      'vechicle_id': selectedVehicle.value,
      'distance': distance.toString(),
      'distance_unit': Constant.distanceUnit.toString(),
      'duree': duration.toString(),
      'id_payment': 5,
      'transaction_id': response?.paymentId ?? "0",
      'depart_name': departureController.text,
      'destination_name': destinationController.text,
      'stops': stopsList,
      'statut_round': (isOutstation && isRoundTrip) ? 'yes' : 'no',
      'time_stamp': DateTime.now().millisecondsSinceEpoch,
      'date_retour': DateFormat("yyyy-MM-dd").format(dateTime),
      'heure_retour': DateFormat("HH:mm:ss").format(dateTime),
      'type': isOutstation ? "outstation_ride" : "daily_ride",
      'return_date': returnDateTime == null ? null : DateFormat("yyyy-MM-dd").format(returnDateTime),""
      'return_hour': returnDateTime == null ? null : DateFormat("HH:mm:ss").format(returnDateTime),
      'coupon_id': couponId,
      'assign_id': assignId,
      "discount": discount,
      "scheduled_ride": isScheduledRide ? 'yes' : 'no',
      ...bookingPricing.toPayload(),
    };

    try {
      await bookRide(bodyParams).then((value) {
        print("isScheduledRide----->$isScheduledRide");
        // rideAccepted.value = false;
        loadingx = false;
        if (value != null && value['success'] == "success") {
          String rideId = value['data'][0]['id'].toString();

          // rideAccepted = true;
          devlog("---rider ACCEPTED A RIDER");
          // rideAccepted.value = true;
          Get.back();
          Get.back();

          if (Get.context != null) {
            if (searchDriver) {
              print("----SEARCH DRIVER FROM RAZORPAY SUCCESS");
              Utils.showBottomSearchDriver(Get.context!, rideId);
            } else {
              showDialog(
                  context: Get.context!,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return PopScope(
                      onPopInvokedWithResult: (didPop, result) {
                        final MainPageController controller = Get.find<MainPageController>();
                        controller.selectedDrawerIndex.value = drawerItems.indexWhere((element) => element.isAllRides);
                      },
                      child: CustomDialogBox(
                        title: "",
                        descriptions: "Your booking request has been sent successfully",
                        onPress: () {
                          Navigator.pop(context);
                        },
                        img: Image.asset('assets/images/green_checked.png'),
                      ),
                    );
                  });
            }
          }
        }
      });
    } catch (e) {
      loadingx = false;
      print("--Error in razorpay payment success handler: $e");
      showSnackBarAlert(message: e.toString());
    }
    loadingx = false;
  }

  void _handleExternalWaller(ExternalWalletResponse response) {
    Get.back();
    showSnackBarAlert(
      message: "Payment Processing Via\n${response.walletName!}",
      color: Colors.blue.shade400,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Get.back();
    showSnackBarAlert(
      message: "Payment Failed!!\n "
          "${jsonDecode(response.message!)['error']['description']}",
      color: Colors.red.shade400,
    );
  }

  showSnackBarAlert({required String message, Color color = Colors.green}) {
    return Get.showSnackbar(GetSnackBar(
      isDismissible: true,
      message: message,
      backgroundColor: color,
      duration: const Duration(seconds: 2),
    ));
  }
}

/*  if (distance > minimumDeliveryChargesWithin) {
      cout = (distance * deliveryCharges).toDouble();
    } else {
      cout = minimumDeliveryCharges;
    }*/

class AddChildModel {
  TextEditingController editingController = TextEditingController();

  AddChildModel({required this.editingController});
}

class AddStopModel {
  String latitude = "";
  String longitude = "";
  TextEditingController editingController = TextEditingController();

  AddStopModel({
    required this.editingController,
    required this.latitude,
    required this.longitude,
  });
}
