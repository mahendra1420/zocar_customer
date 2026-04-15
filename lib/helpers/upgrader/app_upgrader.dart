import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';
import 'package:zocar/helpers/devlog.dart';
import 'package:zocar/helpers/upgrader/update_app_screen.dart';
import 'package:zocar/helpers/upgrader/version_check_response.dart';
import 'package:zocar/helpers/url_launcher_helper.dart';
import 'package:zocar/service/api.dart';
import 'package:zocar/themes/constant_colors.dart';

import '../../constant/constant.dart';

enum UpdateDialogType { fullScreen, alert }

class AppUpgrader {
  const AppUpgrader._();

  static Future<VersionCheckResponse?> fetchLatestVersionInfo({bool isForTest = false}) async {
    if (isForTest) {
      await Future.delayed(const Duration(seconds: 1));
      return VersionCheckResponse(status: true, type: Constant.appType, androidVersion: "1.0.16", iosVersion: "");
    }
    try {
      final dio = Dio(BaseOptions(headers: API.header));
      final response = await dio.get(API.versionCheck, queryParameters: {'type': Constant.appType});
      if (response.statusCode != 200) {
        devlog("FAILED TO FETCH LATEST VERSION INFO");
        return null;
      }

      final resData = (response.data);
      if (resData == null) {
        devlog("EMPTY RESPONSE BODY WHILE FETCHING LATEST VERSION INFO");
        return null;
      }
      devlog("LATEST VERSION INFO RESPONSE : $resData");
      final versionCheckRes = VersionCheckResponse.fromJson(resData);
      return versionCheckRes;
    } catch (e) {
      devlog("ERROR FETCHING LATEST VERSION INFO: $e");
      return null;
    }
  }

  static Future<bool> checkUpdate(BuildContext context, {UpdateDialogType dialogType = UpdateDialogType.fullScreen}) async {
    bool isUpdateAvailable = false;
    try {
      final info = await PackageInfo.fromPlatform();
      final isIOS = Platform.isIOS;
      final Version currentVersion = Version.parse(info.version);
      devlog("CURRENT VERSION : $currentVersion");

      final versionCheckRes = await fetchLatestVersionInfo();
      if (versionCheckRes == null) {
        devlog("VERSION CHECK RESPONSE IS NULL");
        return false;
      }

      final Version latestVersion = Version.parse(isIOS ? versionCheckRes.iosVersion : versionCheckRes.androidVersion);
      devlog("LATEST VERSION FROM SERVER : $latestVersion");
      isUpdateAvailable = currentVersion < latestVersion;
    } catch (e) {
      devlog("ERROR CHECKING FOR UPDATE: $e");
    } finally {
      if (isUpdateAvailable) {
        if (dialogType == UpdateDialogType.fullScreen) {
          showFullScreenUpdateDialog(context);
        } else {
          showAlertUpdateDialog(context);
        }
      }
      return isUpdateAvailable;
    }
  }

  static void showFullScreenUpdateDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return PopScope(canPop: false, child: UpdateScreen());
        });
  }

  static void showAlertUpdateDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
              title: Text(
                "Update Available.!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.start,
              ),
              content: Text(
                "A new version of ${Constant.appName} is available",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.start,
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      if (Platform.isAndroid) {
                        UrlLauncher.launchNetworkUrl(Constant.playStoreUrl);
                      } else {
                        UrlLauncher.launchNetworkUrl(Constant.iosUrl);
                      }
                    },
                    child: Text(
                      "Update Now",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: ConstantColors.primary,
                      ),
                    ))
              ],
            ),
          );
        });
  }
}
