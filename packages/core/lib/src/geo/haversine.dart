import 'dart:math' as math;

/// Great-circle distance in kilometers between two lat/lng points.
double haversineKm({
  required double lat1,
  required double lng1,
  required double lat2,
  required double lng2,
}) {
  const earthRadiusKm = 6371.0;
  final dLat = _toRadians(lat2 - lat1);
  final dLng = _toRadians(lng2 - lng1);
  final rLat1 = _toRadians(lat1);
  final rLat2 = _toRadians(lat2);

  final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(rLat1) *
          math.cos(rLat2) *
          math.sin(dLng / 2) *
          math.sin(dLng / 2);
  return 2 * earthRadiusKm * math.asin(math.min(1, math.sqrt(h)));
}

double _toRadians(double degrees) => degrees * math.pi / 180;
