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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final items = kFoodCategories.map((category) {
            final isSelected =
                category.toLowerCase() == selectedCategory.toLowerCase();

            return InkWell(
              onTap: () => onSelected(category),
              borderRadius: BorderRadius.circular(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Circular button
                  Container(
                    width: 46,
                    height: 46,
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
                      size: const Size(22, 22),
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
            );
          }).toList();

          if (constraints.maxWidth < 340) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: items
                    .map((w) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: w,
                        ))
                    .toList(),
              ),
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: items,
          );
        },
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
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    switch (category.toLowerCase()) {
      case 'all':
        // Menu / bullet list icon (3 lines with dots)
        for (var i = 0; i < 3; i++) {
          final y = h * 0.25 + i * h * 0.25;
          canvas.drawCircle(Offset(w * 0.2, y), 1.5, fillPaint);
          canvas.drawLine(Offset(w * 0.38, y), Offset(w * 0.82, y), paint);
        }
        break;

      case 'proteins':
        // Drumstick / chicken bone outline
        final path = Path()
          ..moveTo(w * 0.35, h * 0.65)
          ..lineTo(w * 0.2, h * 0.8)
          ..moveTo(w * 0.3, h * 0.7)
          ..lineTo(w * 0.15, h * 0.85);
        canvas.drawPath(path, paint);
        // Meat bulb
        canvas.drawCircle(Offset(w * 0.58, h * 0.42), w * 0.26, paint);
        break;

      case 'veggies':
        // Carrot icon: triangular body + top leaves
        final carrotPath = Path()
          ..moveTo(w * 0.35, h * 0.35)
          ..quadraticBezierTo(w * 0.7, h * 0.3, w * 0.65, h * 0.5)
          ..lineTo(w * 0.25, h * 0.85)
          ..close();
        canvas.drawPath(carrotPath, paint);
        // Leaf greens
        canvas.drawLine(Offset(w * 0.55, h * 0.33), Offset(w * 0.68, h * 0.18), paint);
        canvas.drawLine(Offset(w * 0.62, h * 0.36), Offset(w * 0.8, h * 0.26), paint);
        // Ridges on carrot
        canvas.drawLine(Offset(w * 0.44, h * 0.48), Offset(w * 0.56, h * 0.45), paint);
        canvas.drawLine(Offset(w * 0.36, h * 0.6), Offset(w * 0.46, h * 0.58), paint);
        break;

      case 'beverages':
        // Cup with straw
        final cupPath = Path()
          ..moveTo(w * 0.3, h * 0.4)
          ..lineTo(w * 0.35, h * 0.82)
          ..lineTo(w * 0.65, h * 0.82)
          ..lineTo(w * 0.7, h * 0.4)
          ..close();
        canvas.drawPath(cupPath, paint);
        // Lid line
        canvas.drawLine(Offset(w * 0.26, h * 0.4), Offset(w * 0.74, h * 0.4), paint);
        // Straw
        final strawPath = Path()
          ..moveTo(w * 0.5, h * 0.4)
          ..lineTo(w * 0.58, h * 0.18)
          ..lineTo(w * 0.68, h * 0.18);
        canvas.drawPath(strawPath, paint);
        break;

      case 'meals':
        // Jar / pot with lid
        final jarPath = Path()
          ..moveTo(w * 0.3, h * 0.42)
          ..lineTo(w * 0.3, h * 0.8)
          ..quadraticBezierTo(w * 0.5, h * 0.86, w * 0.7, h * 0.8)
          ..lineTo(w * 0.7, h * 0.42)
          ..close();
        canvas.drawPath(jarPath, paint);
        // Jar lid
        final lidRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.28, h * 0.28, w * 0.44, h * 0.12),
          const Radius.circular(2),
        );
        canvas.drawRRect(lidRect, paint);
        // Label stripe
        canvas.drawLine(Offset(w * 0.34, h * 0.58), Offset(w * 0.66, h * 0.58), paint);
        break;

      case 'sauces':
        // Bottle shape
        final bottlePath = Path()
          // Neck
          ..moveTo(w * 0.44, h * 0.22)
          ..lineTo(w * 0.56, h * 0.22)
          ..lineTo(w * 0.56, h * 0.38)
          // Shoulder
          ..quadraticBezierTo(w * 0.7, h * 0.45, w * 0.7, h * 0.58)
          // Body
          ..lineTo(w * 0.7, h * 0.82)
          ..lineTo(w * 0.3, h * 0.82)
          ..lineTo(w * 0.3, h * 0.58)
          // Shoulder
          ..quadraticBezierTo(w * 0.3, h * 0.45, w * 0.44, h * 0.38)
          ..close();
        canvas.drawPath(bottlePath, paint);
        // Cap
        canvas.drawRect(Rect.fromLTWH(w * 0.42, h * 0.14, w * 0.16, h * 0.08), fillPaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _CategoryIconPainter oldDelegate) {
    return oldDelegate.category != category || oldDelegate.color != color;
  }
}
