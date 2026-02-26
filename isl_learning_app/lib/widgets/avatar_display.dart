// lib/widgets/avatar_display.dart
import 'package:flutter/material.dart';
import '../models/user_avatar.dart';

class AvatarDisplay extends StatelessWidget {
  final UserAvatar avatar;
  final double size;
  final String? emotion;

  const AvatarDisplay({Key? key, required this.avatar, this.size = 120, this.emotion}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isFemale = avatar.gender == 'female';
    final isHappy  = emotion == null || emotion == 'happy';

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          isFemale
              ? _FemaleAvatar(skin: avatar.skinColor, hair: avatar.hairColor, shirt: avatar.shirtColor, size: size, isHappy: isHappy)
              : _MaleAvatar(skin: avatar.skinColor, hair: avatar.hairColor, shirt: avatar.shirtColor, size: size, isHappy: isHappy),

          if (isHappy)
            Positioned(
              top: 0, right: 0,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (_, v, __) => Opacity(
                  opacity: v.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: v.clamp(0.0, 1.4),
                    child: Text('✨', style: TextStyle(fontSize: size * 0.18)),
                  ),
                ),
              ),
            ),

          if (emotion == 'sad')
            Positioned(
              bottom: size * 0.22, left: size * 0.18,
              child: Text('💧', style: TextStyle(fontSize: size * 0.12)),
            ),
        ],
      ),
    );
  }
}

// ─── MALE AVATAR ──────────────────────────────────────────────────────────────
class _MaleAvatar extends StatelessWidget {
  final Color skin, hair, shirt;
  final double size;
  final bool isHappy;
  const _MaleAvatar({required this.skin, required this.hair, required this.shirt, required this.size, required this.isHappy});

  @override
  Widget build(BuildContext context) {
    final s = size;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ── HEAD ──────────────────────────────────────────────────────
        SizedBox(
          width: s * 0.52,
          height: s * 0.48,
          child: Stack(alignment: Alignment.center, children: [

            // Hair (short — top block)
            Positioned(
              top: 0,
              child: Container(
                width: s * 0.48,
                height: s * 0.22,
                decoration: BoxDecoration(
                  color: hair,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(100)),
                ),
              ),
            ),

            // Face circle
            Positioned(
              bottom: 0,
              child: Container(
                width: s * 0.52,
                height: s * 0.40,
                decoration: BoxDecoration(
                  color: skin,
                  borderRadius: BorderRadius.circular(s * 0.14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 4),
                    // Eyes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _Eye(size: s, isHappy: isHappy),
                        SizedBox(width: s * 0.10),
                        _Eye(size: s, isHappy: isHappy),
                      ],
                    ),
                    SizedBox(height: s * 0.02),
                    // Mouth
                    _Mouth(size: s, isHappy: isHappy),
                  ],
                ),
              ),
            ),

          ]),
        ),

        SizedBox(height: s * 0.01),

        // ── BODY / SHIRT ──────────────────────────────────────────────
        Container(
          width: s * 0.54,
          height: s * 0.28,
          decoration: BoxDecoration(
            color: shirt,
            borderRadius: BorderRadius.circular(s * 0.08),
          ),
          child: Center(
            child: Text('👕', style: TextStyle(fontSize: s * 0.14)),
          ),
        ),
      ],
    );
  }
}

// ─── FEMALE AVATAR ────────────────────────────────────────────────────────────
class _FemaleAvatar extends StatelessWidget {
  final Color skin, hair, shirt;
  final double size;
  final bool isHappy;
  const _FemaleAvatar({required this.skin, required this.hair, required this.shirt, required this.size, required this.isHappy});

