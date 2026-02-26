import 'package:flutter/material.dart';
import 'dart:ui';

class SliderPainter extends CustomPainter {
  final double offset;
  final bool isVertical;
  SliderPainter({required this.offset, required this.isVertical});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Track
    final trackPaint = Paint()
      ..color = Color(0xFFF0F0F0)
      ..style = PaintingStyle.fill;
    
    final trackRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: isVertical ? 36 : size.width,
        height: isVertical ? size.height : 36,
      ),
      Radius.circular(18),
    );
    canvas.drawRRect(trackRect, trackPaint);
    
    // Track border
    final borderPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(trackRect, borderPaint);
    
    // Gradient overlay
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: isVertical ? Alignment.topCenter : Alignment.centerLeft,
        end: isVertical ? Alignment.bottomCenter : Alignment.centerRight,
        colors: [
          Color(0xFFFF6B35).withOpacity(0.1),
          Color(0xFFFF6B35).withOpacity(0.3),
        ],
      ).createShader(trackRect.outerRect);
    canvas.drawRRect(trackRect, gradientPaint);
    
    // Knob with shadow
    final knobPosition = isVertical ? center + Offset(0, offset) : center + Offset(offset, 0);
    
    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..style = PaintingStyle.fill
      ..imageFilter = ImageFilter.blur(sigmaX: 3, sigmaY: 3);
    canvas.drawCircle(knobPosition, 18, shadowPaint);
    
    // Knob
    final knobPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(knobPosition, 16, knobPaint);
    
    // Knob border
    final knobBorderPaint = Paint()
      ..color = Color(0xFFFF6B35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(knobPosition, 16, knobBorderPaint);
    
    // Center line
    final linePaint = Paint()
      ..color = Color(0xFFFF6B35).withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    if (isVertical) {
      canvas.drawLine(
        Offset(center.dx, 0),
        Offset(center.dx, size.height),
        linePaint,
      );
    } else {
      canvas.drawLine(
        Offset(0, center.dy),
        Offset(size.width, center.dy),
        linePaint,
      );
    }
    
    // Center indicator
    final centerPaint = Paint()
      ..color = Color(0xFFFF6B35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3, centerPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}