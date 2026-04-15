// ignore_for_file: file_names

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:zocar/service/api.dart';

import '../model/ride_settings_model.dart';

class Preferences {
  static const isFinishOnBoardingKey = "isFinishOnBoardingKey";
  static const languageCodeKey = "languageCodeKey";
  static const isLogin = "isLogin";
  static const userId = "userId";
  static const user = "userData";
  static const paymentSetting = "paymentSetting";
  static const driverRadius = "driverRadius";
  static const contactUsAddress = "contactUsAddress";
  static const contactUsPhone = "contactUsPhone";
  static const contactUsEmail = "contactUsEmail";
  static const currency = "currency";
  static const deliverChargeParcel = "deliverChargeParcel";
  static const parcelPerWeightCharge = "parcelPerWeightCharge";
  static const accesstoken = "accesstoken";
  static const admincommission = "adminCommission";
  static const adminCommissionType = "adminCommissionType";
  static const rideSettingsKey = "rideSettings";
  // static const initialPaymentPercentage = "initialPaymentPercentage";

  static late SharedPreferences pref;

  static initPref() async {
    pref = await SharedPreferences.getInstance();
  }

  // Existing methods - kept for backward compatibility
  static bool getBoolean(String key) {
    return pref.getBool(key) ?? false;
  }

  static Future<void> setBoolean(String key, bool value) async {
    await pref.setBool(key, value);
  }

  static String getString(String key) {
    return pref.getString(key) ?? "";
  }

  static Future<void> setString(String key, String value) async {
    await pref.setString(key, value);
  }

  static int getInt(String key) {
    return pref.getInt(key) ?? 0;
  }

  static Future<void> setInt(String key, int value) async {
    await pref.setInt(key, value);
  }

  static Future<void> clearSharPreference() async {
    await pref.clear();
  }

  static Future<void> clearKeyData(String key) async {
    await pref.remove(key);
  }

  // static int getInitialPaymentPercentage() {
  //   return pref.getInt(initialPaymentPercentage) ?? 0;
  // }
  //
  // static Future<void> setInitialPaymentPercentage(int value) async {
  //   await pref.setInt(initialPaymentPercentage, value);
  // }

  // New methods with default values support - for Constant class
  static bool getBool(String key, {bool defaultValue = false}) {
    return pref.getBool(key) ?? defaultValue;
  }

  static Future<bool> setBool(String key, bool value) async {
    return await pref.setBool(key, value);
  }

  static double getDouble(String key, {double defaultValue = 0.0}) {
    return pref.getDouble(key) ?? defaultValue;
  }

  static Future<bool> setDouble(String key, double value) async {
    return await pref.setDouble(key, value);
  }

  // Check if key exists
  static bool containsKey(String key) {
    return pref.containsKey(key);
  }

  /// ---------- RIDE SETTINGS ----------
  static Future<void> setRideSettings(RideSettings model) async {
    final jsonString = jsonEncode(model.toJson());
    await pref.setString(rideSettingsKey, jsonString);
  }

  static RideSettings? get rideSettings {
    final jsonString = pref.getString(rideSettingsKey);

    if (jsonString == null || jsonString.isEmpty) return null;

    try {
      final Map<String, dynamic> jsonMap = json.safeDecode(jsonString);
      return RideSettings.fromJson(jsonMap);
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearRideSettings() async {
    await pref.remove(rideSettingsKey);
  }
}