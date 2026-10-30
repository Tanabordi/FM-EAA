import 'package:flutter/material.dart';

/// Categories supported in FM-EAA
const List<String> kFoodCategories = [
  'All',
  'Proteins',
  'Veggies',
  'Beverages',
  'Meals',
  'Sauces',
];

/// Circular category chip selector matching Figma node 11:178 & 275:17
class CategoryChips extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const CategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: kFoodCategories.map((category) {
          final isSelected =
              category.toLowerCase() == selectedCategory.toLowerCase();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: InkWell(
              onTap: () => onSelected(category),
              borderRadius: BorderRadius.circular(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Circular button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? const Color(0xFF2E6A44)
                          : Colors.transparent,
                      border: isSelected
                          ? null
                          : Border.all(
                              color: const Color(0xFFBCCBC0),
                              width: 1.3,
                            ),
                    ),
                    alignment: Alignment.center,
                    child: CustomPaint(
                      size: const Size(24, 24),
                      painter: _CategoryIconPainter(
                        category: category,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF2C3A2F),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Category label underneath
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF1A201C)
                          : const Color(0xFF47574B),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CategoryIconPainter extends CustomPainter {
  final String category;
  final Color color;

  _CategoryIconPainter({required this.category, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.75
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (category.toLowerCase()) {
      case 'all':
        // Menu list with 3 bullet dots and 3 rounded horizontal lines
        for (int i = 0; i < 3; i++) {
          final y = 5.5 + i * 6.5;
          canvas.drawCircle(Offset(4.5, y), 1.4, fillPaint);
          canvas.drawLine(Offset(8.5, y), Offset(20.5, y), strokePaint);
        }
        break;

      case 'proteins':
        // Chicken drumstick with dual knuckle at bottom-left and meat bulb at top-right
        final drumstick = Path()
          ..moveTo(10.5, 14.5)
          ..cubicTo(7.5, 9.5, 12.0, 4.5, 16.5, 5.0)
          ..cubicTo(21.5, 5.5, 22.5, 12.0, 19.0, 16.0)
          ..cubicTo(17.5, 17.5, 14.5, 17.0, 12.5, 15.5);
        canvas.drawPath(drumstick, strokePaint);
        // Bone shaft
        canvas.drawLine(const Offset(11.5, 15.0), const Offset(7.5, 19.0), strokePaint);
        // Dual knuckles at bone end
        canvas.drawCircle(const Offset(6.0, 19.5), 1.7, strokePaint);
        canvas.drawCircle(const Offset(8.5, 21.5), 1.7, strokePaint);
        break;

      case 'veggies':
        // Carrot angled down-left
        // Top leafy stems
        canvas.drawLine(const Offset(16.5, 8.0), const Offset(20.5, 4.0), strokePaint);
        canvas.drawLine(const Offset(15.0, 6.5), const Offset(16.5, 2.5), strokePaint);
        // Carrot cone body
        final carrot = Path()
          ..moveTo(13.0, 8.0)
          ..quadraticBezierTo(18.5, 8.5, 18.0, 11.5)
          ..lineTo(6.5, 21.0)
          ..quadraticBezierTo(5.0, 22.0, 5.5, 20.0)
          ..lineTo(13.0, 8.0);
        canvas.drawPath(carrot, strokePaint);
        // Horizontal creases / texture marks
        canvas.drawLine(const Offset(12.0, 12.5), const Offset(15.5, 13.5), strokePaint);
        canvas.drawLine(const Offset(9.0, 16.0), const Offset(12.0, 17.0), strokePaint);
        break;

      case 'beverages':
        // Drink cup with lid rim and angled straw
        // Straw sticking out and bent to the right
        final straw = Path()
          ..moveTo(12.0, 9.0)
          ..lineTo(13.0, 3.5)
          ..lineTo(17.0, 3.5);
        canvas.drawPath(straw, strokePaint);
        // Lid rim
        canvas.drawLine(const Offset(5.5, 9.0), const Offset(18.5, 9.0), strokePaint);
        // Tapered cup body
        final cup = Path()
          ..moveTo(6.5, 9.0)
          ..lineTo(8.5, 20.5)
          ..quadraticBezierTo(12.0, 21.5, 15.5, 20.5)
          ..lineTo(17.5, 9.0);
        canvas.drawPath(cup, strokePaint);
        // Liquid level line
        canvas.drawLine(const Offset(7.5, 14.0), const Offset(16.5, 14.0), strokePaint);
        break;

      case 'meals':
        // Food jar with cap and label
        // Cap
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(8.0, 4.5, 8.0, 3.5),
            const Radius.circular(1.2),
          ),
          strokePaint,
        );
        // Jar body
        final jar = Path()
          ..moveTo(6.0, 9.0)
          ..lineTo(6.0, 19.5)
          ..quadraticBezierTo(12.0, 21.5, 18.0, 19.5)
          ..lineTo(18.0, 9.0)
          ..close();
        canvas.drawPath(jar, strokePaint);
        // Center label line
        canvas.drawLine(const Offset(8.5, 14.0), const Offset(15.5, 14.0), strokePaint);
        break;

      case 'sauces':
        // Sauce / condiment bottle with cap, narrow neck, and stripes
        // Cap
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(10.5, 3.5, 3.0, 2.5),
            const Radius.circular(1.0),
          ),
          strokePaint,
        );
        // Bottle outline
        final bottle = Path()
          ..moveTo(10.5, 6.0)
          ..lineTo(10.5, 9.5)
          ..lineTo(7.5, 13.0)
          ..lineTo(7.5, 20.5)
          ..quadraticBezierTo(12.0, 22.0, 16.5, 20.5)
          ..lineTo(16.5, 13.0)
          ..lineTo(13.5, 9.5)
          ..lineTo(13.5, 6.0);
        canvas.drawPath(bottle, strokePaint);
        // Two horizontal label lines across the body
        canvas.drawLine(const Offset(7.5, 16.0), const Offset(16.5, 16.0), strokePaint);
        canvas.drawLine(const Offset(7.5, 18.5), const Offset(16.5, 18.5), strokePaint);
        break;

      default:
        canvas.drawCircle(Offset(size.width / 2, size.height / 2), 5, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CategoryIconPainter oldDelegate) =>
      oldDelegate.category != category || oldDelegate.color != color;
}
