import 'package:flutter/material.dart';

/// Pixel-perfect illustrated smiling fridge matching Figma Screen #5 Empty State.
class CuteFridgeIllustration extends StatelessWidget {
  final double size;

  const CuteFridgeIllustration({super.key, this.size = 240});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CuteFridgePainter(),
      ),
    );
  }
}

class _CuteFridgePainter extends CustomPainter {
  // Exact HEX colors extracted directly from Figma design:
  static const Color haloColor = Color(0xFFF2F7EF);       // Soft background halo
  static const Color shadowColor = Color(0xFFE8F2E4);     // Ground oval shadow
  static const Color fridgeBodyColor = Color(0xFFD8EACF); // Light sage green fridge body
  static const Color innerCavityColor = Color(0xFFF9FCF6);// Inner white shelf interior
  static const Color doorFillColor = Color(0xFFE4F0E0);   // Open door interior fill
  static const Color strokeColor = Color(0xFF638467);     // Medium sage green outline
  static const Color shelfColor = Color(0xFFC4D8BC);      // Light sage shelf divider lines
  static const Color doorShelfColor = Color(0xFFCDDEC6);  // Door shelf lines
  static const Color faceColor = Color(0xFF285C3E);       // Dark forest green face (eyes, smile)
  static const Color handleColor = Color(0xFF638467);     // Handle color
  static const Color sparkleColor = Color(0xFFC4D8BC);    // Sparkle star & dot

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 240.0;
    canvas.save();
    canvas.scale(scale, scale);

    // 1. Soft halo circle background
    final haloPaint = Paint()
      ..color = haloColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(120, 115), 104, haloPaint);

    // 2. Left 4-pointed sparkle
    _drawDiamondSparkle(canvas, const Offset(48, 77), 8.5, sparkleColor);

    // 3. Right circular sparkle dot
    final dotPaint = Paint()
      ..color = sparkleColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(192.5, 52), 2.8, dotPaint);

    // 4. Ground oval shadow under the fridge
    final shadowPaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(120, 209), width: 122, height: 16),
      shadowPaint,
    );

    // 5. Fridge feet (two rounded tabs at the bottom)
    final footPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(83, 201, 10, 8.5), const Radius.circular(4.5)),
      footPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(147, 201, 10, 8.5), const Radius.circular(4.5)),
      footPaint,
    );

    // 6. Open door on the right
    final doorPath = Path()
      ..moveTo(166.5, 87)
      ..lineTo(198, 96.5)
      ..arcToPoint(const Offset(201, 102), radius: const Radius.circular(4))
      ..lineTo(201, 187)
      ..arcToPoint(const Offset(197.5, 192), radius: const Radius.circular(4))
      ..lineTo(166.5, 199)
      ..close();

    final doorFillPaint = Paint()
      ..color = doorFillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(doorPath, doorFillPaint);

    final doorStrokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(doorPath, doorStrokePaint);

    // 3 shelves on the inside of the open door
    final doorShelfPaint = Paint()
      ..color = doorShelfColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(175, 122), const Offset(194, 118), doorShelfPaint);
    canvas.drawLine(const Offset(175, 147), const Offset(194, 143), doorShelfPaint);
    canvas.drawLine(const Offset(175, 173), const Offset(194, 169), doorShelfPaint);

    // 7. Fridge main body (colored in pastel sage green #D8EACF)
    final bodyFillPaint = Paint()
      ..color = fridgeBodyColor
      ..style = PaintingStyle.fill;
    final bodyStrokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final bodyRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(73.5, 29, 93, 173.5),
      const Radius.circular(20),
    );
    canvas.drawRRect(bodyRect, bodyFillPaint);
    canvas.drawRRect(bodyRect, bodyStrokePaint);

    // 8. Freezer divider line
    canvas.drawLine(const Offset(73.5, 85.5), const Offset(166.5, 85.5), bodyStrokePaint);

    // 9. Freezer handle on the left
    final handlePaint = Paint()
      ..color = handleColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(83.5, 53, 3.8, 15), const Radius.circular(2)),
      handlePaint,
    );

    // 10. Cute Face on Freezer
    final eyePaint = Paint()
      ..color = faceColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(114, 55), 2.8, eyePaint);
    canvas.drawCircle(const Offset(139.5, 55), 2.8, eyePaint);

    // Smile mouth 'v'
    final smilePath = Path()
      ..moveTo(122, 60.5)
      ..lineTo(126.8, 67.5)
      ..lineTo(131.5, 60.5);
    final smilePaint = Paint()
      ..color = faceColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(smilePath, smilePaint);

    // 11. Inner white shelf cavity (#F9FCF6) in the lower compartment
    final cavityPaint = Paint()
      ..color = innerCavityColor
      ..style = PaintingStyle.fill;
    final cavityRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(81.5, 93.5, 77, 101),
      const Radius.circular(10),
    );
    canvas.drawRRect(cavityRect, cavityPaint);

    // 12. Two horizontal shelves inside the cavity (#C4D8BC)
    final shelfPaint = Paint()
      ..color = shelfColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(81.5, 127), const Offset(158.5, 127), shelfPaint);
    canvas.drawLine(const Offset(81.5, 161), const Offset(158.5, 161), shelfPaint);

    canvas.restore();
  }

  void _drawDiamondSparkle(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(center.dx, center.dy - radius);
    path.quadraticBezierTo(center.dx, center.dy, center.dx + radius, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + radius);
    path.quadraticBezierTo(center.dx, center.dy, center.dx - radius, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - radius);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
