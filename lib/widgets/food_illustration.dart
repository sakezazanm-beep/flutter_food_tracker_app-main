import 'package:flutter/material.dart';

/// A clean, scalable food mark drawn to match the bold Figma illustration.
class FoodIllustration extends StatelessWidget {
  const FoodIllustration({super.key});

  @override
  Widget build(BuildContext context) => const CustomPaint(
    painter: _FoodIllustrationPainter(),
    child: SizedBox.expand(),
  );
}

class _FoodIllustrationPainter extends CustomPainter {
  const _FoodIllustrationPainter();

  static const _ink = Color(0xFF202124);
  static const _bun = Color(0xFFFFA726);
  static const _bunLight = Color(0xFFFFC34D);
  static const _cheese = Color(0xFFFFC928);
  static const _lettuce = Color(0xFF54B866);
  static const _red = Color(0xFFF44336);
  static const _cupBlue = Color(0xFF29B6E6);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 300, size.height / 250);

    final fill = Paint()..style = PaintingStyle.fill;
    final outline = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // Soda cup at the back.
    final straw = Path()
      ..moveTo(151, 63)
      ..lineTo(151, 28)
      ..lineTo(168, 13);
    canvas.drawPath(straw, outline);
    final cup = Path()
      ..moveTo(124, 55)
      ..lineTo(181, 55)
      ..lineTo(174, 147)
      ..quadraticBezierTo(173, 157, 162, 157)
      ..lineTo(143, 157)
      ..quadraticBezierTo(132, 157, 131, 147)
      ..close();
    fill.color = _cupBlue;
    canvas.drawPath(cup, fill);
    canvas.drawPath(cup, outline);
    final lid = RRect.fromRectAndRadius(
      const Rect.fromLTRB(119, 48, 186, 65),
      const Radius.circular(5),
    );
    fill.color = Colors.white;
    canvas.drawRRect(lid, fill);
    canvas.drawRRect(lid, outline);

    // Fries and carton on the right.
    final fries = [
      const Rect.fromLTRB(195, 50, 211, 134),
      const Rect.fromLTRB(215, 35, 232, 133),
      const Rect.fromLTRB(237, 53, 254, 136),
      const Rect.fromLTRB(258, 69, 274, 137),
    ];
    fill.color = _cheese;
    for (final rect in fries) {
      final shape = RRect.fromRectAndRadius(rect, const Radius.circular(7));
      canvas.drawRRect(shape, fill);
      canvas.drawRRect(shape, outline);
    }
    final carton = Path()
      ..moveTo(190, 117)
      ..lineTo(274, 117)
      ..lineTo(262, 205)
      ..quadraticBezierTo(260, 215, 249, 215)
      ..lineTo(211, 215)
      ..quadraticBezierTo(201, 215, 199, 205)
      ..close();
    fill.color = _red;
    canvas.drawPath(carton, fill);
    canvas.drawPath(carton, outline);
    fill.color = Colors.white;
    canvas.drawCircle(const Offset(233, 172), 11, fill);
    canvas.drawCircle(const Offset(233, 172), 11, outline);

    // Burger in the foreground: lower bun, lettuce, cheese and top bun.
    final bottomBun = RRect.fromRectAndRadius(
      const Rect.fromLTRB(27, 174, 216, 220),
      const Radius.circular(20),
    );
    fill.color = _bunLight;
    canvas.drawRRect(bottomBun, fill);
    canvas.drawRRect(bottomBun, outline);

    final lettuce = Path()
      ..moveTo(34, 171)
      ..lineTo(60, 157)
      ..lineTo(82, 172)
      ..lineTo(106, 155)
      ..lineTo(131, 172)
      ..lineTo(157, 155)
      ..lineTo(184, 171)
      ..lineTo(211, 159)
      ..lineTo(205, 184)
      ..lineTo(39, 184)
      ..close();
    fill.color = _lettuce;
    canvas.drawPath(lettuce, fill);
    canvas.drawPath(lettuce, outline);

    final cheese = Path()
      ..moveTo(40, 151)
      ..lineTo(203, 151)
      ..lineTo(184, 174)
      ..lineTo(159, 164)
      ..lineTo(135, 180)
      ..lineTo(111, 163)
      ..lineTo(83, 177)
      ..close();
    fill.color = _cheese;
    canvas.drawPath(cheese, fill);
    canvas.drawPath(cheese, outline);

    final patty = RRect.fromRectAndRadius(
      const Rect.fromLTRB(36, 135, 207, 163),
      const Radius.circular(12),
    );
    fill.color = const Color(0xFF7A3E26);
    canvas.drawRRect(patty, fill);
    canvas.drawRRect(patty, outline);

    final topBun = Path()
      ..moveTo(29, 137)
      ..cubicTo(27, 104, 51, 89, 82, 89)
      ..lineTo(157, 89)
      ..cubicTo(190, 89, 212, 105, 209, 137)
      ..close();
    fill.color = _bun;
    canvas.drawPath(topBun, fill);
    canvas.drawPath(topBun, outline);

    // Sesame seeds.
    final seed = Paint()..color = Colors.white;
    for (final point in const [
      Offset(69, 112),
      Offset(99, 101),
      Offset(132, 114),
      Offset(163, 103),
      Offset(184, 119),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(center: point, width: 7, height: 4),
        seed,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
