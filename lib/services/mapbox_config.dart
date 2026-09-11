import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration and helper utilities for Mapbox API and map rendering.
class MapboxConfig {
  /// Default Mapbox Public Access Token loaded securely from .env file.
  static String get defaultAccessToken {
    return dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
  }

  /// In-memory cache of ImageProviders to ensure instant reuse without reload flicker.
  static final Map<String, ImageProvider> _imageProviderCache = {};

  /// Retrieves or caches a NetworkImage provider for the given URL.
  static ImageProvider getCachedImageProvider(String url) {
    return _imageProviderCache.putIfAbsent(url, () => NetworkImage(url));
  }

  /// Precaches a map URL into Flutter's image cache safely with offline fallback handling.
  static Future<void> precacheUrl(BuildContext context, String url) async {
    try {
      final provider = getCachedImageProvider(url);
      await precacheImage(
        provider,
        context,
        onError: (exception, stackTrace) {
          // Gracefully handled for offline/no-DNS environments
        },
      );
    } catch (_) {}
  }

  /// Pre-caches all standard day maps (Days 1 to 5) when a plan is created/viewed.
  static void precacheTokyoDays(BuildContext context, {String? token}) {
    // Standard coordinates for Day 1 - Day 5
    final dayCoordsList = [
      // Day 1: Omotesando -> Meiji Shrine -> Harajuku -> Afuri -> Shibuya -> teamLab -> Toyosu Stalls
      [
        (lat: 35.6672, lng: 139.7092),
        (lat: 35.6764, lng: 139.6993),
        (lat: 35.6702, lng: 139.7027),
        (lat: 35.6713, lng: 139.7031),
        (lat: 35.6595, lng: 139.7005),
        (lat: 35.6491, lng: 139.7898),
        (lat: 35.6458, lng: 139.7842),
      ],
      // Day 2: Ameyoko -> Ueno Park -> Akihabara -> Jangara Ramen -> Ginza -> Yurakucho Hawker Alley
      [
        (lat: 35.7112, lng: 139.7745),
        (lat: 35.7140, lng: 139.7740),
        (lat: 35.6983, lng: 139.7731),
        (lat: 35.6998, lng: 139.7709),
        (lat: 35.6719, lng: 139.7648),
        (lat: 35.6738, lng: 139.7608),
      ],
      // Day 3: Shibakoen Bakery -> Tokyo Tower -> Roppongi Hills -> Butagumi -> Shinjuku Gyoen -> Omoide Yokocho
      [
        (lat: 35.6565, lng: 139.7490),
        (lat: 35.6586, lng: 139.7454),
        (lat: 35.6605, lng: 139.7292),
        (lat: 35.6602, lng: 139.7298),
        (lat: 35.6852, lng: 139.7101),
        (lat: 35.6932, lng: 139.6998),
      ],
      // Day 4: Tsukiji Market -> Odaiba Seaside -> Takoyaki Museum -> Senso-ji -> Skytree -> Hoppy Street
      [
        (lat: 35.6655, lng: 139.7708),
        (lat: 35.6298, lng: 139.7753),
        (lat: 35.6288, lng: 139.7760),
        (lat: 35.7148, lng: 139.7967),
        (lat: 35.7100, lng: 139.8107),
        (lat: 35.7135, lng: 139.7942),
      ],
      // Day 5: Fuglen Cafe -> Nakano Broadway -> Uobei Sushi -> Shibuya Sky -> Tokyo Station -> Ramen Street
      [
        (lat: 35.6648, lng: 139.6925),
        (lat: 35.7090, lng: 139.6657),
        (lat: 35.6598, lng: 139.6975),
        (lat: 35.6585, lng: 139.7013),
        (lat: 35.6812, lng: 139.7671),
        (lat: 35.6808, lng: 139.7682),
      ],
    ];

    for (final coords in dayCoordsList) {
      final bounds = computeOptimalBounds(
        coordinates: coords,
        viewportWidth: 350.0,
        viewportHeight: 280.0,
        horizontalPadding: 45.0,
        verticalPadding: 32.0,
      );

      final mapboxUrl = buildMapboxStaticUrl(
        centerLat: bounds.centerLat,
        centerLng: bounds.centerLng,
        zoom: bounds.zoom,
        width: 800,
        height: 500,
        token: token,
      );

      final fallbackUrl = buildRealMapFallbackUrl(
        centerLat: bounds.centerLat,
        centerLng: bounds.centerLng,
        zoom: bounds.zoom,
        width: 800,
        height: 500,
      );

      precacheUrl(context, mapboxUrl);
      precacheUrl(context, fallbackUrl);
    }
  }

  /// Standard Mapbox street style
  static const String streetStyle = 'mapbox/streets-v12';

