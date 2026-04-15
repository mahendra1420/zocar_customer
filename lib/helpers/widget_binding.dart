import 'package:flutter/widgets.dart';

typedef Framecallback = void Function(Duration _);

void widgetBinding(Framecallback callback) {
  WidgetsBinding.instance.addPostFrameCallback(callback);
}
