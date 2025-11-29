import 'package:flutter/material.dart';

class RotAILogo extends StatelessWidget {
  final double size;
  final bool showText;
  
  const RotAILogo({
    super.key,
    this.size = 120,
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: showText ? size * 0.3 : size,
      child: CustomPaint(
        painter: _RotAILogoPainter(showText: showText),
      ),
    );
  }
}

class _RotAILogoPainter extends CustomPainter {
  final bool showText;
  
  _RotAILogoPainter({this.showText = false});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 200;

    // "RotAI" yazısı
    if (showText) {
      final textStyle = TextStyle(
        fontSize: 18 * scale,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      );
      
      final textSpan = TextSpan(
        children: [
          TextSpan(
            text: 'Rot',
            style: textStyle.copyWith(
              color: const Color(0xFF4B5563), // Koyu gri/gümüş
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          TextSpan(
            text: 'AI',
            style: textStyle.copyWith(
              color: const Color(0xFF96ADFC), // Topluluk Oylaması rengi
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      );
      
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.width - textPainter.width) / 2,
          (size.height - textPainter.height) / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

