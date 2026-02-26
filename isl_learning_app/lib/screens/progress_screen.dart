// lib/screens/progress_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_progress_service.dart';
import '../widgets/avatar_display.dart';
import '../widgets/kids_widgets.dart';
import '../theme/app_theme.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);
  @override State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward(); }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Widget _anim(int i, Widget child) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) {
      final delay = i * 0.1;
      final t = ((_ctrl.value - delay) / (1 - delay.clamp(0, 0.7))).clamp(0.0, 1.0);
      return Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 30 * (1 - Curves.easeOutCubic.transform(t))), child: child));
    },
  );

  @override
  Widget build(BuildContext context) {
    final svc = Provider.of<UserProgressService>(context);
    final avatar = svc.avatar!;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: KidsAppBar(title: 'My Progress', emoji: '🏆', gradient: const [Color(0xFFFFD93D), Color(0xFFFFA500)]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Avatar + Level card
          _anim(0, Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFFFFD93D), Color(0xFFFFA500)]),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [BoxShadow(color: const Color(0xFFFFD93D).withOpacity(0.4), blurRadius: 18, offset: const Offset(0, 8))],
            ),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
                child: AvatarDisplay(avatar: avatar, size: 90),
              ),
              const SizedBox(height: 12),
              Text(avatar.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF5D3A00))),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(20)),
                child: Text('⭐ Level ${svc.level} • ${svc.getLevelTitle()}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF5D3A00))),
              ),
              const SizedBox(height: 14),
              XPBar(progress: svc.completedLetters.length / 26, gradient: const [Color(0xFFFFFFFF), Color(0xFFFFE082)], height: 10),
              const SizedBox(height: 4),
              Text('${svc.completedLetters.length}/26 letters mastered',
                style: const TextStyle(fontSize: 13, color: Color(0xFF7A4F00), fontWeight: FontWeight.w600)),
            ]),
          )),

          const SizedBox(height: 16),

          // Stats grid
          _anim(1, GridView.count(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5,
            children: [
              _statCard('⭐', '${svc.points}', 'Total Points', AppColors.sunshine, const [Color(0xFFFFF9E6), Color(0xFFFFF3C4)]),
              _statCard('🔥', '${svc.streak}', 'Day Streak', AppColors.coral, const [Color(0xFFFFEEEE), Color(0xFFFFD6D6)]),
              _statCard('📚', '${svc.completedLetters.length}', 'Signs Learned', AppColors.sky, const [Color(0xFFE6F4FF), Color(0xFFCCE9FF)]),
              _statCard('🎖️', '${svc.badges.length}', 'Badges Earned', AppColors.grape, const [Color(0xFFF3E8FF), Color(0xFFE8D4FF)]),
              _statCard('📖', '${svc.storiesCompleted}', 'Stories Read', AppColors.grass, const [Color(0xFFEBFFEF), Color(0xFFD4F7DC)]),
              _statCard('💬', '${svc.completedWords.length}', 'Words Learned', AppColors.mint, const [Color(0xFFE6FFF9), Color(0xFFCCF7EE)]),
            ],
          )),

          const SizedBox(height: 16),

          // Badges section
          _anim(2, _badgesSection(svc)),

          // Completed letters
          if (svc.completedLetters.isNotEmpty) ...[
            const SizedBox(height: 16),
            _anim(3, _lettersSection(svc)),
          ],
        ]),
      ),
    );
  }

  Widget _statCard(String emoji, String value, String label, Color color, List<Color> bgColors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: bgColors),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: TextStyle(fontSize: 11, color: color.withOpacity(0.7), fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _badgesSection(UserProgressService svc) {
    final allBadges = [
      {'id': 'alphabet_master', 'name': 'Alphabet Master', 'emoji': '🏆', 'desc': 'Learned all 26 letters'},
      {'id': 'story_hero', 'name': 'Story Hero', 'emoji': '📖', 'desc': 'Completed 10 stories'},
      {'id': 'streak_star', 'name': 'Streak Star', 'emoji': '🔥', 'desc': '7-day streak'},
      {'id': 'game_champ', 'name': 'Game Champ', 'emoji': '🎮', 'desc': 'Played all games'},
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.grape.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeader(emoji: '🎖️', title: 'Badges', color: AppColors.grape),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12, runSpacing: 12,
          children: allBadges.map((b) {
            final earned = svc.badges.contains(b['id']);
            return Container(
              width: 80,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: earned ? AppColors.grape.withOpacity(0.1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: earned ? AppColors.grape.withOpacity(0.3) : Colors.grey.shade200),
              ),
              child: Column(children: [
                Opacity(opacity: earned ? 1.0 : 0.3, child: Text(b['emoji']!, style: const TextStyle(fontSize: 30))),
                const SizedBox(height: 4),
                Text(b['name']!, textAlign: TextAlign.center, style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700,
                  color: earned ? AppColors.grape : Colors.grey.shade400,
                )),
              ]),
            );
          }).toList(),
        ),
      ]),
    );
  }

  Widget _lettersSection(UserProgressService svc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.grass.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionHeader(emoji: '🌸', title: 'Letters Mastered', color: AppColors.grass),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: svc.completedLetters.map((l) => Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF5ECC7B), Color(0xFF2DB87A)]),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: const Color(0xFF5ECC7B).withOpacity(0.35), blurRadius: 6, offset: const Offset(0, 3))],
            ),
            child: Center(child: Text(l, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white))),
          )).toList(),
        ),
      ]),
    );
  }
}