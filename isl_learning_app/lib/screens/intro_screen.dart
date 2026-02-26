// lib/screens/intro_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_progress_service.dart';
import '../theme/app_theme.dart';
import 'avatar_customization_screen.dart';
import 'home_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);
  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with TickerProviderStateMixin {
  late AnimationController _bgCtrl, _logoCtrl, _textCtrl, _btnCtrl, _floatCtrl, _bubblesCtrl;
  late Animation<double> _logoScale, _logoRotate, _titleSlide, _titleFade, _subFade, _btnScale, _btnFade, _floatY;
  late Animation<Color?> _bgA, _bgB;

  final _rng = Random();
  late List<_Bubble> _bubbles;

  @override
  void initState() {
    super.initState();
    _bubbles = List.generate(20, (_) => _Bubble(_rng));

    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat(reverse: true);
    _bgA = ColorTween(begin: const Color(0xFF5BB8FF), end: const Color(0xFFA855F7)).animate(_bgCtrl);
    _bgB = ColorTween(begin: const Color(0xFFA855F7), end: const Color(0xFFFF7BAC)).animate(_bgCtrl);

    _bubblesCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _logoScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.9), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut));
    _logoRotate = Tween(begin: -0.15, end: 0.0)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));

    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _titleSlide = Tween(begin: 50.0, end: 0.0)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));
    _titleFade = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _textCtrl, curve: const Interval(0, 0.6)));
    _subFade = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _textCtrl, curve: const Interval(0.4, 1.0)));

    _btnCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _btnScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.12), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeOut));
    _btnFade = Tween(begin: 0.0, end: 1.0).animate(_btnCtrl);

    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat(reverse: true);
    _floatY = Tween(begin: -14.0, end: 14.0)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _logoCtrl.forward();
    Future.delayed(const Duration(milliseconds: 500), () { if (mounted) _textCtrl.forward(); });
    Future.delayed(const Duration(milliseconds: 1100), () { if (mounted) _btnCtrl.forward(); });

    _checkExisting();
  }

  Future<void> _checkExisting() async {
    final svc = Provider.of<UserProgressService>(context, listen: false);
    await svc.loadProgress();
    if (svc.avatar != null) {
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    for (final c in [_bgCtrl, _bubblesCtrl, _logoCtrl, _textCtrl, _btnCtrl, _floatCtrl]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressService = Provider.of<UserProgressService>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_bgCtrl, _bubblesCtrl, _floatCtrl]),
        builder: (ctx, _) => Container(
          width: double.infinity, height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [_bgA.value!, _bgB.value!, const Color(0xFFFFD93D).withOpacity(0.6)],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
          child: Stack(children: [
            // Floating bubbles
            ..._bubbles.map((b) {
              final t = (_bubblesCtrl.value * b.speed + b.phase / (2 * pi)) % 1.0;
              final dy = sin(t * 2 * pi) * 25;
              final dx = cos(t * 2 * pi + b.phase) * 12;
              return Positioned(
                left: b.x * size.width + dx,
                top: b.y * size.height + dy,
                child: Opacity(
                  opacity: 0.12 + 0.1 * sin(t * 2 * pi),
                  child: Container(
                    width: b.size, height: b.size,
                    decoration: BoxDecoration(color: b.color, shape: BoxShape.circle),
                  ),
                ),
              );
            }),

            // Sparkle emojis at corners
            _sparkle('✨', size.width * 0.08, size.height * 0.12, 0),
            _sparkle('⭐', size.width * 0.82, size.height * 0.08, 1),
            _sparkle('💫', size.width * 0.05, size.height * 0.52, 2),
            _sparkle('🌟', size.width * 0.88, size.height * 0.42, 3),
            _sparkle('✨', size.width * 0.12, size.height * 0.82, 4),
            _sparkle('⭐', size.width * 0.78, size.height * 0.78, 5),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Logo
                  AnimatedBuilder(
                    animation: _logoCtrl,
                    builder: (_, __) => Transform.scale(
                      scale: _logoScale.value,
                      child: Transform.rotate(
                        angle: _logoRotate.value,
                        child: _buildLogo(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Floating mascot hand
                  Transform.translate(
                    offset: Offset(0, _floatY.value),
                    child: Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                      ),
                      child: const Center(child: Text('👋', style: TextStyle(fontSize: 46))),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Title
                  AnimatedBuilder(
                    animation: _textCtrl,
                    builder: (_, __) => Opacity(
                      opacity: _titleFade.value,
                      child: Transform.translate(
                        offset: Offset(0, _titleSlide.value),
                        child: Column(children: [
                          Text(
                            'Sign with Joy!',
                            style: TextStyle(
                              fontSize: 16, color: Colors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w500, letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ShaderMask(
                            shaderCallback: (b) => const LinearGradient(
                              colors: [Colors.white, Color(0xFFFFE082)],
                            ).createShader(b),
                            child: const Text(
                              'ISL Learning',
                              style: TextStyle(
                                fontSize: 52, fontWeight: FontWeight.w900,
                                color: Colors.white, height: 1.0,
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Subtitle pill
                  AnimatedBuilder(
                    animation: _textCtrl,
                    builder: (_, __) => Opacity(
                      opacity: _subFade.value,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 48),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Text(
                          '🌟  Learn Indian Sign Language with Fun!  🌟',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Start Button
                  if (progressService.avatar == null)
                    AnimatedBuilder(
                      animation: _btnCtrl,
                      builder: (_, __) => Opacity(
                        opacity: _btnFade.value,
                        child: Transform.scale(
                          scale: _btnScale.value,
                          child: _buildStartBtn(context),
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Bottom emoji row
                  AnimatedBuilder(
                    animation: _btnCtrl,
                    builder: (_, __) => Opacity(
                      opacity: _btnFade.value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: ['🤟', '🌈', '🎉', '⭐', '🚀'].map((e) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            shape: BoxShape.circle,
                          ),
                          child: Center(child: Text(e, style: const TextStyle(fontSize: 20))),
                        )).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 150, height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 32, offset: const Offset(0, 14)),
          BoxShadow(color: const Color(0xFFFFD93D).withOpacity(0.55), blurRadius: 28, spreadRadius: 6),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/Logo.jpg',
          width: 150, height: 150,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🤟', style: TextStyle(fontSize: 56)),
              Text('ISL', style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w900,
                color: const Color(0xFF5BB8FF), letterSpacing: 4,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartBtn(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => const AvatarCustomizationScreen(),
          transitionsBuilder: (_, anim, __, child) => SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 24, offset: const Offset(0, 10)),
            BoxShadow(color: const Color(0xFFFFD93D).withOpacity(0.6), blurRadius: 20, spreadRadius: 2),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🚀', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 10),
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [Color(0xFF5BB8FF), Color(0xFFA855F7)],
              ).createShader(b),
              child: const Text(
                "Let's Start!",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sparkle(String emoji, double x, double y, int i) {
    return Positioned(
      left: x, top: y,
      child: AnimatedBuilder(
        animation: _bubblesCtrl,
        builder: (_, __) {
          final s = 0.6 + 0.4 * sin(_bubblesCtrl.value * 2 * pi + i * 1.1);
          return Transform.scale(
            scale: s,
            child: Opacity(opacity: s, child: Text(emoji, style: const TextStyle(fontSize: 24))),
          );
        },
      ),
    );
  }
}

class _Bubble {
  final double x, y, size, speed, phase;
  final Color color;
  _Bubble(Random r)
    : x = r.nextDouble(), y = r.nextDouble(),
      size = 18 + r.nextDouble() * 55, speed = 0.3 + r.nextDouble() * 0.7,
      phase = r.nextDouble() * 2 * pi,
      color = [AppColors.coral, AppColors.sunshine, AppColors.grass,
               AppColors.sky, AppColors.grape, AppColors.rose][r.nextInt(6)];
}