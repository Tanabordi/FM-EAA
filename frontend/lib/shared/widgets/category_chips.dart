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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: kFoodCategories.map((category) {
          final isSelected = category.toLowerCase() == selectedCategory.toLowerCase();

          return Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: InkWell(
              onTap: () => onSelected(category),
              borderRadius: BorderRadius.circular(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Circular button
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? const Color(0xFF2E6A44) : Colors.transparent,
                      border: isSelected
                          ? null
                          : Border.all(color: const Color(0xFFC7D3C5), width: 1.2),
                    ),
                    alignment: Alignment.center,
                    child: CustomPaint(
                      size: const Size(26, 26),
                      painter: _CategoryIconPainter(
                        category: category,
                        color: isSelected ? Colors.white : const Color(0xFF2C3A2F),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Category label underneath
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? const Color(0xFF1A201C) : const Color(0xFF47574B),
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
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (category.toLowerCase()) {
      case 'all':
        // Menu list with 3 bullet dots and lines
        for (int i = 0; i < 3; i++) {
          final y = 6.0 + i * 7.0;
          canvas.drawCircle(Offset(5, y), 1.6, fillPaint);
          canvas.drawLine(Offset(10, y), Offset(22, y), strokePaint);
        }
        break;

      case 'proteins':
        // Chicken drumstick
        final path = Path();
        // Bone knuckle at bottom-left
        canvas.drawCircle(const Offset(7, 20), 2.0, fillPaint);
        canvas.drawCircle(const Offset(10, 22), 2.0, fillPaint);
        canvas.drawLine(const Offset(8, 19), const Offset(12, 15), strokePaint);
        // Meat bulb at top-right
        path.moveTo(11, 16);
        path.quadraticBezierTo(9, 9, 16, 6);
        path.quadraticBezierTo(23, 7, 22, 14);
        path.quadraticBezierTo(19, 20, 13, 16);
        canvas.drawPath(path, strokePaint);
        break;

      case 'veggies':
        // Carrot
        final path = Path();
        // Top leafy stems
        canvas.drawLine(const Offset(18, 7), const Offset(21, 4), strokePaint);
        canvas.drawLine(const Offset(16, 6), const Offset(17, 3), strokePaint);
        // Carrot cone body
        path.moveTo(14, 8);
        path.quadraticBezierTo(20, 9, 19, 12);
        path.lineTo(7, 22);
        path.quadraticBezierTo(5, 23, 6, 21);
        path.lineTo(14, 8);
        canvas.drawPath(path, strokePaint);
        // Texture marks
        canvas.drawLine(const Offset(12, 13), const Offset(15, 14), strokePaint);
        canvas.drawLine(const Offset(9, 17), const Offset(11, 18), strokePaint);
        break;

      case 'beverages':
        // Drink cup with straw
        canvas.drawLine(const Offset(14, 10), const Offset(18, 4), strokePaint);
        canvas.drawLine(const Offset(6, 10), const Offset(20, 10), strokePaint);
        final cup = Path()
          ..moveTo(7, 10)
          ..lineTo(9, 22)
          ..quadraticBezierTo(13, 23, 17, 22)
          ..lineTo(19, 10);
        canvas.drawPath(cup, strokePaint);
        break;

      case 'meals':
        // Food jar / bowl
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(8, 6, 10, 4), const Radius.circular(2)),
          strokePaint,
        );
        final jar = Path()
          ..moveTo(6, 10)
          ..lineTo(6, 21)
          ..quadraticBezierTo(13, 23, 20, 21)
          ..lineTo(20, 10)
          ..close();
        canvas.drawPath(jar, strokePaint);
        canvas.drawLine(const Offset(9, 15), const Offset(17, 15), strokePaint);
        break;

      case 'sauces':
        // Sauce bottle
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(11, 4, 4, 3), const Radius.circular(1)),
          strokePaint,
        );
        final bottle = Path()
          ..moveTo(11, 7)
          ..lineTo(11, 11)
          ..lineTo(8, 14)
          ..lineTo(8, 22)
          ..quadraticBezierTo(13, 23, 18, 22)
          ..lineTo(18, 14)
          ..lineTo(15, 11)
          ..lineTo(15, 7);
        canvas.drawPath(bottle, strokePaint);
        canvas.drawLine(const Offset(10, 17), const Offset(16, 17), strokePaint);
        break;

      default:
        canvas.drawCircle(Offset(size.width / 2, size.height / 2), 6, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CategoryIconPainter oldDelegate) =>
      oldDelegate.category != category || oldDelegate.color != color;
}
