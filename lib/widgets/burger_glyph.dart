import 'package:flutter/material.dart';

/// Compact red burger mark used in the Figma food list thumbnails.
class BurgerGlyph extends StatelessWidget {
  const BurgerGlyph({super.key});

  @override
  Widget build(BuildContext context) => const CustomPaint(
    painter: _BurgerGlyphPainter(),
    child: SizedBox.square(dimension: 34),
  );
}

class _BurgerGlyphPainter extends CustomPainter {
  const _BurgerGlyphPainter();

  static const _red = Color(0xFFD52A00);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 34, size.height / 34);
    final fill = Paint()..color = _red;
    final stroke = Paint()
      ..color = _red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final bun = Path()
      ..moveTo(5, 15)
      ..cubicTo(5, 8.5, 10, 6, 17, 6)
      ..cubicTo(24, 6, 29, 8.5, 29, 15)
      ..close();
    canvas.drawPath(bun, fill);

    final topWave = Path()
      ..moveTo(5, 18)
      ..cubicTo(8, 15, 11, 21, 14, 18)
      ..cubicTo(17, 15, 20, 21, 23, 18)
      ..cubicTo(26, 15, 28, 17, 29, 18);
    canvas.drawPath(topWave, stroke);

    final lowerWave = Path()
      ..moveTo(5, 23)
      ..cubicTo(8, 20, 11, 26, 14, 23)
      ..cubicTo(17, 20, 20, 26, 23, 23)
      ..cubicTo(26, 20, 28, 22, 29, 23);
    canvas.drawPath(lowerWave, stroke);

    final bottomBun = Path()
      ..moveTo(6, 27)
      ..lineTo(28, 27);
    canvas.drawPath(bottomBun, stroke);

    final seed = Paint()..color = const Color(0xFFFFE5DB);
    for (final point in const [Offset(12, 11), Offset(18, 9), Offset(23, 12)]) {
      canvas.drawCircle(point, 1, seed);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
