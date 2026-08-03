import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:models/models.dart';

/// True when [address] is empty or only a "Lat …, Lng …" placeholder.
bool isCoordinateOnlyAddress(String? address) {
  final trimmed = address?.trim() ?? '';
  if (trimmed.isEmpty) return true;
  return RegExp(
    r'^Lat\s+-?\d+(\.\d+)?\s*,\s*Lng\s+-?\d+(\.\d+)?$',
    caseSensitive: false,
  ).hasMatch(trimmed);
}

/// Resolves a human-readable address via OpenStreetMap Nominatim.
Future<String?> reverseGeocode(
  GeoLocation location, {
  String userAgent = 'PakolaWaters/1.0 (reverse-geocode)',
}) async {
  try {
    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/reverse',
      {
        'lat': location.latitude.toString(),
        'lon': location.longitude.toString(),
        'format': 'json',
        'zoom': '18',
        'addressdetails': '1',
      },
    );
    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'User-Agent': userAgent,
      },
    );
    if (response.statusCode != 200) return null;
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return null;
    final name = decoded['display_name'] as String?;
    final trimmed = name?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  } catch (_) {
    return null;
  }
}
