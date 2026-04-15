// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/constant.dart';
import '../helpers/url_launcher_helper.dart';
import '../page/auth_screens/login_screen.dart';
import '../utils/preferences.dart';

Future<void> openAppStore() async {
  final String shareUrl = Constant.playStoreUrl;

  try {
    await UrlLauncher.launchNetworkUrl(shareUrl);
  } catch (e) {}
}

void showLogoutDialog() {
  Get.dialog(
    AlertDialog(
      title: Text('Logout'),
      content: Text('Are you sure you want to Sign out?'),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('No'),
        ),
        TextButton(
          onPressed: () {
            try {
              Preferences.clearKeyData(Preferences.isLogin);
              Preferences.clearKeyData(Preferences.user);
              Preferences.clearKeyData(Preferences.userId);
              Preferences.clearKeyData(Preferences.accesstoken);
              // Preferences.clearKeyData(Preferences.initialPaymentPercentage);
            } catch (e) {}
            Get.offAll(() => LoginScreen());
          },
          child: Text('Yes'),
        ),
      ],
    ),
  );
}
Widget buildModernButton({
  required BuildContext context,
  required String label,
  required IconData? icon,
  required Color bgColor,
  Color textColor = Colors.white,
  Color? borderColor,
  required VoidCallback onPressed,
}) {
  return Container(
    height: 48,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      boxShadow: borderColor == null
          ? [
        BoxShadow(
          color: bgColor.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ]
          : null,
    ),
    child: ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon == null  ? null : Icon(icon, size: 18),
      label: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: borderColor != null ? BorderSide(color: borderColor, width: 1.5) : BorderSide.none,
        ),
      ),
    ),
  );
}