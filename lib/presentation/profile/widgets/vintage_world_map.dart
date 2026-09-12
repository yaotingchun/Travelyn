import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/explorer_country.dart';

/// Interactive vintage world map displaying the authentic watercolor base map
/// with dynamic dashed travel trajectory routes (轨迹) and location pins.
///
/// Updates dynamically whenever the user visits a new country or updates their travel list.
class VintageWorldMap extends StatefulWidget {
  final List<ExplorerCountry> countries;
  final ValueChanged<ExplorerCountry>? onCountryTap;
  final double height;

  const VintageWorldMap({
    super.key,
    required this.countries,
    this.onCountryTap,
    this.height = 240,
  });

  @override
  State<VintageWorldMap> createState() => _VintageWorldMapState();
}

class _VintageWorldMapState extends State<VintageWorldMap> {
  ExplorerCountry? _selectedCountry;

  void _handleTapUp(TapUpDetails details, Size size) {
    final localPos = details.localPosition;
    final normalized = Offset(
      (localPos.dx / size.width).clamp(0.0, 1.0),
      (localPos.dy / size.height).clamp(0.0, 1.0),
    );

    // Find closest country within hit threshold
    ExplorerCountry? closest;
    double minDistance = 0.085;

    for (final country in widget.countries) {
      final dx = country.mapCoordinate.dx - normalized.dx;
      final dy =
          (country.mapCoordinate.dy - normalized.dy) * (size.height / size.width);
      final dist = math.sqrt(dx * dx + dy * dy);
      if (dist < minDistance) {
        minDistance = dist;
        closest = country;
      }
    }

    if (closest != null) {
      setState(() {
        _selectedCountry = closest;
      });
      widget.onCountryTap?.call(closest);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F0E4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2D3BE),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3E2723).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mapSize = Size(constraints.maxWidth, widget.height);

            return GestureDetector(
              onTapUp: (details) => _handleTapUp(details, mapSize),
              behavior: HitTestBehavior.opaque,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. The authentic high-resolution vintage watercolor world map
                  Image.asset(
                    'assets/profile/vintage_world_map.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFF7F0E4),
                      child: const Center(
                        child: Icon(Icons.public, color: Color(0xFF8D6E63), size: 48),
                      ),
                    ),
                  ),

