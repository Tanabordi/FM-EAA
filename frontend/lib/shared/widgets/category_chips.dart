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

/// Circular category chip selector matching exact Figma node 11:178 & uploaded mockup
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
                  // Circular button with prominent, enlarged icons matching user request
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? const Color(0xFF2E6A44) // Active forest green #2E6A44
                          : const Color(0xFFEAEFE8), // Inactive surface container #EAEFE8
                      border: isSelected
                          ? null
                          : Border.all(
                              color: const Color(0xFF717971), // Inactive border outline #717971
                              width: 1.2,
                            ),
                    ),
                    alignment: Alignment.center,
                    child: CustomPaint(
                      size: const Size(28, 28), // Enlarged from 22x22 to 28x28 for high visibility
                      painter: _CategoryIconPainter(
                        category: category,
                        color: isSelected
                            ? const Color(0xFFF6FBF3) // Active white-tinted icon
                            : const Color(0xFF414942), // Inactive dark charcoal green #414942
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Category label underneath
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF1A201C)
                          : const Color(0xFF414942), // Inactive label #414942
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

/// Custom painter rendering prominent, clear vector icons matching uploaded image
class _CategoryIconPainter extends CustomPainter {
  final String category;
  final Color color;

  _CategoryIconPainter({required this.category, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
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
        // Menu / bullet list: 3 filled dots on left, 3 rounded lines on right
        final dotRadius = w * 0.07;
        final lineStartX = w * 0.32;
        final lineEndX = w * 0.90;
        final ys = [h * 0.22, h * 0.50, h * 0.78];
        for (final y in ys) {
          canvas.drawCircle(Offset(w * 0.12, y), dotRadius, fillPaint);
          canvas.drawLine(Offset(lineStartX, y), Offset(lineEndX, y), paint);
        }
        break;

      case 'proteins':
        // Chicken drumstick:
        // Round meat bulb at top-right
        final meatCenter = Offset(w * 0.62, h * 0.38);
        final meatRadius = w * 0.26;
        canvas.drawCircle(meatCenter, meatRadius, paint);

        // Bone shaft extending down-left
        final boneStart = Offset(w * 0.46, h * 0.54);
        final boneEnd = Offset(w * 0.24, h * 0.76);
        canvas.drawLine(boneStart, boneEnd, paint);

        // Bone joint head with 2 rounded condyles
        final knob1 = Offset(w * 0.16, h * 0.70);
        final knob2 = Offset(w * 0.24, h * 0.82);
        canvas.drawCircle(knob1, w * 0.08, paint);
        canvas.drawCircle(knob2, w * 0.08, paint);
        break;

      case 'veggies':
        // Carrot:
        // Body cone tapering down-left
        final carrotPath = Path()
          ..moveTo(w * 0.36, h * 0.38)
          ..quadraticBezierTo(w * 0.53, h * 0.36, w * 0.70, h * 0.40)
          ..quadraticBezierTo(w * 0.58, h * 0.62, w * 0.16, h * 0.86)
          ..quadraticBezierTo(w * 0.24, h * 0.58, w * 0.36, h * 0.38)
          ..close();
        canvas.drawPath(carrotPath, paint);

        // 3 leafy sprigs radiating from top base
        canvas.drawLine(Offset(w * 0.53, h * 0.38), Offset(w * 0.53, h * 0.14), paint);
        canvas.drawLine(Offset(w * 0.46, h * 0.38), Offset(w * 0.30, h * 0.22), paint);
        canvas.drawLine(Offset(w * 0.60, h * 0.38), Offset(w * 0.76, h * 0.24), paint);

        // 2 ridges on carrot body
        final thinPaint = Paint()
          ..color = color
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        canvas.drawLine(Offset(w * 0.38, h * 0.54), Offset(w * 0.52, h * 0.52), thinPaint);
        canvas.drawLine(Offset(w * 0.28, h * 0.68), Offset(w * 0.38, h * 0.66), thinPaint);
        break;

      case 'beverages':
        // Drink cup with bent straw:
        // Straw coming out of lid
        final strawPath = Path()
          ..moveTo(w * 0.46, h * 0.34)
          ..lineTo(w * 0.52, h * 0.14)
          ..lineTo(w * 0.72, h * 0.14);
        canvas.drawPath(strawPath, paint);

        // Lid horizontal rim
        canvas.drawLine(Offset(w * 0.16, h * 0.34), Offset(w * 0.84, h * 0.34), paint);

        // Cup body tapering downwards
        final cupPath = Path()
          ..moveTo(w * 0.20, h * 0.34)
          ..lineTo(w * 0.30, h * 0.84)
          ..quadraticBezierTo(w * 0.30, h * 0.86, w * 0.34, h * 0.86)
          ..lineTo(w * 0.66, h * 0.86)
          ..quadraticBezierTo(w * 0.70, h * 0.86, w * 0.70, h * 0.84)
          ..lineTo(w * 0.80, h * 0.34);
        canvas.drawPath(cupPath, paint);

        // Horizontal sleeve across middle of cup
        canvas.drawLine(Offset(w * 0.24, h * 0.50), Offset(w * 0.76, h * 0.50), paint);
        canvas.drawLine(Offset(w * 0.26, h * 0.58), Offset(w * 0.74, h * 0.58), paint);
        break;

      case 'meals':
        // Preserve jar with lid:
        // Lid (rounded rectangle)
        final lidRRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.28, h * 0.20, w * 0.44, h * 0.14),
          const Radius.circular(3.0),
        );
        canvas.drawRRect(lidRRect, paint);

        // Jar body
        final jarPath = Path()
          ..moveTo(w * 0.34, h * 0.34)
          ..lineTo(w * 0.34, h * 0.42)
          ..quadraticBezierTo(w * 0.20, h * 0.45, w * 0.20, h * 0.52)
          ..lineTo(w * 0.20, h * 0.80)
          ..quadraticBezierTo(w * 0.20, h * 0.84, w * 0.26, h * 0.84)
          ..lineTo(w * 0.74, h * 0.84)
          ..quadraticBezierTo(w * 0.80, h * 0.84, w * 0.80, h * 0.80)
          ..lineTo(w * 0.80, h * 0.52)
          ..quadraticBezierTo(w * 0.80, h * 0.45, w * 0.66, h * 0.42)
          ..lineTo(w * 0.66, h * 0.34);
        canvas.drawPath(jarPath, paint);

        // Center label on jar
        canvas.drawLine(Offset(w * 0.34, h * 0.64), Offset(w * 0.66, h * 0.64), paint);
        break;

      case 'sauces':
        // Sauce bottle:
        // Cap
        final capRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.42, h * 0.18, w * 0.16, h * 0.10),
          const Radius.circular(2.0),
        );
        canvas.drawRRect(capRect, paint);

        // Bottle body
        final bottlePath = Path()
          // Neck
          ..moveTo(w * 0.38, h * 0.28)
          ..lineTo(w * 0.38, h * 0.46)
          // Shoulder
          ..quadraticBezierTo(w * 0.24, h * 0.49, w * 0.24, h * 0.56)
          // Body
          ..lineTo(w * 0.24, h * 0.82)
          ..quadraticBezierTo(w * 0.24, h * 0.84, w * 0.28, h * 0.84)
          ..lineTo(w * 0.72, h * 0.84)
          ..quadraticBezierTo(w * 0.76, h * 0.84, w * 0.76, h * 0.82)
          ..lineTo(w * 0.76, h * 0.56)
          ..quadraticBezierTo(w * 0.76, h * 0.49, w * 0.62, h * 0.46)
          ..lineTo(w * 0.62, h * 0.28);
        canvas.drawPath(bottlePath, paint);

        // Two horizontal label stripes
        canvas.drawLine(Offset(w * 0.24, h * 0.62), Offset(w * 0.76, h * 0.62), paint);
        canvas.drawLine(Offset(w * 0.24, h * 0.70), Offset(w * 0.76, h * 0.70), paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _CategoryIconPainter oldDelegate) {
    return oldDelegate.category != category || oldDelegate.color != color;
  }
}
