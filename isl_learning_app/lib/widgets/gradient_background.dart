// lib/widgets/gradient_background.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final Alignment begin;
  final Alignment end;
  final EdgeInsets padding;

  const GradientBackground({
    Key? key,
    required this.child,
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors ?? [
            AppTheme.primaryBlue.withOpacity(0.1),
            AppTheme.primaryPurple.withOpacity(0.1),
            AppTheme.primaryPink.withOpacity(0.1),
          ],
        ),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

class GardenBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const GardenBackground({
    Key? key,
    required this.child,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.gardenSky,
            AppTheme.gardenGrass,
          ],
        ),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}