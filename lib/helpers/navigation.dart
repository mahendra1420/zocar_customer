import 'package:flutter/cupertino.dart';

extension NavigationExt on BuildContext {
  void push(Widget screen, {String? name}) {
    Navigator.push(
      this,
      PageRouteBuilder(
        settings: RouteSettings(name: name),
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: screen,
        ),
      ),
    );
  }
}
