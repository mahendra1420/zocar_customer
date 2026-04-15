import 'dart:async';
import 'dart:io';

import 'package:zocar/helpers/devlog.dart';
import 'package:zocar/utils/preferences.dart';

import 'package:http/http.dart' as http;

import 'dart:convert';

extension SafeDecode on JsonCodec {
  dynamic safeDecode(String value) {
    try {
      return json.decode(value);
    } catch (e) {
      return <String, dynamic>{};
    }
  }
}

class LoggingClient {
  final http.Client _inner;

  LoggingClient(this._inner);

  void _log(String method, Uri url, var headers, Object? body, http.Response response) {
    final bodyString = body != null ? "📨 Body: $body" : "";
    final responseBody = response.body;

    devlog(
        "-----------------------------------------------------------------------------------\n"
        "📡 Request: $method $url \n"
        "📨 Headers: ${headers} \n"
        "$bodyString \n"
        "✅ Status: ${response.statusCode} \n"
        "📦 Response: ${(responseBody.toString().length > 3000) ? responseBody.toString().substring(0, 3000) : responseBody.toString()} \n"
        "-----------------------------------------------------------------------------------\n",
        name: "[ API LOG ]");
  }

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final response = await _inner.get(url, headers: headers);
    _log("GET", url, headers, null, response);
    return response;
  }

  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final response = await _inner.post(url, headers: headers, body: body, encoding: encoding);
    _log("POST", url, headers, body, response);
    return response;
  }
}

class API {
  // static const baseUrl = "https://admin.zocar.co.in/api/v1/"; // live
  // static const apiKey = "base64:Da/G9umZfVYh0mNBY1P5td1gFQ0Xq8KeNecT2GNf/nk=";//live
  static const apiKey = "base64:Z6YdVQ1qBHOK/px2+WtJfr6EHLPvRpKjjUF41E3jgOA=";//staging
  static const baseUrl = "https://devadmin.zocar.co.in/api/v1/"; // staging



  static Map<String, String> authheader = {
    HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
    'apikey': apiKey,
  };
  static Map<String, String> header = {
    HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
    'apikey': apiKey,
    'accesstoken': Preferences.getString(Preferences.accesstoken)
  };

  static Map<String, String> headerForReview = {
    HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
    'apikey': apiKey,
    'Accept': '*/*',
    'accesstoken': Preferences.getString(Preferences.accesstoken)
  };

  static Map<String, String> headerSecond = {'apikey': apiKey, 'Accept': 'application/json', 'accesstoken': Preferences.getString(Preferences.accesstoken)};
//88 63 84 43 24
  static const userStatus = "${baseUrl}user-status";
  static const versionCheck = "${baseUrl}check-force-update";
  static const userSignUP = "${baseUrl}user";
  static const userLogin = "${baseUrl}user-login";
  static const userLoginOtp = "${baseUrl}login/otp";
  static const userLoginVerifyOtp = "${baseUrl}verify/login/otp";
  static const editProfile = "${baseUrl}update-user-profile";
  static const sendResetPasswordOtp = "${baseUrl}reset-password-otp";
  static const resetPasswordOtp = "${baseUrl}resert-password";
  static const getProfileByPhone = "${baseUrl}profilebyphone";
  static const getExistingUserOrNot = "${baseUrl}existing-user";
  static const updateUserNic = "${baseUrl}update-user-nic";
  static const uploadUserPhoto = "${baseUrl}user-photo";
  static const updateUserEmail = "${baseUrl}update-user-email";
  static const changePassword = "${baseUrl}update-user-mdp";
  static const updatePreName = "${baseUrl}user-pre-name";
  static const updateLastName = "${baseUrl}user-name";
  static const updateAddress = "${baseUrl}user-address";
  static const contactUs = "${baseUrl}contact-us";
  static const updateToken = "${baseUrl}update-fcm";
  static const favorite = "${baseUrl}favorite";
  static const rentVehicle = "${baseUrl}vehicle-get";
  static const transaction = "${baseUrl}transaction";
  static const wallet = "${baseUrl}wallet";
  static const amount = "${baseUrl}amount";
  static const getFcmToken = "${baseUrl}fcm-token";
  static const deleteFavouriteRide = "${baseUrl}delete-favorite-ride";
  static const rejectRide = "${baseUrl}set-rejected-requete";
  static const getRideReview = "${baseUrl}get-ride-review";
  static const taxi = "${baseUrl}taxi";
  static const userPendingPayment = "${baseUrl}user-pending-payment";
  static const setFavouriteRide = "${baseUrl}favorite-ride";
  static const getVehicleCategory = "${baseUrl}Vehicle-category";
  static const driverDetails = "${baseUrl}driver";
  static const getPaymentMethod = "${baseUrl}payment-method";
  // static const bookRides = "${baseUrl}requete-register";
  static const userAllRides = "${baseUrl}user-all-rides";
  static const newRide = "${baseUrl}requete-userapp";
  static const confirmedRide = "${baseUrl}user-confirmation";
  static const onRide = "${baseUrl}user-ride";
  static const completedRide = "${baseUrl}user-complete";
  static const canceledRide = "${baseUrl}user-cancel";
  static const driverConfirmRide = "${baseUrl}driver-confirm";
  static const feelSafeAtDestination = "${baseUrl}feel-safe";
  static const sos = "${baseUrl}storesos";
  static const bookRentalVehicle = "${baseUrl}set-Location";
  static const getRentedData = "${baseUrl}location";
  static const cancelRentedVehicle = "${baseUrl}canceled-location";
  static const paymentSetting = "${baseUrl}payment-settings";
  static const payRequestWallet = "${baseUrl}pay-requete-wallet";
  static const payRequestCash = "${baseUrl}payment-by-cash";
  static const payRequestTransaction = "${baseUrl}new-pay-requete";
  static const addReview = "${baseUrl}review";
  static const addComplaint = "${baseUrl}complaints";
  static const getComplaint = "${baseUrl}complaintsList";

