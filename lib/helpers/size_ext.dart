import 'package:get/get.dart';

extension SizeExt on num {
  double get h => Get.height * (this / 100);
  double get w => Get.width * (this / 100);

  /// Responsive text size
  double get sp {
    final shortestSide = Get.width < Get.height
        ? Get.width
        : Get.height;

    return shortestSide * (this / 100);
  }
}