                  // 2. Subtle parchment vignette overlay around borders
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 0.95,
                          colors: [
                            Colors.transparent,
                            const Color(0xFF5D4037).withValues(alpha: 0.12),
                          ],
                          stops: const [0.75, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // 3. Dynamic Trajectory Routes & Non-overlapping Country Pins
                  CustomPaint(
                    size: mapSize,
                    painter: _DynamicRouteOverlayPainter(
                      countries: widget.countries,
                      selectedCode: _selectedCountry?.code,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Canvas painter dynamically rendering static dashed travel trajectories and country pins
class _DynamicRouteOverlayPainter extends CustomPainter {
  final List<ExplorerCountry> countries;
  final String? selectedCode;

  _DynamicRouteOverlayPainter({
    required this.countries,
    this.selectedCode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawStaticTrajectories(canvas, size);
    _drawDynamicCountryPins(canvas, size);
  }

  void _drawStaticTrajectories(Canvas canvas, Size size) {
    final trajectoryPaint = Paint()
      ..color = const Color(0xFF5D4037).withValues(alpha: 0.78)
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;

    final trajectoryGlow = Paint()
      ..color = const Color(0xFFFFF8E7).withValues(alpha: 0.70)
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke;

    // Active countries lookup
    final countryMap = {for (var c in countries) c.code: c};

    // Connected route pairs for explored countries
    final routePairs = <List<String>>[
      ['US', 'GB'],
      ['GB', 'FR'],
      ['FR', 'IT'],
      ['IT', 'TR'],
      ['TR', 'CN'],
      ['CN', 'KR'],
      ['KR', 'JP'],
      ['CN', 'TH'],
      ['TH', 'MY'],
      ['MY', 'SG'],
      ['SG', 'ID'],
      ['ID', 'AU'],
      ['AU', 'NZ'],
    ];

    for (final pair in routePairs) {
      final countryA = countryMap[pair[0]];
      final countryB = countryMap[pair[1]];

      if (countryA == null || countryB == null) continue;

      final isAExplored = countryA.isExplored;
      final isBExplored = countryB.isExplored;
      final isAWish = countryA.isWishlist;
      final isBWish = countryB.isWishlist;

      if (!((isAExplored || isAWish) && (isBExplored || isBWish))) {
        continue;
      }

      final p1 = Offset(
        countryA.mapCoordinate.dx * size.width,
        countryA.mapCoordinate.dy * size.height,
      );
      final p2 = Offset(
        countryB.mapCoordinate.dx * size.width,
        countryB.mapCoordinate.dy * size.height,
      );

      final path = Path();
      path.moveTo(p1.dx, p1.dy);

      // Natural curved arch between coordinates
      final midX = (p1.dx + p2.dx) / 2;
      final midY = (p1.dy + p2.dy) / 2;
      final dist = (p1 - p2).distance;
      final curvature = (p2.dx > p1.dx) ? -dist * 0.20 : dist * 0.16;

      final cp = Offset(midX, midY + curvature);
      path.quadraticBezierTo(cp.dx, cp.dy, p2.dx, p2.dy);

      // 1. Soft subtle halo behind dashed line for high contrast
      _drawDashedPath(canvas, path, trajectoryGlow, 4.5, 3.5);

      // 2. Static clean dashed trajectory line
      _drawDashedPath(canvas, path, trajectoryPaint, 4.5, 3.5);
    }
  }

  void _drawDashedPath(
      Canvas canvas, Path path, Paint paint, double dashWidth, double dashSpace) {
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final len = math.min(dashWidth, metric.length - distance);
        final extract = metric.extractPath(distance, distance + len);
        canvas.drawPath(extract, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  void _drawDynamicCountryPins(Canvas canvas, Size size) {
    for (final country in countries) {
      if (country.isSomeday) continue; // Only label explored and wishlist

      final pos = Offset(
        country.mapCoordinate.dx * size.width,
        country.mapCoordinate.dy * size.height,
      );

      final isExplored = country.isExplored;
      final isSelected = country.code == selectedCode;

      final pinColor =
          isExplored ? const Color(0xFFE87516) : const Color(0xFFD8A24A);
      final pinBorderColor =
          isExplored ? const Color(0xFF9E3A00) : const Color(0xFF8D653E);

      // 1. Soft pin shadow
      canvas.drawCircle(
        pos + const Offset(0, 1.5),
        4.0,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.20)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0),
      );

      // 2. Teardrop Location Pin
      final pinPath = Path()
        ..moveTo(pos.dx, pos.dy)
        ..lineTo(pos.dx - 3.5, pos.dy - 6.5)
        ..arcToPoint(
          Offset(pos.dx + 3.5, pos.dy - 6.5),
          radius: const Radius.circular(3.5),
        )
        ..close();

      final pinPaint = Paint()
        ..color = pinColor
        ..style = PaintingStyle.fill;
      final borderPaint = Paint()
        ..color = pinBorderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;

      canvas.drawPath(pinPath, pinPaint);
      canvas.drawPath(pinPath, borderPaint);

      // 3. Inner bright dot
      canvas.drawCircle(
        Offset(pos.dx, pos.dy - 6.5),
        1.3,
        Paint()..color = Colors.white,
      );

      // 4. Country Name Typography
      final labelSpan = TextSpan(
        text: country.name,
        style: GoogleFonts.nunito(
          fontSize: isSelected ? 9.5 : 8.0,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
          color: const Color(0xFF2C1E1A),
          shadows: const [
            Shadow(
              color: Color(0xFFFFFDF8),
              offset: Offset(0.8, 0.8),
              blurRadius: 2.0,
            ),
            Shadow(
              color: Color(0xFFFFFDF8),
              offset: Offset(-0.8, -0.8),
              blurRadius: 2.0,
            ),
            Shadow(
              color: Color(0xFFFFFDF8),
              offset: Offset(-0.8, 0.8),
              blurRadius: 2.0,
            ),
            Shadow(
              color: Color(0xFFFFFDF8),
              offset: Offset(0.8, -0.8),
              blurRadius: 2.0,
            ),
          ],
        ),
      );

      final textPainter = TextPainter(
        text: labelSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      // 5. Smart directional placement to avoid overlap with adjacent countries
      final labelOffset = _getSmartLabelOffset(country.code, textPainter.size);

      // Prevent clipping past card boundaries
      final textX = (pos.dx + labelOffset.dx)
          .clamp(4.0, size.width - textPainter.width - 4.0);
      final textY = (pos.dy + labelOffset.dy)
          .clamp(4.0, size.height - textPainter.height - 4.0);

      textPainter.paint(canvas, Offset(textX, textY));
    }
  }

  /// Calculates directional label offset relative to pin coordinate
  Offset _getSmartLabelOffset(String code, Size textSize) {
    switch (code) {
      case 'GB': // UK: Offset top-left so it floats cleanly above France
        return Offset(-textSize.width - 4.0, -textSize.height - 4.0);
      case 'FR': // France: Place to left in Atlantic/Bay of Biscay
        return Offset(-textSize.width - 4.5, -textSize.height / 2);
      case 'CH': // Switzerland: Place centered above pin
        return Offset(-textSize.width / 2, -textSize.height - 6.0);
      case 'IT': // Italy: Place bottom-right in Mediterranean
        return Offset(5.0, 3.0);
      case 'TR': // Turkey: Place right into Middle East
        return Offset(5.0, -textSize.height / 2);
      case 'CN': // China: Place top-left inside China landmass
        return Offset(-textSize.width - 3.0, -textSize.height - 2.0);
      case 'KR': // South Korea: Place to left (Yellow Sea) so it doesn't overlap Japan
        return Offset(-textSize.width - 4.5, -textSize.height / 2);
      case 'JP': // Japan: Place to right into Pacific Ocean
        return Offset(5.0, -textSize.height / 2);
      case 'TH': // Thailand: Place to left into Andaman Sea
        return Offset(-textSize.width - 4.5, -textSize.height / 2);
      case 'MY': // Malaysia: Place to left into Malacca Strait
        return Offset(-textSize.width - 4.5, -textSize.height / 2);
      case 'SG': // Singapore: Place to right
        return Offset(5.0, -textSize.height / 2);
      case 'ID': // Indonesia: Place to bottom-right into Indian Ocean
        return Offset(5.0, 3.0);
      case 'AU': // Australia: Place to right
        return Offset(5.0, -textSize.height / 2);
      case 'NZ': // New Zealand: Place to left (Tasman Sea) to prevent right border clipping
        return Offset(-textSize.width - 5.0, -textSize.height / 2);
      case 'US': // United States: Place to right
        return Offset(5.0, -textSize.height / 2);
      case 'IS': // Iceland: Place to right
        return Offset(5.0, -textSize.height / 2);
      default:
        return Offset(5.0, -textSize.height / 2);
    }
  }

  @override
  bool shouldRepaint(covariant _DynamicRouteOverlayPainter oldDelegate) {
    return oldDelegate.selectedCode != selectedCode ||
        oldDelegate.countries != countries;
  }
}
