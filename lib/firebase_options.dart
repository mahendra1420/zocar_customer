// File generated manually from google-services.json
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web is not configured.');
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return androidUser;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions androidUser = FirebaseOptions(
    apiKey: 'AIzaSyBg15FOaaTAwokMMWbigYIxfGpfm9AhpKM',
    appId: '1:1069212466932:android:314218d61bdb8020eee8a1',
    messagingSenderId: '1069212466932',
    projectId: 'zocar-d2893',
    storageBucket: 'zocar-d2893.firebasestorage.app',
  );
}
