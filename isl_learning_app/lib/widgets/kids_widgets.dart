// lib/widgets/kids_widgets.dart
// Shared children-friendly UI components

import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─── Bubbly Gradient Button ───────────────────────────────────────────────────
class KidsButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final List<Color> gradient;
  final double fontSize;
  final EdgeInsets padding;
  final String? emoji;

  const KidsButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.gradient = const [AppColors.sky, Color(0xFF4A90E2)],
    this.fontSize = 18,
    this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
    this.emoji, required Color color,
  }) : super(key: key);

  @override
  State<KidsButton> createState() => _KidsButtonState();
}

class _KidsButtonState extends State<KidsButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween(begin: 1.0, end: 0.93).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.gradient,
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.first.withOpacity(0.45),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.emoji != null) ...[
                Text(widget.emoji!, style: TextStyle(fontSize: widget.fontSize)),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tap-Bounce Wrapper ───────────────────────────────────────────────────────
class TapBounce extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const TapBounce({Key? key, required this.child, required this.onTap}) : super(key: key);

  @override
  State<TapBounce> createState() => _TapBounceState();
}

class _TapBounceState extends State<TapBounce> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween(begin: 1.0, end: 0.92).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

// ─── Colorful Section Header ──────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String emoji;
  final String title;
  final Color color;

  const SectionHeader({Key? key, required this.emoji, required this.title, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Animated Stars / Confetti ───────────────────────────────────────────────
class FloatingStars extends StatefulWidget {
  final int count;
  final double size;

  const FloatingStars({Key? key, this.count = 8, this.size = 300}) : super(key: key);

  @override
  State<FloatingStars> createState() => _FloatingStarsState();
}

class _FloatingStarsState extends State<FloatingStars> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final Random _rng = Random();
  late List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    _stars = List.generate(widget.count, (_) => _Star(_rng));
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size, height: widget.size,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(painter: _StarPainter(_stars, _ctrl.value)),
      ),
    );
  }
}

class _Star {
  final double x, y, size, speed, phase;
  final Color color;

  _Star(Random r)
    : x = r.nextDouble(),
      y = r.nextDouble(),
      size = 4 + r.nextDouble() * 8,
      speed = 0.5 + r.nextDouble() * 0.5,
      phase = r.nextDouble() * 2 * pi,
      color = [
        AppColors.sunshine, AppColors.coral, AppColors.sky,
        AppColors.rose, AppColors.grape, AppColors.grass,
      ][r.nextInt(6)];
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final double t;

  _StarPainter(this.stars, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      final opacity = 0.4 + 0.6 * (0.5 + 0.5 * sin(t * 2 * pi * s.speed + s.phase));
      final paint = Paint()..color = s.color.withOpacity(opacity);
      final x = s.x * size.width;
      final y = s.y * size.height + sin(t * 2 * pi * s.speed + s.phase) * 8;
      canvas.drawCircle(Offset(x, y), s.size * opacity, paint);
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => true;
}

// ─── Kid-Friendly AppBar ──────────────────────────────────────────────────────
class KidsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String emoji;
  final List<Color> gradient;
  final List<Widget>? actions;
  final bool showBack;

  const KidsAppBar({
    Key? key,
    required this.title,
    required this.emoji,
    required this.gradient,
    this.actions,
    this.showBack = true,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: gradient.first.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (showBack && Navigator.canPop(context))
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                  ),
                )
              else
                const SizedBox(width: 36),
              Expanded(
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (actions != null) ...actions!
              else const SizedBox(width: 36),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Gradient Background ──────────────────────────────────────────────────────
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
          begin: begin, end: end,
          colors: colors ?? [AppColors.bgMain, AppColors.bgSoft],
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class GardenBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const GardenBackground({Key? key, required this.child, this.padding = EdgeInsets.zero}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [AppColors.sky, AppColors.grass],
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

// ─── Progress XP Bar ─────────────────────────────────────────────────────────
class XPBar extends StatelessWidget {
  final double progress;
  final List<Color> gradient;
  final double height;

  const XPBar({Key? key, required this.progress, required this.gradient, this.height = 10}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Stack(
        children: [
          Container(height: height, color: gradient.first.withOpacity(0.15)),
          FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(height),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Badge ──────────────────────────────────────────────────────────────
class StatBadge extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;

  const StatBadge({Key? key, required this.emoji, required this.value, required this.label, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: TextStyle(fontSize: 10, color: color.withOpacity(0.7), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}