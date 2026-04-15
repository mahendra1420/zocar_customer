import 'dart:io';

import 'package:zocar/constant/constant.dart';
import 'package:zocar/helpers/size_ext.dart';
import 'package:zocar/themes/constant_colors.dart';
import 'package:flutter/material.dart';
import '../strings.dart';
import '../url_launcher_helper.dart';

class UpdateScreen extends StatefulWidget {
  UpdateScreen({super.key});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 5.h),
          Container(
            height: 35.h,
            padding: EdgeInsets.all(1.h),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              // borderRadius: BorderRadius.circular(17),
              image: DecorationImage(
                image: AssetImage('assets/images/appIcon.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  S.newUpdateAvailable,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize:  5.2.sp,
                    letterSpacing: 0.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Text(
                    S.weveMadeAppEvenBetterDesc,
                    style: TextStyle(
                      fontSize: 4.7.sp,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 3.h),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: ConstantColors.yellow),
                    onPressed: () async {
                      if (Platform.isAndroid) {
                        UrlLauncher.launchNetworkUrl(Constant.playStoreUrl);
                      }
                    },
                    child: Center(
                      child: Text(
                        S.updateNow,
                        style: TextStyle(
                          fontSize: 4.7.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
