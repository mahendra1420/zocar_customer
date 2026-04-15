import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PolylineCacheHelper {
  const PolylineCacheHelper._();

  static Future<void> saveEncodedRoute(String key, String encoded) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, encoded);
  }

  static Future<String?> getEncodedRoute(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static String encodePolyline(List<LatLng> points) {
    var encoded = '';
    int lastLat = 0;
    int lastLng = 0;

    for (final point in points) {
      int lat = (point.latitude * 1e5).round();
      int lng = (point.longitude * 1e5).round();

      encoded += _encodeValue(lat - lastLat);
      encoded += _encodeValue(lng - lastLng);

      lastLat = lat;
      lastLng = lng;
    }

    return encoded;
  }

  static String _encodeValue(int value) {
    value = value < 0 ? ~(value << 1) : (value << 1);
    var output = '';

    while (value >= 0x20) {
      output += String.fromCharCode((0x20 | (value & 0x1f)) + 63);
      value >>= 5;
    }

    output += String.fromCharCode(value + 63);
    return output;
  }

  static List<LatLng> decodePolyline(String encoded) {
    return PolylinePoints().decodePolyline(encoded).map((e) => LatLng(e.latitude, e.longitude)).toList();
  }
}