  // static const discountList = "${baseUrl}discount-list";
  static String get discountList => "${baseUrl}discount-list?id_user_app=${Preferences.getInt(Preferences.userId)}";

  static String get rewardDiscountList => "${baseUrl}assign-discount-list?id_user_app=${Preferences.getInt(Preferences.userId)}";
  static const rideDetails = "${baseUrl}ridedetails";
  static const getLanguage = "${baseUrl}language";
  static const deleteUser = "${baseUrl}user-delete?user_id=";
  static const settings = "${baseUrl}settings";
  static const rideSettings = "${baseUrl}ride-settings";
  static const privacyPolicy = "${baseUrl}privacy-policy";
  static const termsOfCondition = "${baseUrl}terms-of-condition";
  static const referralAmount = "${baseUrl}get-referral";

  //Parcel API
  static const getParcelCategory = "${baseUrl}get-parcel-category";
  static const bookParcel = "${baseUrl}parcel-register";
  static const parcelReject = "${baseUrl}parcel-rejected";
  static const parcelCanceled = "${baseUrl}parcel-canceled";
  static const getParcel = "${baseUrl}get-user-parcel-orders";
  static const parcelPayByWallet = "${baseUrl}parcel-pay-requete-wallet";
  static const parcelPayByCase = "${baseUrl}parcel-payment-by-cash";
  static const parcelPaymentRequest = "${baseUrl}parcel-payment-requete";
  static const getParcelDetails = "${baseUrl}get-parcel-detail";
  // static const getBannerAdvertisement = "${baseUrl}banner_advertisement";
  static const driverDetailById = "${baseUrl}driver/by/id";
  static const CancelRequest = "${baseUrl}set-rejected-requete-by-customer";

//  Rental Module

  static const getRidePackagesData = "${baseUrl}rental-packages";
  static const getVehiclesByPackage = "${baseUrl}vehicles-by-package";
  // static const requestRegisterRentalBooking = "${baseUrl}requete-register-rental";
  // static const saveAddressDetails = "${baseUrl}save-address-details";
  // static const addressDetails = "${baseUrl}address-details";

  // seat sharing
  static const searchRideList = "${baseUrl}get-ride-list";
  static const seatSharingRideDetails = "${baseUrl}driver-ride-detail";
  static const bookSeats = "${baseUrl}book-ride";
  static const myRidesList = "${baseUrl}get-user-ride-list";

  // CUSTOM RENTAL BOOKING
  static const getCustomRentalVehicles = "${baseUrl}getCustomRentalVehicles";
  static const rentalCalculate = "${baseUrl}rental/calculate";
  static const initiateCustomRentalRefund = "${baseUrl}initiateCustomRentalRefund";
  static const addExtraTimeToCustomRental = "${baseUrl}addExtraTimeToCustomRental";
  static const updateCustomRentalStatus = "${baseUrl}updateCustomRentalStatus";


  /// Booking Api
  static const bookRides = "${baseUrl}requete-register-v2";
  static const rentalBooking = "${baseUrl}rental-booking";
  static const requestRegisterRentalBooking = "${baseUrl}requete-register-rental-new";



}
