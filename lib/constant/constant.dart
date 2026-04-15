// ignore_for_file: deprecated_member_use, non_constant_identifier_names, body_might_complete_normally_catch_error
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/controller/main_page_controller.dart';
import 'package:zocar/model/payment_setting_model.dart';
import 'package:zocar/model/tax_model.dart';
import 'package:zocar/model/user_model.dart';
import 'package:zocar/page/chats_screen/conversation_screen.dart';
import 'package:zocar/themes/button_them.dart';
import 'package:zocar/themes/constant_colors.dart';
import 'package:zocar/utils/preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:map_launcher/map_launcher.dart' as launcher;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path/path.dart' as path;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmf;
import 'package:google_api_headers/src/google_api_headers.dart';
import '../helpers/devlog.dart';

/// here is only newly added images, old code have hard coded string in each place in code :(
const kImgWhiteBg = "assets/images/white_bg.jpg";
const kImgZocar = "assets/images/zocar.png";
const kImgZocarWhite = "assets/images/zokar.png";
const kImgInfo = "assets/icons/info.png";

class Constant {
  static const String appName = 'ZoCar';
  static const String appType = 'customer';
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.zocar.cab&hl=en_IN';
  static const String iosUrl = '';

  // Preference keys for dynamic values
  static const String _keyGoogleApiKey = 'google_api_key';
  static const String _keyDistanceUnit = 'distance_unit';
  static const String _keyDecimal = 'decimal';
  static const String _keyDriverLocationUpdate = 'driver_location_update';
  static const String _keyDeliverChargeParcel = 'deliver_charge_parcel';
  static const String _keyParcelPerWeightCharge = 'parcel_per_weight_charge';
  static const String _keyDriverLocationUpdateUnit = 'driver_location_update_unit';
  static const String _keySelectedMapType = 'selected_map_type';
  static const String _keyHomeScreenType = 'home_screen_type';
  static const String _keyRideOtp = 'ride_otp';
  static const String _keyStripePublishableKey = 'stripe_publishable_key';
  static const String _keyTaxList = 'tax_list';
  static const String _keySymbolAtRight = 'symbol_at_right';
  static const String _keyMapType = 'map_type';

  // Getters and Setters with SharedPreferences backing
  static String? get kGoogleApiKey {
    final value = Preferences.getString(_keyGoogleApiKey);
    return value.isEmpty ? "AIzaSyCeTS8oOJapyx6s8hKT-MWgT2sQORTuiAI" : value;
  }
  static set kGoogleApiKey(String? value) {
    if (value != null) Preferences.setString(_keyGoogleApiKey, value);
  }

  static String? get distanceUnit {
    final value = Preferences.getString(_keyDistanceUnit);
    return value.isEmpty ? "KM" : value;
  }
  static set distanceUnit(String? value) {
    if (value != null) Preferences.setString(_keyDistanceUnit, value);
  }

  static String? get decimal {
    final value = Preferences.getString(_keyDecimal);
    return value.isEmpty ? "0" : value;
  }
  static set decimal(String? value) {
    if (value != null) Preferences.setString(_keyDecimal, value);
  }

  static String? get currency {
    final value = Preferences.getString(Preferences.currency);
    return value.isEmpty ? "₹" : value;
  }
  static set currency(String? value) {
    if (value != null) Preferences.setString(Preferences.currency, value);
  }

  static String? get driverRadius {
    final value = Preferences.getString(Preferences.driverRadius);
    return value.isEmpty ? "0" : value;
  }
  static set driverRadius(String? value) {
    if (value != null) {
      Preferences.setString(Preferences.driverRadius, value);
    }
  }

  static bool get symbolAtRight {
    return Preferences.getBool(_keySymbolAtRight, defaultValue: false);
  }
  static set symbolAtRight(bool value) {
    Preferences.setBool(_keySymbolAtRight, value);
  }

  static String get mapType {
    final value = Preferences.getString(_keyMapType);
    return value.isEmpty ? "inappmap" : value;
  }
  static set mapType(String value) {
    Preferences.setString(_keyMapType, value);
  }

