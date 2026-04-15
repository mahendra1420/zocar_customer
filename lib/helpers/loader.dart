import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'devlog.dart';

class LoaderService {
  static LoaderService? _instance;
  static LoaderService get instance => _instance ??= LoaderService._();

  LoaderService._();

  bool _isLoading = false;
  BuildContext? _loaderContext;
  Timer? _timeoutTimer;

  bool get isLoading => _isLoading;

  void show({
    BuildContext? context,
    String? message,
    Duration timeout = const Duration(minutes: 2),
    bool barrierDismissible = false,
  }) {
    if (_isLoading) return;

    final ctx = context ?? Get.context;
    if (ctx == null) {
      devlogError("LoaderService: No context available");
      return;
    }

    _isLoading = true;

    showDialog(
      context: ctx,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black45,
      builder: (BuildContext dialogContext) {
        _loaderContext = dialogContext;
        return PopScope(
          canPop: false,
          child: BasicLoader(message: message),
        );
      },
    );

    _timeoutTimer = Timer(timeout, () {
      devlogError("LoaderService: Auto-hiding loader after timeout");
      hide();
    });
  }

  void hide() {
    if (!_isLoading) return;

    try {
      _timeoutTimer?.cancel();
      _timeoutTimer = null;

      if (_loaderContext != null && _loaderContext!.mounted) {
        Navigator.of(_loaderContext!).pop();
      }
    } catch (e) {
      devlogError("LoaderService: Error hiding loader - $e");
    } finally {
      _isLoading = false;
      _loaderContext = null;
    }
  }

  void forceHide() {
    try {
      _timeoutTimer?.cancel();
      _timeoutTimer = null;

      if (_loaderContext != null) {
        Navigator.of(_loaderContext!, rootNavigator: true).pop();
      }
    } catch (e) {
      devlogError("LoaderService: Error force hiding loader - $e");
    } finally {
      _isLoading = false;
      _loaderContext = null;
    }
  }
}

class BasicLoader extends StatelessWidget {
  final String? message;

  const BasicLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoActivityIndicator(
                radius: 18,
                color: Colors.indigo,
              ),
              if (message != null) ...[
                SizedBox(height: 16),
                Text(
                  message!,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

// Simple usage functions
void showLoader(BuildContext? context, {String? message, Duration? timeout}) {
  LoaderService.instance.show(
    context: context,
    message: message,
    timeout: timeout ?? const Duration(seconds: 30),
  );
}

void hideLoader() {
  LoaderService.instance.hide();
}

void forceHideLoader() {
  LoaderService.instance.forceHide();
}

bool get isLoaderVisible => LoaderService.instance.isLoading;

void showLoaderWithMessage(String message, {BuildContext? context}) {
  showLoader(context, message: message);
}

void showQuickLoader({BuildContext? context}) {
  showLoader(context, timeout: const Duration(seconds: 10));
}


// //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// //               CREATED BY NAYAN PARMAR
// //                      © 2025
// //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// import 'package:layer_kit/core/utils/devlog.dart';
// import 'package:layer_kit/layer_kit.dart';
// import 'package:fastest_delivery/core/constants/color_constants.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// BuildContext? c;
//
// showLoader(context) {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (BuildContext context) {
//       c = AppRouter.context;
//       return const LoaderPage();
//     },
//   );
// }
//
// hideLoader() {
//   try {
//     Navigator.pop(c ?? AppRouter.context);
//   } catch (e) {
//     devlogError("error in hide loader : $e");
//   }
// }
//
// class LoaderPage extends StatelessWidget {
//   const LoaderPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       onPopInvokedWithResult: (didPop, r) {
//         return;
//       },
//       child: Material(
//         color: Colors.grey.withOpacity(0.2),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             ClipRRect(
//               borderRadius: BorderRadius.all(Radius.circular(4.w)),
//               child: Container(
//                 margin: const EdgeInsets.all(20),
//                 padding: const EdgeInsets.all(10),
//                 decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(
//                           color: Colors.grey,
//                           blurRadius: 10,
//                           offset: Offset(1, 1))
//                     ]),
//                 child: Column(
//                   children: <Widget>[
//                     CupertinoActivityIndicator(
//                         color: AppColors.primary, radius: 20),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
