import 'dart:math';
import 'package:flutter/material.dart';
import 'slider_painter.dart';

class VerticalSliderWidget extends StatefulWidget {
  final double height;
  final double maxHeight;
  final Function(double y) onChanged;
  
  const VerticalSliderWidget({
    Key? key,
    required this.height,
    this.maxHeight = 200,
    required this.onChanged, required Color color,
  }) : super(key: key);
  
  @override
  _VerticalSliderWidgetState createState() => _VerticalSliderWidgetState();
}

class _VerticalSliderWidgetState extends State<VerticalSliderWidget> {
  double _y = 0.0;
  
  @override
  void initState() {
    super.initState();
    _y = min(widget.height, widget.maxHeight) / 2 - 20;
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (d) {
        double limit = min(widget.height, widget.maxHeight) / 2 - 20;
        setState(() { _y = (_y + d.delta.dy).clamp(-limit, limit); });
        widget.onChanged(-_y / limit);
      },
      child: CustomPaint(
        size: Size(60, min(widget.height, widget.maxHeight)),
        painter: SliderPainter(offset: _y, isVertical: true),
      ),
    );
  }
}