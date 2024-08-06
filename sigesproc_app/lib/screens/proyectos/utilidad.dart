import 'package:url_launcher/url_launcher_string.dart';

class MapUtils {
  MapUtils._();

  static Future<void> openMapWithPosition(double latitude, double longitude) async {
    String googleMapUrl = "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";

    if (await canLaunchUrlString(googleMapUrl)) {
      await launchUrlString(googleMapUrl, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not open map.";
    }
  }

  static Future<void> openMapWithAddress(String completeAddress) async {
    String query = Uri.encodeComponent(completeAddress);
    String googleMapUrl = "https://www.google.com/maps/search/?api=1&query=$query";

    if (await canLaunchUrlString(googleMapUrl)) {
      await launchUrlString(googleMapUrl, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not open map.";
    }
  }
}
