//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//               CREATED BY NAYAN PARMAR
//                      © 2025
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import 'dart:developer' as dev;

enum EnvType {
  debug,
  release,
  production,
  ;

  bool get isDebug => this == EnvType.debug;
  bool get isRelease => this == EnvType.release;
  bool get isProduction => this == EnvType.production;
}

class GlobalConfig {
  GlobalConfig._();

  static const EnvType envType = EnvType.production;
  static const bool showDevLog = true;
  static const bool showDevErrorLog = true;
  static const bool removeTryCatch = false;
}

String _truncateData(String data, int? limit) {
  String dataString = data.toString();
  if (limit == null) return dataString;
  return dataString.length > limit ? '${dataString.substring(0, limit)}...' : dataString;
}

void devlog(String msg, {String? name, int? limit}) {
  if (GlobalConfig.showDevLog) {
    dev.log("👉 👉 👉 ${_truncateData(msg, limit)}", name: name ?? " LOG ");
    if (GlobalConfig.envType.isRelease) print("[${name ?? " LOG "}] 👉 👉 👉 ${_truncateData(msg, limit)}");
  }
}

void devlogError(String error) {
  if (GlobalConfig.showDevErrorLog) {
    dev.log("❌ ==> ==> * $error", name: " ERROR ");
    if (GlobalConfig.envType.isRelease) print("[ ERROR ] ❌ ==> ==> * $error");
  }
}

void devlogApi(String msg) {
  dev.log(" == == == >>> $msg", name: "[ API LOG ]");
  if (GlobalConfig.envType.isRelease) print("[ API LOG ] == == == >>> $msg");
}