  static String get driverLocationUpdate {
    final value = Preferences.getString(_keyDriverLocationUpdate);
    return value.isEmpty ? "10" : value;
  }
  static set driverLocationUpdate(String value) {
    Preferences.setString(_keyDriverLocationUpdate, value);
  }

  static String get deliverChargeParcel {
    final value = Preferences.getString(_keyDeliverChargeParcel);
    return value.isEmpty ? "0" : value;
  }
  static set deliverChargeParcel(String value) {
    Preferences.setString(_keyDeliverChargeParcel, value);
    Preferences.setString(Preferences.deliverChargeParcel, value);
  }

  static String? get parcelPerWeightCharge {
    final value = Preferences.getString(_keyParcelPerWeightCharge);
    return value.isEmpty ? "" : value;
  }
  static set parcelPerWeightCharge(String? value) {
    if (value != null) {
      Preferences.setString(_keyParcelPerWeightCharge, value);
      Preferences.setString(Preferences.parcelPerWeightCharge, value);
    }
  }

  static String get driverLocationUpdateUnit {
    final value = Preferences.getString(_keyDriverLocationUpdateUnit);
    return value.isEmpty ? "10" : value;
  }
  static set driverLocationUpdateUnit(String value) {
    Preferences.setString(_keyDriverLocationUpdateUnit, value);
  }

  // static int get initialPaymentPercentage {
  //   return Preferences.getInitialPaymentPercentage();
  // }
  // static set initialPaymentPercentage(int value) {
  //   Preferences.setInitialPaymentPercentage(value);
  // }

  static String get selectedMapType {
    final value = Preferences.getString(_keySelectedMapType);
    return value.isEmpty ? 'google' : value;
  }
  static set selectedMapType(String value) {
    Preferences.setString(_keySelectedMapType, value);
  }

  static String? get homeScreenType {
    final value = Preferences.getString(_keyHomeScreenType);
    return value.isEmpty ? "OlaHome" : value;
  }
  static set homeScreenType(String? value) {
    if (value != null) Preferences.setString(_keyHomeScreenType, value);
  }

  static String? get contactUsEmail {
    final value = Preferences.getString(Preferences.contactUsEmail);
    return value.isEmpty ? "" : value;
  }
  static set contactUsEmail(String? value) {
    if (value != null) Preferences.setString(Preferences.contactUsEmail, value);
  }

  static String? get contactUsAddress {
    final value = Preferences.getString(Preferences.contactUsAddress);
    return value.isEmpty ? "" : value;
  }
  static set contactUsAddress(String? value) {
    if (value != null) Preferences.setString(Preferences.contactUsAddress, value);
  }

  static String? get contactUsPhone {
    final value = Preferences.getString(Preferences.contactUsPhone);
    return value.isEmpty ? "" : value;
  }
  static set contactUsPhone(String? value) {
    if (value != null) Preferences.setString(Preferences.contactUsPhone, value);
  }

  static String? get rideOtp {
    final value = Preferences.getString(_keyRideOtp);
    return value.isEmpty ? "yes" : value;
  }
  static set rideOtp(String? value) {
    if (value != null) Preferences.setString(_keyRideOtp, value);
  }

  static String get stripePublishablekey {
    final value = Preferences.getString(_keyStripePublishableKey);
    return value.isEmpty ? "pk_test_51Kaaj9SE3HQdbrEJneDaJ2aqIyX1SBpYhtcMKfwchyohSZGp53F75LojfdGTNDUwsDV5p6x5BnbATcrerModlHWa00WWm5Yf5h" : value;
  }
  static set stripePublishablekey(String value) {
    Preferences.setString(_keyStripePublishableKey, value);
  }

