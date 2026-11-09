import 'package:latlong2/latlong.dart';
import '../../features/listings/models/property.dart';

/// Approximate coordinates for the map. Precise enough to show which
/// homes are around which campus.
class Geo {
  static const tunisCenter = LatLng(36.8065, 10.1815);

  /// Homes within this distance are shown around a selected university.
  static const nearbyRadiusKm = 3.0;

  static const universities = <String, LatLng>{
    'Université de Tunis El Manar': LatLng(36.8380, 10.1460),
    'Université de Carthage': LatLng(36.8525, 10.3233),
    'Université de la Manouba': LatLng(36.8130, 10.0670),
    'Université de Sousse': LatLng(35.8256, 10.5930),
    'Université de Sfax': LatLng(34.7400, 10.7500),
    'Université de Monastir': LatLng(35.7680, 10.8180),
    'Université de Gabès': LatLng(33.8880, 10.0980),
    'Université de Kairouan': LatLng(35.6760, 10.0960),
    'INSAT': LatLng(36.8430, 10.1970),
    'ENIT': LatLng(36.8320, 10.1470),
    'ESPRIT': LatLng(36.8990, 10.1890),
    'IHEC Carthage': LatLng(36.8600, 10.3300),
  };

  static const cities = <String, LatLng>{
    'Tunis': LatLng(36.8065, 10.1815),
    'Ariana': LatLng(36.8625, 10.1956),
    'Ben Arous': LatLng(36.7531, 10.2189),
    'La Manouba': LatLng(36.8101, 10.0863),
    'Sousse': LatLng(35.8256, 10.6360),
    'Sfax': LatLng(34.7406, 10.7603),
    'Monastir': LatLng(35.7643, 10.8113),
    'Nabeul': LatLng(36.4561, 10.7376),
    'Bizerte': LatLng(37.2744, 9.8739),
    'Gabès': LatLng(33.8815, 10.0982),
    'Kairouan': LatLng(35.6781, 10.0963),
    'Mahdia': LatLng(35.5047, 11.0622),
  };

  static const _distance = Distance();

  static double km(LatLng a, LatLng b) =>
      _distance.as(LengthUnit.Meter, a, b) / 1000;

  static String formatKm(double km) => km < 1
      ? '${(km * 1000).round()} m'
      : '${km.toStringAsFixed(1).replaceAll('.', ',')} km';

  /// Where to draw a listing. Older listings without coordinates are placed
  /// near their university (or city) with a small stable offset so pins
  /// don't stack on top of each other.
  static LatLng positionOf(Property p) {
    if (p.lat != null && p.lng != null) return LatLng(p.lat!, p.lng!);
    final base =
        universities[p.university] ?? cities[p.city] ?? tunisCenter;
    final h = p.id.hashCode;
    final dLat = ((h % 1000) / 1000 - 0.5) * 0.02;
    final dLng = (((h ~/ 1000) % 1000) / 1000 - 0.5) * 0.02;
    return LatLng(base.latitude + dLat, base.longitude + dLng);
  }

  static (String, double)? nearestUniversity(LatLng point) {
    (String, double)? best;
    for (final e in universities.entries) {
      final d = km(point, e.value);
      if (best == null || d < best.$2) best = (e.key, d);
    }
    return best;
  }
}
