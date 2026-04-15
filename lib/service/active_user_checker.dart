import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:zocar/constant/show_toast_dialog.dart';
import 'package:zocar/helpers/widget_binding.dart';
import 'package:zocar/service/api.dart';
import 'package:zocar/utils/preferences.dart';

import '../page/auth_screens/login_screen.dart';

class ActiveChecker {
  static Future<bool> check() async {
    Get.log('[ActiveChecker] Status check started');

    try {
      final userId = await Preferences.getInt(Preferences.userId).toString();

      if (userId.isEmpty || userId == "null") {
        Get.log('[ActiveChecker] userId not found in preferences');
        _handleInactiveUser(reason: 'Missing user session');
        return false;
      }

      Get.log('[ActiveChecker] Checking status for userId=$userId');

      final res = await LoggingClient(http.Client()).get(Uri.parse("${API.userStatus}?user_id=$userId"), headers: API.header);

      final response = json.safeDecode(res.body);

      Get.log('[ActiveChecker] API Response: status=${res.statusCode}, data=${response}');

      if (res.statusCode == 200 && response != null) {
        final bool isActive = response['active'] == true;

        if (!isActive) {
          Get.log('[ActiveChecker] User is inactive');
          _handleInactiveUser(reason: 'Account inactive');
          return false;
        }

        Get.log('[ActiveChecker] User is active');
        return true;
      }

      if (res.statusCode == 429) {
        showToast('Too many requests. Please wait a moment and try again.');
        Get.log('[ActiveChecker] HTTP 429 – Too many requests sent to the server.');
        return false;
      }
      Get.log('[ActiveChecker] Invalid response from server');
      _handleInactiveUser(reason: 'Invalid server response');
      return false;
    } catch (e, stack) {
      Get.log(
        '[ActiveChecker] Exception occurred: $e',
        isError: true,
      );
      Get.log(stack.toString(), isError: true);

      _handleInactiveUser(reason: 'Network or server error');
      return false;
    }
  }

  /// Clears session and redirects to Login
  static void _handleInactiveUser({required String reason}) {
    Get.log('[ActiveChecker] Handling inactive user. Reason: $reason');

    try {
      Preferences.clearKeyData(Preferences.isLogin);
      Preferences.clearKeyData(Preferences.user);
      Preferences.clearKeyData(Preferences.userId);
      Preferences.clearKeyData(Preferences.accesstoken);
      // Preferences.clearKeyData(Preferences.initialPaymentPercentage);

      Get.log('[ActiveChecker] User session cleared');
    } catch (e) {
      Get.log(
        '[ActiveChecker] Error while clearing session: $e',
        isError: true,
      );
    }

    widgetBinding((_) {
      showToast('Your session has expired. Please log in again.');

      Get.offAll(() => LoginScreen());
    });
  }
}
