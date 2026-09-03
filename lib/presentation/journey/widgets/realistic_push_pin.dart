import 'package:flutter/material.dart';

/// Realistic 3D pushpin painted with shadow, tapered needle, sculpted neck,
/// rounded grip knob, and glossy highlight matching the reference image.
class RealisticPushPin extends StatelessWidget {
  final double size;
  const RealisticPushPin({super.key, this.size = 28.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RealisticPushPinPainter(),
      ),
    );
  }
}

class _RealisticPushPinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Center of rotation
    canvas.translate(size.width * 0.5, size.height * 0.5);
    // Rotate ~45 degrees pointing down-left into the paper
    canvas.rotate(0.785);

    // 1. Soft oval cast shadow on paper
    final shadowPaint = Paint()
      ..color = const Color(0x381A0F0A)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    final shadowPath = Path()
      ..addOval(Rect.fromCenter(
        center: const Offset(3.5, 3.5),
        width: 8.0,
        height: 14.0,
      ));
    canvas.drawPath(shadowPath, shadowPaint);

    // 2. Tapered metal needle
    final needlePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF90A4AE), Color(0xFF37474F)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(const Rect.fromLTWH(-1.2, 3.0, 2.4, 9.5));

    final needlePath = Path()
      ..moveTo(-1.1, 3.0)
      ..lineTo(1.1, 3.0)
      ..lineTo(0.2, 12.0)
      ..lineTo(-0.2, 12.0)
      ..close();
    canvas.drawPath(needlePath, needlePaint);

    // 3. Plastic collar / base rim
    final collarPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF4A342B), Color(0xFF1E130E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(const Rect.fromLTWH(-5.0, 0.0, 10.0, 3.5));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-5.0, 0.5, 10.0, 3.5),
        const Radius.circular(1.8),
      ),
      collarPaint,
    );

    // 4. Narrow neck / waist
    final neckPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF382319), Color(0xFF170E0A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(const Rect.fromLTWH(-3.0, -3.5, 6.0, 4.5));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-3.0, -3.5, 6.0, 4.5),
        const Radius.circular(1.2),
      ),
      neckPaint,
    );

    // 5. Main Rounded Head / Grip Knob
    final headPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.35, -0.4),
        radius: 0.85,
        colors: [
          Color(0xFF5D3F33), // specular warm highlight
          Color(0xFF2E1C14), // rich dark brown
          Color(0xFF120A07), // deep shadow
        ],
        stops: [0.0, 0.55, 1.0],
      ).createShader(const Rect.fromLTWH(-6.5, -12.5, 13.0, 10.0));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-6.5, -12.5, 13.0, 10.0),
        const Radius.circular(4.5),
      ),
      headPaint,
    );

    // 6. Glossy reflection highlight on knob
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.38)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8);
    canvas.drawCircle(const Offset(-2.2, -8.5), 1.6, highlightPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
