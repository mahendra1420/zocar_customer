
import 'package:flutter/material.dart';

import '../../constant/constant.dart';
import '../../themes/constant_colors.dart';

class ZocarLogoWidget extends StatelessWidget {
  const ZocarLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "kImgZocar",
      child: Container(
        width: 140,
        height: 70,
        padding: const EdgeInsets.all(10),
        color: Colors.transparent,
        // decoration: BoxDecoration(
        //   color: Colors.white.withOpacity(0.9),
        //   borderRadius: BorderRadius.circular(80),
        //   boxShadow: [
        //     BoxShadow(
        //       color: ConstantColors.primary.withOpacity(0.1),
        //       blurRadius: 20,
        //       offset: const Offset(0, 5),
        //     ),
        //   ],
        //
        // ),


        child: Image.asset(
          kImgZocar,
          // width: 120,
          // color: ConstantColors.primary,
        ),
      ),
    );
  }
}