  // Tax list with JSON serialization
  static List<TaxModel> get taxList {
    final String jsonStr = Preferences.getString(_keyTaxList);
    if (jsonStr.isEmpty) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList.map((json) => TaxModel.fromJson(json)).toList();
    } catch (e) {
      devlog("Error parsing tax list: $e");
      return [];
    }
  }

  static set taxList(List<TaxModel> value) {
    try {
      final String jsonStr = jsonEncode(value.map((tax) => tax.toJson()).toList());
      Preferences.setString(_keyTaxList, jsonStr);
    } catch (e) {
      devlog("Error saving tax list: $e");
    }
  }

  // Non-persisted static variables
  static LocationData? currentLocation;
  static List<TaxModel> allTaxList = [];
  static bool isBottomSheetVisible = true;
  static bool isAccepted = false;

  // Firebase collections
  static CollectionReference conversation = FirebaseFirestore.instance.collection('conversation');
  static CollectionReference driverLocationUpdateNEw = FirebaseFirestore.instance.collection('driver_location_update');
  static CollectionReference driverLocationUpdateCollection = FirebaseFirestore.instance.collection('driver_location_update');

  static String getUuid() {
    var uuid = const Uuid();
    return uuid.v1();
  }

  static UserModel getUserData() {
    final String user = Preferences.getString(Preferences.user);
    Map<String, dynamic> userMap = jsonDecode(user);
    return UserModel.fromJson(userMap);
  }

  static PaymentSettingModel getPaymentSetting() {
    final String user = Preferences.getString(Preferences.paymentSetting);
    devlog("Payment setting data paymentSetting ==> ${Preferences.getString(Preferences.paymentSetting)}");
    devlog("Payment setting data user ==> $user");
    if (user.isNotEmpty) {
      Map<String, dynamic> userMap = jsonDecode(user);
      return PaymentSettingModel.fromJson(userMap);
    }
    return PaymentSettingModel();
  }

  Future<String> getAddressFromLatLong(Position position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    return '${place.subLocality}, ${place.locality}';
  }

  String amountShow({required String? amount}) {
    final parsedAmount = double.tryParse(amount?.toString() ?? "0") ?? 0.0;
    final parsedDecimal = int.tryParse(decimal ?? "2") ?? 2;
    final formattedAmount = parsedAmount.toStringAsFixed(parsedDecimal);
    final currencySymbol = currency?.toString() ?? "";

    if (symbolAtRight == true) {
      return "$formattedAmount $currencySymbol";
    } else {
      return "$currencySymbol $formattedAmount";
    }
  }

  String sanitizePrice(String price) {
    return price.replaceAll(RegExp(r'[^\d.]'), '');
  }

  static Widget emptyView(BuildContext context, String msg, bool isButtonShow) {
    final controllerDashBoard = Get.put(MainPageController());
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Image.asset('assets/images/empty_placeholde.png'),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 150),
          child: Text(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        Visibility(
          visible: isButtonShow,
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: ButtonThem.buildButton(
              context,
              title: 'Book now'.tr,
              btnHeight: 45,
              btnWidthRatio: 0.8,
              btnColor: ConstantColors.primary,
              txtColor: Colors.white,
              onPress: () async {
                controllerDashBoard.onSelectItem(0);
              },
            ),
          ),
        )
      ],
    );
  }

  static Widget loader() {
    return Center(
      child: CupertinoActivityIndicator(color: ConstantColors.primary),
    );
  }

  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  static Future<void> launchMapURl(String? latitude, String? longLatitude) async {
    String appleUrl = 'https://maps.apple.com/?saddr=&daddr=$latitude,$longLatitude&directionsmode=driving';
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longLatitude';

    if (Platform.isIOS) {
      if (await canLaunch(appleUrl)) {
        await launch(appleUrl);
      } else {
        if (await canLaunch(googleUrl)) {
          await launch(googleUrl);
        } else {
          throw 'Could not open the map.';
        }
      }
    }
  }

  static Future<Url> uploadChatImageToFireStorage(File image) async {
    ShowToastDialog.showLoader('Uploading image...');
    var uniqueID = const Uuid().v4();
    Reference upload = FirebaseStorage.instance.ref().child('images/$uniqueID.png');

    File compressedImage = await compressImage(image);
    log(compressedImage.path);
    UploadTask uploadTask = upload.putFile(compressedImage);

    uploadTask.snapshotEvents.listen((event) {
      ShowToastDialog.showLoader('Uploading image ${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(2)} /'
          '${(event.totalBytes.toDouble() / 1000).toStringAsFixed(2)} '
          'KB');
    });
    uploadTask.whenComplete(() {}).catchError((onError) {
      ShowToastDialog.closeLoader();
      log(onError.message);
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    ShowToastDialog.closeLoader();
    return Url(mime: metaData.contentType ?? 'image', url: downloadUrl.toString());
  }

  static Future<File> compressImage(File file) async {
    final Directory tempDir = await getTemporaryDirectory();
    final String targetPath = path.join(tempDir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');

    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 25,
    );

    return result != null ? File(result.path) : file;
  }

  static Future<ChatVideoContainer> uploadChatVideoToFireStorage(File video) async {
    ShowToastDialog.showLoader('Uploading video');
    var uniqueID = const Uuid().v4();
    Reference upload = FirebaseStorage.instance.ref().child('videos/$uniqueID.mp4');
    SettableMetadata metadata = SettableMetadata(contentType: 'video');
    UploadTask uploadTask = upload.putFile(video, metadata);
    uploadTask.snapshotEvents.listen((event) {
      ShowToastDialog.showLoader('Uploading video ${(event.bytesTransferred.toDouble() / 1000).toStringAsFixed(2)} /'
          '${(event.totalBytes.toDouble() / 1000).toStringAsFixed(2)} '
          'KB');
    });
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    final uint8list = await VideoThumbnail.thumbnailFile(video: downloadUrl, thumbnailPath: (await getTemporaryDirectory()).path, imageFormat: ImageFormat.PNG);
    final file = File(uint8list ?? '');
    String thumbnailDownloadUrl = await uploadVideoThumbnailToFireStorage(file);
    ShowToastDialog.closeLoader();
    return ChatVideoContainer(videoUrl: Url(url: downloadUrl.toString(), mime: metaData.contentType ?? 'video'), thumbnailUrl: thumbnailDownloadUrl);
  }

  static Future<String> uploadVideoThumbnailToFireStorage(File file) async {
    var uniqueID = const Uuid().v4();
    Reference upload = FirebaseStorage.instance.ref().child('thumbnails/$uniqueID.png');
    File compressedImage = await compressImage(file);
    UploadTask uploadTask = upload.putFile(compressedImage);
    var downloadUrl = await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  static redirectMap({required String name, required double latitude, required double longLatitude}) async {
    if (mapType == "google") {
      bool? isAvailable = await launcher.MapLauncher.isMapAvailable(launcher.MapType.google);
      if (isAvailable == true) {
        await launcher.MapLauncher.showDirections(
          mapType: launcher.MapType.google,
          directionsMode: launcher.DirectionsMode.driving,
          destinationTitle: name,
          destination: launcher.Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("Google map is not installed");
      }
    } else if (mapType == "googleGo") {
      bool? isAvailable = await launcher.MapLauncher.isMapAvailable(launcher.MapType.googleGo);
      if (isAvailable == true) {
        await launcher.MapLauncher.showDirections(
          mapType: launcher.MapType.googleGo,
          directionsMode: launcher.DirectionsMode.driving,
          destinationTitle: name,
          destination: launcher.Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("Google Go map is not installed");
      }
    } else if (mapType == "waze") {
      bool? isAvailable = await launcher.MapLauncher.isMapAvailable(launcher.MapType.waze);
      if (isAvailable == true) {
        await launcher.MapLauncher.showDirections(
          mapType: launcher.MapType.waze,
          directionsMode: launcher.DirectionsMode.driving,
          destinationTitle: name,
          destination: launcher.Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("Waze is not installed");
      }
    } else if (mapType == "mapswithme") {
      bool? isAvailable = await launcher.MapLauncher.isMapAvailable(launcher.MapType.mapswithme);
      if (isAvailable == true) {
        await launcher.MapLauncher.showDirections(
          mapType: launcher.MapType.mapswithme,
          directionsMode: launcher.DirectionsMode.driving,
          destinationTitle: name,
          destination: launcher.Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("Mapswithme is not installed");
      }
    } else if (mapType == "yandexNavi") {
      bool? isAvailable = await launcher.MapLauncher.isMapAvailable(launcher.MapType.yandexNavi);
      if (isAvailable == true) {
        await launcher.MapLauncher.showDirections(
          mapType: launcher.MapType.yandexNavi,
          directionsMode: launcher.DirectionsMode.driving,
          destinationTitle: name,
          destination: launcher.Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("YandexNavi is not installed");
      }
    } else if (mapType == "yandexMaps") {
      bool? isAvailable = await launcher.MapLauncher.isMapAvailable(launcher.MapType.yandexMaps);
      if (isAvailable == true) {
        await launcher.MapLauncher.showDirections(
          mapType: launcher.MapType.yandexMaps,
          directionsMode: launcher.DirectionsMode.driving,
          destinationTitle: name,
          destination: launcher.Coords(latitude, longLatitude),
        );
      } else {
        ShowToastDialog.showToast("yandexMaps map is not installed");
      }
    }
  }

  Future<CitySearchPrediction?> searchCityLocation(BuildContext context, {List<String>? types}) async {
    void onError(response) {
      ShowToastDialog.showToast(response.errorMessage ?? 'Unknown error');
    }

    final p = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        onError: onError,
        mode: Mode.overlay,
        language: 'en',
        components: [],
        types: types,
        logo: Text(""),
        resultTextStyle: Theme.of(context).textTheme.titleMedium);

    if (p == null || p.placeId == null) {
      return null;
    }
    final places = GoogleMapsPlaces(
      apiKey: kGoogleApiKey,
      apiHeaders: await const GoogleApiHeaders().getHeaders(),
    );

    final detail = await places.getDetailsByPlaceId(p.placeId!);

    final latlng = gmf.LatLng(detail.result.geometry!.location.lat, detail.result.geometry!.location.lng);

    String cityName = '';
    for (var component in detail.result.addressComponents) {
      if (component.types.contains('locality')) {
        cityName = component.longName;
        break;
      }
    }
    if (cityName.isEmpty) {
      for (var component in detail.result.addressComponents) {
        if (component.types.contains('administrative_area_level_2')) {
          cityName = component.longName;
          break;
        }
      }
    }
    devlog("cityname : $cityName");
    return CitySearchPrediction(city: cityName, latLng: latlng);
  }
}

class CitySearchPrediction {
  final gmf.LatLng latLng;
  final String city;

  CitySearchPrediction({required this.latLng, required this.city});

  Map<String, dynamic> toJson() => {
    'latitude': latLng.latitude,
    'longitude': latLng.longitude,
    'city': city,
  };

  factory CitySearchPrediction.fromJson(Map<String, dynamic> json) {
    return CitySearchPrediction(
      latLng: gmf.LatLng(
        (json['latitude'] as num).toDouble(),
        (json['longitude'] as num).toDouble(),
      ),
      city: json['city'],
    );
  }
}

class SearchLocationPair {
  final CitySearchPrediction from;
  final CitySearchPrediction to;

  SearchLocationPair({required this.from, required this.to});

  Map<String, dynamic> toJson() => {
    'from': from.toJson(),
    'to': to.toJson(),
  };

  factory SearchLocationPair.fromJson(Map<String, dynamic> json) {
    return SearchLocationPair(
      from: CitySearchPrediction.fromJson(json['from']),
      to: CitySearchPrediction.fromJson(json['to']),
    );
  }
}

class Url {
  String mime;
  String url;

  Url({this.mime = '', this.url = ''});

  factory Url.fromJson(Map<dynamic, dynamic> parsedJson) {
    return Url(mime: parsedJson['mime'] ?? '', url: parsedJson['url'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'mime': mime, 'url': url};
  }
}