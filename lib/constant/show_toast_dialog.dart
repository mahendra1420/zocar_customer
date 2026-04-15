import 'package:flutter_easyloading/flutter_easyloading.dart';

Future showToast(String? message, {EasyLoadingToastPosition position = EasyLoadingToastPosition.top}) async {
  try {
    await EasyLoading.showToast(message!, toastPosition: position);
  } catch (e) {}
}

// Future showLoader(String message) async {
//   try {
//     await EasyLoading.show(status: message);
//   } catch (e) {}
// }
//
// Future hideLoader() async {
//   try {
//     await EasyLoading.dismiss();
//   } catch (e) {}
// }

class ShowToastDialog {
  static showToast(String? message, {EasyLoadingToastPosition position = EasyLoadingToastPosition.top}) {
    try {
      EasyLoading.showToast(message!, toastPosition: position);
    } catch (e) {}
  }

  static showLoader(String message) async {
    try {
      await EasyLoading.show(status: message);
    } catch (e) {}
  }

  static closeLoader() async {
    try {
      await EasyLoading.dismiss();
    } catch (e) {}
  }
}
