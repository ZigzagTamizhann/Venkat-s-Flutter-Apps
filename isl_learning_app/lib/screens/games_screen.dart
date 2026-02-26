// lib/screens/games_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/kids_widgets.dart';
import '../models/sign_data.dart';
import 'sentence_game_screen.dart';
import 'camera_practice_screen.dart';
import 'spell_name_screen.dart';
import 'quick_recognition_screen.dart';
import 'flower_collector_screen.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({Key? key}) : super(key: key);
  @override State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..forward(); }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  PageRoute _r(Widget p) => PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (_, __, ___) => p,
    transitionsBuilder: (_, a, __, c) => SlideTransition(
      position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)), child: c),
  );

  @override
  Widget build(BuildContext context) {
    final games = [
      _G('✍️', 'Spell Your Name', 'Fingerspell your name letter by letter!', '🏅',
          const [Color(0xFF5BB8FF), Color(0xFF4A90E2)], const Color(0xFF5BB8FF),
          () => Navigator.push(context, _r(const SpellNameScreen()))),
      _G('⚡', 'Quick Recognition', 'Match sign → letter as fast as you can!', '🔥',
          const [Color(0xFFFFD93D), Color(0xFFFFA500)], const Color(0xFFFFD93D),
          () => Navigator.push(context, _r(const QuickRecognitionScreen()))),
      _G('💬', 'Sentence Builder', 'Sign complete sentences! Full power!', '💡',
          const [Color(0xFF5ECC7B), Color(0xFF2DB87A)], const Color(0xFF5ECC7B),
          () => Navigator.push(context, _r(const SentenceGameScreen()))),
      _G('📸', 'Camera Challenge', 'Show your signing to the camera!', '🎯',
          const [Color(0xFFFF7BAC), Color(0xFFE91E8C)], const Color(0xFFFF7BAC),
          () => Navigator.push(context, _r(CameraPracticeScreen(
            signData: SignData(letter: 'Practice', emoji: '🎯', funFact: 'Practice makes perfect!', description: 'Show your best signs'))))),
      _G('😊', 'Expression Gym', 'Match facial expressions with signs!', '🌟',
          const [Color(0xFFA855F7), Color(0xFF7C3AED)], const Color(0xFFA855F7),
          () => _showExpressions(context)),
      _G('🌸', 'Flower Collector', 'Pick the right sign to collect flowers!', '🌺',
          const [Color(0xFFFF9F7F), Color(0xFFFF6B6B)], const Color(0xFFFF9F7F),
          () => Navigator.push(context, _r(const FlowerCollectorScreen()))),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: KidsAppBar(title: 'Play & Practice', emoji: '🎮', gradient: const [Color(0xFFA855F7), Color(0xFF7C3AED)]),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: games.length,
        itemBuilder: (ctx, i) => AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final delay = i * 0.1;
            final t = ((_ctrl.value - delay) / (1 - delay.clamp(0, 0.7))).clamp(0.0, 1.0);
            final slide = 40 * (1 - Curves.easeOutCubic.transform(t));
            return Opacity(opacity: t, child: Transform.translate(offset: Offset(0, slide), child: _GameCard(g: games[i])));
          },
        ),
      ),
    );
  }

  void _showExpressions(BuildContext context) {
    final exps = [
      {'emoji': '😊', 'name': 'HAPPY', 'tip': 'Smile WIDE while signing HAPPY!'},
      {'emoji': '😢', 'name': 'SAD', 'tip': 'Drop your shoulders while signing SAD'},
      {'emoji': '😠', 'name': 'ANGRY', 'tip': 'Furrow your brows while signing ANGRY'},
      {'emoji': '😲', 'name': 'SURPRISED', 'tip': 'Open your eyes wide for SURPRISED!'},
    ];
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.82,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(children: [
          const SizedBox(height: 12),
          Container(width: 48, height: 5, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8))),
          const SizedBox(height: 18),
          const Text('😊 Expression Gym', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.grape)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text('Facial expressions are CRUCIAL in sign language! Match them perfectly 💪',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.textMid)),
          ),
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: exps.length,
            itemBuilder: (_, i) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.grape.withOpacity(0.06), AppColors.rose.withOpacity(0.06)]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.grape.withOpacity(0.15)),
              ),
              child: Row(children: [
                Text(exps[i]['emoji']!, style: const TextStyle(fontSize: 48)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(exps[i]['name']!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  Text(exps[i]['tip']!, style: const TextStyle(fontSize: 13, color: AppColors.textMid)),
                ])),
              ]),
            ),
          )),
          Padding(
            padding: const EdgeInsets.all(20),
            child: KidsButton(
              text: 'Got It!',
              emoji: '🎉',
              color: AppColors.grape,
              gradient: const [AppColors.grape, Color(0xFF7C3AED)],
              onTap: () => Navigator.pop(ctx),
            ),
          ),
        ]),
      ),
    );
  }
}

class _G {
  final String icon, title, desc, badge;
  final List<Color> gradient;
  final Color shadow;
  final VoidCallback onTap;
  const _G(this.icon, this.title, this.desc, this.badge, this.gradient, this.shadow, this.onTap);
}

class _GameCard extends StatefulWidget {
  final _G g;
  const _GameCard({required this.g});
  @override State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  @override
  void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100)); _scale = Tween(begin: 1.0, end: 0.94).animate(_ctrl); }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.g.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(scale: _scale, child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: widget.g.gradient),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: widget.g.shadow.withOpacity(0.32), blurRadius: 14, offset: const Offset(0, 6))],
        ),
        child: Row(children: [
          Container(
            width: 58, height: 58,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: Center(child: Text(widget.g.icon, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.g.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 3),
            Text(widget.g.desc, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85))),
          ])),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
            child: Text(widget.g.badge, style: const TextStyle(fontSize: 22)),
          ),
        ]),
      )),
    );
  }
}