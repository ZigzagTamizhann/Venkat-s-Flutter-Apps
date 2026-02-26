import 'package:flutter/material.dart';

class TrimButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  
  const TrimButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    required this.color,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}