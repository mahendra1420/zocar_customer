import 'package:flutter/cupertino.dart';

unfocusAll() {
  FocusManager.instance.primaryFocus?.unfocus();
}