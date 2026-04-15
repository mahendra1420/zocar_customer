import 'package:flutter/cupertino.dart';

import '../constant/constant.dart';

class AppBg extends StatelessWidget {
  const AppBg({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(image: DecorationImage(image: AssetImage(kImgWhiteBg), fit: BoxFit.cover)),
      child: child,
    );
  }
}
