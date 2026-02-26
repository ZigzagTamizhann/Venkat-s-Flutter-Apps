import 'package:flutter/material.dart';
import 'dart:math';

class JoystickWidget extends StatefulWidget {
  final double size;
  final double maxSize;
  final Function(double x, double y) onChanged;
  
  const JoystickWidget({
    Key? key,
    required this.size,
    this.maxSize = 160,
    required this.onChanged,
  }) : super(key: key);
  
  @override
  _JoystickWidgetState createState() => _JoystickWidgetState();
}

class _JoystickWidgetState extends State<JoystickWidget> {
  double _x = 0.0, _y = 0.0;
  
  @override
  Widget build(BuildContext context) {
    double actualSize = min(widget.size, widget.maxSize);
    
    return GestureDetector(
      onPanUpdate: (d) {
        double r = actualSize / 2;
        double dx = d.localPosition.dx - r;
        double dy = d.localPosition.dy - r;
        double dist = sqrt(dx * dx + dy * dy);
        if (dist > r - 20) {
          double ratio = (r - 20) / dist;
          dx *= ratio; dy *= ratio;
        }
        setState(() { _x = dx; _y = dy; });
        widget.onChanged(_x / (r - 20), -_y / (r - 20));
      },
      onPanEnd: (d) {
        setState(() { _x = 0; _y = 0; });
        widget.onChanged(0, 0);
      },
      child: CustomPaint(
        size: Size(actualSize, actualSize),
        painter: JoystickPainter(x: _x, y: _y),
      ),
    );
  }
}

class JoystickPainter extends CustomPainter {
  final double x, y;
  JoystickPainter({required this.x, required this.y});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Outer circle
    final outerPaint = Paint()
      ..color = Color(0xFFFF6B35).withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, outerPaint);
    
    // Inner circle
    final innerPaint = Paint()
      ..color = Color(0xFFFF6B35).withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 8, innerPaint);
    
    // Cross lines
    final linePaint = Paint()
      ..color = Color(0xFFFF6B35).withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    // Vertical line
    canvas.drawLine(
      Offset(center.dx, 0),
      Offset(center.dx, size.height),
      linePaint,
    );
    
    // Horizontal line
    canvas.drawLine(
      Offset(0, center.dy),
      Offset(size.width, center.dy),
      linePaint,
    );
    
    // Center dot
    final centerPaint = Paint()
      ..color = Color(0xFFFF6B35).withOpacity(0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6, centerPaint);
    
    // Movable knob
    final knobPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final knobShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    final knobPosition = center + Offset(x, y);
    canvas.drawCircle(knobPosition, 18, knobShadowPaint);
    canvas.drawCircle(knobPosition, 16, knobPaint);
    
    // Knob center dot
    final knobCenterPaint = Paint()
      ..color = Color(0xFFFF6B35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(knobPosition, 5, knobCenterPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}