  /// Clean light style matching Travelyn's warm aesthetic
  static const String lightStyle = 'mapbox/light-v11';

  /// Builds a real Mapbox Static Images API URL.
  /// Documentation: https://docs.mapbox.com/api/maps/static-images/
  static String buildMapboxStaticUrl({
    required double centerLat,
    required double centerLng,
    required double zoom,
    int width = 800,
    int height = 550,
    String? token,
    String style = streetStyle,
  }) {
    final activeToken = (token != null && token.trim().isNotEmpty)
        ? token.trim()
        : defaultAccessToken.trim();

    return 'https://api.mapbox.com/styles/v1/$style/static/'
        '${centerLng.toStringAsFixed(5)},${centerLat.toStringAsFixed(5)},${zoom.toStringAsFixed(2)},0,0/'
        '${width}x$height@2x?access_token=$activeToken';
  }

  /// High-reliability public real street map fallback URL (OpenStreetMap / Esri World Street Map)
  /// in case Mapbox API token is unauthorized or network has restricted access.
  static String buildRealMapFallbackUrl({
    required double centerLat,
    required double centerLng,
    required double zoom,
    int width = 800,
    int height = 550,
  }) {
    // OpenStreetMap standard static render fallback
    final z = zoom.round().clamp(10, 18);
    return 'https://staticmap.openstreetmap.de/staticmap.php?'
        'center=${centerLat.toStringAsFixed(5)},${centerLng.toStringAsFixed(5)}'
        '&zoom=$z&size=${width}x$height&maptype=mapnik';
  }

  /// Calculates Web Mercator pixel coordinates for a given (lat, lng) relative to
  /// a map viewport centered at (centerLat, centerLng) with given zoom and dimensions.
  static Offset latLngToViewportPoint({
    required double lat,
    required double lng,
    required double centerLat,
    required double centerLng,
    required double zoom,
    required double viewportWidth,
    required double viewportHeight,
  }) {
    final scale = 256.0 * math.pow(2.0, zoom);

    double x(double lon) => (lon + 180.0) / 360.0 * scale;

    double y(double latitude) {
      final sinLat = math.sin(latitude * math.pi / 180.0).clamp(-0.9999, 0.9999);
      return (0.5 - math.log((1.0 + sinLat) / (1.0 - sinLat)) / (4.0 * math.pi)) * scale;
    }

    final centerX = x(centerLng);
    final centerY = y(centerLat);

    final px = (viewportWidth / 2.0) + (x(lng) - centerX);
    final py = (viewportHeight / 2.0) + (y(lat) - centerY);

    return Offset(px, py);
  }

  /// Computes optimal center and zoom level so all coordinates fit inside the viewport with padding.
  static ({double centerLat, double centerLng, double zoom}) computeOptimalBounds({
    required List<({double lat, double lng})> coordinates,
    required double viewportWidth,
    required double viewportHeight,
    double horizontalPadding = 48.0,
    double verticalPadding = 36.0,
  }) {
    if (coordinates.isEmpty) {
      return (centerLat: 35.6762, centerLng: 139.7000, zoom: 13.0);
    }
    if (coordinates.length == 1) {
      return (
        centerLat: coordinates.first.lat,
        centerLng: coordinates.first.lng,
        zoom: 14.0,
      );
    }

    double minLat = coordinates.first.lat;
    double maxLat = coordinates.first.lat;
    double minLng = coordinates.first.lng;
    double maxLng = coordinates.first.lng;

    for (final c in coordinates) {
      if (c.lat < minLat) minLat = c.lat;
      if (c.lat > maxLat) maxLat = c.lat;
      if (c.lng < minLng) minLng = c.lng;
      if (c.lng > maxLng) maxLng = c.lng;
    }

    final centerLat = (minLat + maxLat) / 2.0;
    final centerLng = (minLng + maxLng) / 2.0;

    final availWidth = math.max(viewportWidth - horizontalPadding * 2, 40.0);
    final availHeight = math.max(viewportHeight - verticalPadding * 2, 40.0);

    final lngDiff = (maxLng - minLng).abs();
    final latDiff = (maxLat - minLat).abs();

    final zoomX = lngDiff > 0.0001
        ? math.log(availWidth * 360.0 / (lngDiff * 256.0)) / math.ln2
        : 14.0;

    final zoomY = latDiff > 0.0001
        ? math.log(availHeight * 180.0 / (latDiff * 256.0 * 1.25)) / math.ln2
        : 14.0;

    final zoom = math.min(zoomX, zoomY).clamp(11.5, 15.0);

    return (centerLat: centerLat, centerLng: centerLng, zoom: zoom);
  }
}
