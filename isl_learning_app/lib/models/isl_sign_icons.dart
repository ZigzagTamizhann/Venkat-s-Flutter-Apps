import 'package:flutter/material.dart';

class ISLSignIcon extends StatelessWidget {
  final String letter;
  final double size;
  final Color? color;
  final Color? backgroundColor;

  const ISLSignIcon({
    super.key,
    required this.letter,
    this.size = 80,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Colors.white;
    final bgColor = backgroundColor ?? const Color(0xFF6C63FF); // Modern Purple

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.2), // Padding inside the icon box
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(size * 0.25), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _ISLFlatPainter(letter: letter, color: iconColor),
      ),
    );
  }
}

class _ISLFlatPainter extends CustomPainter {
  final String letter;
  final Color color;

  _ISLFlatPainter({required this.letter, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // We use a Path to create a merged, solid silhouette
    final Path path = Path();
    
    // Scale helper based on canvas size
    final double w = size.width;
    final double h = size.height;
    final Offset center = Offset(w / 2, h / 2);

    switch (letter.toUpperCase()) {
      case 'A': // Fist
        _drawFist(path, w, h, thumbSide: true);
        break;
      case 'B': // Flat hand
        _drawOpenPalm(path, w, h, thumbIn: true);
        break;
      case 'C': // C Shape
        _drawCShape(path, w, h);
        break;
      case 'D': // Pointing Up
        _drawPointingUp(path, w, h);
        break;
      case 'E': // Claw/Fist
        _drawFist(path, w, h, thumbSide: false); // Tight fist
        break;
      case 'F': // OK Sign
        _drawOKSign(path, w, h);
        break;
      case 'G': // Pointing Side
        _drawPointingSide(path, w, h);
        break;
      case 'H': // Two Fingers Side
        _drawTwoFingersSide(path, w, h);
        break;
      case 'I': // Pinky Up
        _drawPinkyUp(path, w, h);
        break;
      case 'L': // L Shape
        _drawLShape(path, w, h);
        break;
      case 'O': // Circle
        _drawCircleHand(path, w, h);
        break;
      case 'U': // Two Fingers Up
        _drawTwoFingersUp(path, w, h, spread: false);
        break;
      case 'V': // Victory
        _drawTwoFingersUp(path, w, h, spread: true);
        break;
      case 'W': // Three Fingers
        _drawThreeFingers(path, w, h);
        break;
      case 'Y': // Thumb & Pinky
        _drawY(path, w, h);
        break;
      // case '0':
      //   _drawCircleHand(path, w, h);
      //   break;
      // case '1':
      //   _drawPointingUp(path, w, h);
      //   break;
      // case '2':
      //   _drawTwoFingersUp(path, w, h, spread: true);
      //   break;
      // case '3':
      //   _drawThreeFingers(path, w, h);
      //   break;
      // case '4':
      //   _drawOpenPalm(path, w, h, thumbIn: true);
      //   break;
      // case '5':
      //   _drawOpenPalm(path, w, h, thumbIn: false);
      //   break;
      // case '6':
      //   _drawY(path, w, h);
      //   break;
      // case '7':
      //   _drawLShape(path, w, h);
      //   break;
      // case '8':
      //   _drawPinkyUp(path, w, h);
      //   break;
      // case '9':
      //   _drawOKSign(path, w, h);
      //   break;
      default:
        // Default generic hand for other letters to keep code short
        _drawOpenPalm(path, w, h, thumbIn: false);
    }

    // Draw the final merged shape
    canvas.drawPath(path, paint);
  }

  // --- SHAPE BUILDERS (Reusable) ---

  // A: Fist Shape
  void _drawFist(Path path, double w, double h, {bool thumbSide = false}) {
    // Main Fist Box
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.6), width: w * 0.6, height: h * 0.6),
      Radius.circular(w * 0.2),
    ));

    if (thumbSide) {
      // Thumb on side (A)
      path.addOval(Rect.fromCenter(
        center: Offset(w * 0.75, h * 0.4), width: w * 0.2, height: h * 0.35));
    }
  }

  // B: Open Palm (Fingers together)
  void _drawOpenPalm(Path path, double w, double h, {bool thumbIn = false}) {
    // Palm Base
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.7), width: w * 0.5, height: h * 0.4),
      Radius.circular(w * 0.1),
    ));

    // 4 Fingers fused
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.35), width: w * 0.5, height: h * 0.5),
      Radius.circular(w * 0.15),
    ));

    // Thumb
    if (thumbIn) {
      // Thumb folded across
       path.addOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.8), width: w * 0.4, height: h * 0.15));
    } else {
       // Thumb out
       path.addOval(Rect.fromCenter(center: Offset(w * 0.8, h * 0.6), width: w * 0.2, height: h * 0.3));
    }
  }

  // C: Curved Hand
  void _drawCShape(Path path, double w, double h) {
    // Using a thick stroke converted to path conceptually, but here manually
    path.moveTo(w * 0.7, h * 0.2);
    path.quadraticBezierTo(w * 0.2, h * 0.2, w * 0.2, h * 0.5); // Top curve
    path.quadraticBezierTo(w * 0.2, h * 0.8, w * 0.7, h * 0.8); // Bottom curve
    path.lineTo(w * 0.7, h * 0.6); // Thickness return
    path.quadraticBezierTo(w * 0.45, h * 0.6, w * 0.45, h * 0.5); // Inner bottom
    path.quadraticBezierTo(w * 0.45, h * 0.4, w * 0.7, h * 0.4); // Inner top
    path.close();
  }

  // D: Index Up
  void _drawPointingUp(Path path, double w, double h) {
    // Fist Base
    path.addOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.65), width: w * 0.55, height: h * 0.5));
    // Index Finger
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.3), width: w * 0.18, height: h * 0.5),
      Radius.circular(w * 0.09),
    ));
  }

  // F: OK Sign
  void _drawOKSign(Path path, double w, double h) {
    // 3 Fingers Up
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.35, h * 0.3), width: w * 0.15, height: h * 0.45),
      Radius.circular(w * 0.1),
    ));
     path.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.52, h * 0.3), width: w * 0.15, height: h * 0.45),
      Radius.circular(w * 0.1),
    ));
     path.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.69, h * 0.35), width: w * 0.15, height: h * 0.4),
      Radius.circular(w * 0.1),
    ));
    
    // Circle (Thumb + Index)
    path.addOval(Rect.fromCenter(center: Offset(w * 0.6, h * 0.7), width: w * 0.4, height: h * 0.4));
    // Cutout (Visual trick: We can't do cutout easily in simple Path without boolean ops, 
    // so we just draw the solid shape. For a true icon, the solid silhouette implies the hole).
  }
  
  // L: L Shape
  void _drawLShape(Path path, double w, double h) {
     // Index
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.4, h * 0.4), width: w * 0.18, height: h * 0.6),
      Radius.circular(w * 0.09),
    ));
    // Thumb
     path.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.6, h * 0.75), width: w * 0.5, height: h * 0.18),
      Radius.circular(w * 0.09),
    ));
  }

  // V & U
  void _drawTwoFingersUp(Path path, double w, double h, {required bool spread}) {
    // Fist Base
    path.addOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.7), width: w * 0.5, height: h * 0.4));
    
    double offset = spread ? w * 0.15 : w * 0.08;

    // Finger 1
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5 - offset, h * 0.4), width: w * 0.16, height: h * 0.5),
      Radius.circular(w * 0.08),
    ));
    
    // Finger 2
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5 + offset, h * 0.4), width: w * 0.16, height: h * 0.5),
      Radius.circular(w * 0.08),
    ));
  }
  
  // I: Pinky
  void _drawPinkyUp(Path path, double w, double h) {
     // Fist
    path.addOval(Rect.fromCenter(center: Offset(w * 0.4, h * 0.6), width: w * 0.5, height: h * 0.5));
    // Pinky
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.7, h * 0.4), width: w * 0.15, height: h * 0.5),
      Radius.circular(w * 0.08),
    ));
  }
  
  // W
  void _drawThreeFingers(Path path, double w, double h) {
     path.addOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.75), width: w * 0.5, height: h * 0.4));
     
     for(int i=-1; i<=1; i++) {
        path.addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.5 + (i * w * 0.18), h * 0.45), width: w * 0.15, height: h * 0.5),
        Radius.circular(w * 0.08),
      ));
     }
  }

  // Y
  void _drawY(Path path, double w, double h) {
    path.addOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.5), width: w * 0.5, height: h * 0.4)); // Fist
    // Pinky
    path.addOval(Rect.fromCenter(center: Offset(w * 0.8, h * 0.4), width: w * 0.15, height: h * 0.4));
    // Thumb
    path.addOval(Rect.fromCenter(center: Offset(w * 0.2, h * 0.4), width: w * 0.15, height: h * 0.4));
  }

  // O
  void _drawCircleHand(Path path, double w, double h) {
     path.addOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.5), width: w * 0.7, height: h * 0.7));
     // Note: In a filled icon, 'O' is just a solid circle. 
     // To make it look like a hand 'O', we add a small notch at the bottom visually
     path.addRect(Rect.fromCenter(center: Offset(w*0.5, h*0.85), width: w*0.3, height: h*0.2));
  }
  
  // G
  void _drawPointingSide(Path path, double w, double h) {
    path.addOval(Rect.fromCenter(center: Offset(w * 0.3, h * 0.5), width: w * 0.4, height: h * 0.5)); // Fist
    // Index
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.6, h * 0.4), width: w * 0.5, height: h * 0.18),
      Radius.circular(w * 0.09),
    ));
  }
  
  // H
  void _drawTwoFingersSide(Path path, double w, double h) {
    path.addOval(Rect.fromCenter(center: Offset(w * 0.3, h * 0.5), width: w * 0.4, height: h * 0.5)); // Fist
    // Fingers
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.6, h * 0.4), width: w * 0.5, height: h * 0.25),
      Radius.circular(w * 0.09),
    ));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}