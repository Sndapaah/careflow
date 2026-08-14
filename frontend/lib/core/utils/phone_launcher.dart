import 'package:url_launcher/url_launcher.dart';

class PhoneLauncher {
  static Future<void> call(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber.replaceAll(' ', ''));
    await launchUrl(uri);
  }
}
