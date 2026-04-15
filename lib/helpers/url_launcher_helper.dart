import 'package:url_launcher/url_launcher.dart';

import 'devlog.dart';


class UrlLauncher {
  static Future<bool> launchNetworkUrl(String? url, {String prefix = "+91"}) async {
    bool success = false;
    try {
      if (url == null) throw "Url not found!";
      final Uri uri = Uri.parse(url);
      try {
        success = await launchUrl(uri);
      } catch (e) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      devlogError("Error while launching url $url: $e");
    }
    return success;
  }

  static Future<bool> launchMobile(String? mobile, {String prefix = ""}) async {
    bool success = false;
    final phoneNumber = prefix + (mobile ?? "");
    try {
      if (mobile == null) throw "Mobile number not found!";
      final Uri phoneUri = Uri.parse('tel:$phoneNumber');
      if (await canLaunchUrl(phoneUri)) {
        success = await launchUrl(phoneUri);
      } else {
        throw 'Could not launch $phoneNumber';
      }
    } catch (e) {
      devlogError("Error while launching mobile number $phoneNumber: $e");
    }
    return success;
  }

  static Future<bool> launchEmail({required String? email, String subject = "", String body = ""}) async {
    bool success = false;
    try {
      if (email == null || email.isEmpty) throw "Email not provided!";
      final Uri emailUri = Uri(scheme: 'mailto', path: email, queryParameters: {
        'subject': subject,
        'body': body,
      });
      if (await canLaunchUrl(emailUri)) {
        success = await launchUrl(emailUri);
      } else {
        throw 'Could not launch $email';
      }
    } catch (e) {
      devlogError("Error while launching email $email: $e");
    }
    return success;
  }
}
