import 'app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Back button styled with rounded rectangle outline matching Figma
class FigmaBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const FigmaBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AppBackButton(
      onPressed: onPressed ??
          () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/sign-in');
            }
          },
    );
  }
}

/// Google brand sign in button styled to match Figma
class GoogleSignInButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const GoogleSignInButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: const StadiumBorder(),
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.4),
            width: 1,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const GoogleLogoIcon(size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Official 4-color Google "G" logo rendered using CustomPainter
class GoogleLogoIcon extends StatelessWidget {
  final double size;

  const GoogleLogoIcon({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = size.width * 0.22;
    final arcRadius = radius - (strokeWidth / 2);

    final rect = Rect.fromCircle(center: center, radius: arcRadius);

    final paintBlue = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final paintGreen = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final paintYellow = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final paintRed = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // 1. Red Arc (Top)
    canvas.drawArc(rect, -2.4, 1.6, false, paintRed);

    // 2. Yellow Arc (Left)
    canvas.drawArc(rect, -4.0, 1.6, false, paintYellow);

    // 3. Green Arc (Bottom)
    canvas.drawArc(rect, 0.7, 1.6, false, paintGreen);

    // 4. Blue Arc (Right corner)
    canvas.drawArc(rect, 0.0, 0.8, false, paintBlue);

    // 5. Blue Horizontal Bar (center to right)
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    final barRect = Rect.fromLTWH(
      center.dx - (size.width * 0.05),
      center.dy - (strokeWidth / 2),
      radius + (size.width * 0.05),
      strokeWidth,
    );
    canvas.drawRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
