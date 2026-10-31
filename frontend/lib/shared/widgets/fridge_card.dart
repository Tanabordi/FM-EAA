import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Pixel-perfect 2-Column Grid Card for My Fridges Page (matching Figma Populated State)
class FridgeCard extends StatelessWidget {
  final String name;
  final String description;
  final String itemsCountText;
  final bool isPersonal;
  final int memberCount;
  final VoidCallback? onTap;
  final VoidCallback? onMoreOptions;
  final VoidCallback? onLongPress;

  const FridgeCard({
    super.key,
    required this.name,
    required this.description,
    required this.itemsCountText,
    this.isPersonal = true,
    this.memberCount = 1,
    this.onTap,
    this.onMoreOptions,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEAEFE8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onTap,
              onLongPress: onLongPress,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Outline fridge line icon + space for 3-dots
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _FridgeLineIcon(
                          width: 17,
                          height: 26,
                          color: Color(0xFF2E6A44),
                        ),
                        SizedBox(width: 36, height: 26),
                      ],
                    ),
                const SizedBox(height: 14),
                // Middle: Name & Description
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.5,
                    color: Color(0xFF181D18),
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF414942),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                // Items count row (Isometric box icon + text)
                Row(
                  children: [
                    const _IsometricBoxIcon(
                      size: 13,
                      color: Color(0xFF414942),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      itemsCountText,
                      style: const TextStyle(
                        color: Color(0xFF414942),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Thin Divider
                Container(
                  height: 1,
                  color: const Color(0xFFB5BBB3),
                ),
                const SizedBox(height: 10),
                // Bottom: Member status row (Person outline icon + text)
                Row(
                  children: [
                    Icon(
                      isPersonal ? Icons.person_outline : Icons.people_outline,
                      size: 15,
                      color: const Color(0xFF414942),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isPersonal ? 'Personal' : '$memberCount members',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF414942),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      Positioned(
        top: 6,
        right: 6,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onMoreOptions,
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: Icon(
                  Icons.more_vert,
                  size: 20,
                  color: Color(0xFF2E6A44),
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  ),
);
  }
}

/// Outline fridge icon matching Figma line style exactly
class _FridgeLineIcon extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const _FridgeLineIcon({
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _FridgeLinePainter(color),
      ),
    );
  }
}

class _FridgeLinePainter extends CustomPainter {
  final Color color;
  _FridgeLinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Outer rounded rectangle
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.9, 0.9, size.width - 1.8, size.height - 1.8),
      const Radius.circular(4.5),
    );
    canvas.drawRRect(rrect, stroke);

    // Horizontal divider line at 38% height
    final divY = size.height * 0.38;
    canvas.drawLine(Offset(0.9, divY), Offset(size.width - 0.9, divY), stroke);

    // Right-side handle notch inside the right edge
    final handlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final handleX = size.width - 4.2;
    canvas.drawLine(
      Offset(handleX, divY - 3.5),
      Offset(handleX, divY + 4.5),
      handlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 3D Isometric box icon matching Figma 📦 icon
class _IsometricBoxIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _IsometricBoxIcon({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _IsometricBoxPainter(color),
      ),
    );
  }
}

class _IsometricBoxPainter extends CustomPainter {
  final Color color;
  _IsometricBoxPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 0.5;

    // Hexagon vertices
    final vertices = <Offset>[];
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * math.pi / 180;
      vertices.add(Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)));
    }

    final hexPath = Path()..moveTo(vertices[0].dx, vertices[0].dy);
    for (int i = 1; i < 6; i++) {
      hexPath.lineTo(vertices[i].dx, vertices[i].dy);
    }
    hexPath.close();
    canvas.drawPath(hexPath, paint);

    // Interior lines connecting center to vertices 0 (top-right), 2 (bottom-center), 4 (top-left)
    // to form an isometric 3D cube viewed from above
    canvas.drawLine(Offset(cx, cy), vertices[0], paint);
    canvas.drawLine(Offset(cx, cy), vertices[2], paint);
    canvas.drawLine(Offset(cx, cy), vertices[4], paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
