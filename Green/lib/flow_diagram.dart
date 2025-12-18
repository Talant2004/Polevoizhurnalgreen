import 'package:flutter/material.dart';

class FlowDiagram extends StatelessWidget {
  const FlowDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Схема работы')),
      body: Center(
        child: CustomPaint(
          size: const Size(300, 100),
          painter: FlowDiagramPainter(),
        ),
      ),
    );
  }
}

class FlowDiagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 24,
      fontFamily: 'NotoColorEmoji',
    );
    final textPainter = (String text, Offset offset) {
      TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textDirection: TextDirection.ltr,
      )
        ..layout()
        ..paint(canvas, offset);
    };

    textPainter('👨‍🌾', const Offset(20, 50));
    textPainter('📱', const Offset(100, 50));
    textPainter('☁', const Offset(180, 50));
    textPainter('👨‍💼', const Offset(260, 50));

    final arrowPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;

    canvas.drawLine(const Offset(50, 50), const Offset(80, 50), paint);
    canvas.drawPath(
      Path()
        ..moveTo(80, 50)
        ..lineTo(75, 45)
        ..lineTo(75, 55)
        ..close(),
      arrowPaint,
    );

    canvas.drawLine(const Offset(130, 50), const Offset(160, 50), paint);
    canvas.drawPath(
      Path()
        ..moveTo(160, 50)
        ..lineTo(155, 45)
        ..lineTo(155, 55)
        ..close(),
      arrowPaint,
    );

    canvas.drawLine(const Offset(210, 50), const Offset(240, 50), paint);
    canvas.drawPath(
      Path()
        ..moveTo(240, 50)
        ..lineTo(235, 45)
        ..lineTo(235, 55)
        ..close(),
      arrowPaint,
    );

    final labelStyle = TextStyle(color: Colors.black, fontSize: 12);
    final labelPainter = (String text, Offset offset) {
      TextPainter(
        text: TextSpan(text: text, style: labelStyle),
        textDirection: TextDirection.ltr,
      )
        ..layout()
        ..paint(canvas, offset);
    };

    labelPainter('Работник', const Offset(20, 80));
    labelPainter('Приложение', const Offset(100, 80));
    labelPainter('Облако', const Offset(180, 80));
    labelPainter('Админ', const Offset(260, 80));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}