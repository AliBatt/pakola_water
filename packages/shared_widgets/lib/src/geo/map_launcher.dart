import 'package:models/models.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens Google Maps at [location] (external app when available).
Future<bool> openInGoogleMaps(
  GeoLocation location, {
  String? label,
}) async {
  final query = label != null && label.trim().isNotEmpty
      ? Uri.encodeComponent(
          '${location.latitude},${location.longitude} (${label.trim()})',
        )
      : '${location.latitude},${location.longitude}';

  final webUri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$query',
  );

  // Prefer Google Maps app scheme on mobile when installed.
  final appUri = Uri.parse(
    'comgooglemaps://?q=${location.latitude},${location.longitude}',
  );

  if (await canLaunchUrl(appUri)) {
    return launchUrl(appUri, mode: LaunchMode.externalApplication);
  }
  if (await canLaunchUrl(webUri)) {
    return launchUrl(webUri, mode: LaunchMode.externalApplication);
  }
  return false;
}