  @override
  Widget build(BuildContext context) {
    final s = size;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ── HEAD ──────────────────────────────────────────────────────
        SizedBox(
          width: s * 0.60,
          height: s * 0.50,
          child: Stack(alignment: Alignment.center, children: [

            // Long hair left
            Positioned(
              left: 0, top: s * 0.10,
              child: Container(
                width: s * 0.10,
                height: s * 0.38,
                decoration: BoxDecoration(
                  color: hair,
                  borderRadius: BorderRadius.circular(s * 0.06),
                ),
              ),
            ),

            // Long hair right
            Positioned(
              right: 0, top: s * 0.10,
              child: Container(
                width: s * 0.10,
                height: s * 0.38,
                decoration: BoxDecoration(
                  color: hair,
                  borderRadius: BorderRadius.circular(s * 0.06),
                ),
              ),
            ),

            // Hair top
            Positioned(
              top: 0,
              child: Container(
                width: s * 0.46,
                height: s * 0.22,
                decoration: BoxDecoration(
                  color: hair,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(100)),
                ),
              ),
            ),

            // Face
            Positioned(
              bottom: 0,
              child: Container(
                width: s * 0.48,
                height: s * 0.40,
                decoration: BoxDecoration(
                  color: skin,
                  borderRadius: BorderRadius.circular(s * 0.14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 4),
                    // Eyes (bigger for girl)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _Eye(size: s * 1.1, isHappy: isHappy),
                        SizedBox(width: s * 0.09),
                        _Eye(size: s * 1.1, isHappy: isHappy),
                      ],
                    ),
                    SizedBox(height: s * 0.02),
                    // Mouth
                    _Mouth(size: s, isHappy: isHappy),
                    // Blush
                    if (isHappy) ...[
                      SizedBox(height: s * 0.01),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        _Blush(s),
                        SizedBox(width: s * 0.14),
                        _Blush(s),
                      ]),
                    ],
                  ],
                ),
              ),
            ),

          ]),
        ),

        SizedBox(height: s * 0.01),

        // ── DRESS ─────────────────────────────────────────────────────
        Container(
          width: s * 0.56,
          height: s * 0.28,
          decoration: BoxDecoration(
            color: shirt,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(s * 0.06),
              topRight: Radius.circular(s * 0.06),
              bottomLeft: Radius.circular(s * 0.16),
              bottomRight: Radius.circular(s * 0.16),
            ),
          ),
          child: Center(
            child: Text('🎀', style: TextStyle(fontSize: s * 0.14)),
          ),
        ),
      ],
    );
  }
}

// ─── SHARED SMALL WIDGETS ─────────────────────────────────────────────────────
class _Eye extends StatelessWidget {
  final double size;
  final bool isHappy;
  const _Eye({required this.size, required this.isHappy});

  @override
  Widget build(BuildContext context) {
    final r = size * 0.065;
    if (isHappy) {
      // Happy = arc (^_^)
      return SizedBox(
        width: r * 2, height: r,
        child: CustomPaint(painter: _HappyEyePainter()),
      );
    }
    return Container(
      width: r * 2, height: r * 2,
      decoration: const BoxDecoration(color: Color(0xFF2C1810), shape: BoxShape.circle),
      child: Center(
        child: Container(
          width: r * 0.5, height: r * 0.5,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

class _HappyEyePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2C1810)
      ..strokeWidth = size.height * 0.55
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(size.width * 0.5, 0, size.width, size.height);
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(_) => false;
}

class _Mouth extends StatelessWidget {
  final double size;
  final bool isHappy;
  const _Mouth({required this.size, required this.isHappy});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size * 0.18, size * 0.08),
      painter: _MouthPainter(isHappy: isHappy),
    );
  }
}

class _MouthPainter extends CustomPainter {
  final bool isHappy;
  _MouthPainter({required this.isHappy});

  @override
  void paint(Canvas canvas, Size sz) {
    final paint = Paint()
      ..color = const Color(0xFFE57373)
      ..strokeWidth = sz.height * 0.55
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (isHappy) {
      path.moveTo(0, 0);
      path.quadraticBezierTo(sz.width * 0.5, sz.height, sz.width, 0);
    } else {
      path.moveTo(0, sz.height);
      path.quadraticBezierTo(sz.width * 0.5, 0, sz.width, sz.height);
    }
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(_MouthPainter o) => o.isHappy != isHappy;
}

class _Blush extends StatelessWidget {
  final double size;
  const _Blush(this.size);
  @override
  Widget build(BuildContext context) => Container(
    width: size * 0.10,
    height: size * 0.05,
    decoration: BoxDecoration(
      color: Colors.pinkAccent.withOpacity(0.35),
      borderRadius: BorderRadius.circular(size),
    ),
  );
}