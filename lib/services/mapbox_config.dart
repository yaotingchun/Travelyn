import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Configuration and helper utilities for Mapbox API and map rendering.
class MapboxConfig {
  /// Default Mapbox Public Access Token.
  /// Replace with your own Mapbox token (format: pk.eyJ...).
  /// You can obtain a free token at https://account.mapbox.com
  static const String defaultAccessToken =
      'pk.eyJ1IjoieWFvdGluZ2NodW4iLCJhIjoiY21tZ2x1MW9yMGtlMDJ3b2ozaGNhd3ZnZyJ9.d5zcnqiWRPTcoYewN9d-YA';

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
