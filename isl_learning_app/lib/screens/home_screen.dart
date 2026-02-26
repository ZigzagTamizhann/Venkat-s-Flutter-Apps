// lib/screens/home_screen.dart
// import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_progress_service.dart';
import '../widgets/avatar_display.dart';
import '../widgets/kids_widgets.dart';
import '../theme/app_theme.dart';
import 'alphabet_garden_screen.dart';
import 'games_screen.dart';
import 'number_learning_screen.dart';
import 'story_screen.dart';
import 'daily_quests_screen.dart';
import 'settings_screen.dart';
import 'progress_screen.dart';
import 'parent_review_screen.dart';
import 'word_learning_screen.dart';
// import 'intro_screen.dart';
import 'sentence_game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _entranceCtrl, _bgCtrl;
  late Animation<Color?> _bgColor;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);
    _bgColor = ColorTween(
      begin: const Color(0xFFF0F9FF), end: const Color(0xFFF5F0FF),
    ).animate(_bgCtrl);
  }

  @override
  void dispose() { _entranceCtrl.dispose(); _bgCtrl.dispose(); super.dispose(); }

  PageRoute _r(Widget page) => PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, anim, __, child) => SlideTransition(
      position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
          .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final svc = Provider.of<UserProgressService>(context);
    final avatar = svc.avatar!;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgCtrl,
        builder: (_, __) => Container(
          color: _bgColor.value,
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                // ── TOP BAR ──────────────────────────────────────────────
                SliverToBoxAdapter(child: _topBar(context, svc)),

                // ── HERO CARD ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: _animated(0, _heroCard(context, avatar, svc)),
                ),

                // ── STATS ROW ─────────────────────────────────────────────
                SliverToBoxAdapter(child: _animated(1, _statsRow(svc))),

                // ── SECTION TITLE ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: _animated(2, const Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
                    child: SectionHeader(emoji: '🎯', title: "Let's Learn!", color: AppColors.sky),
                  )),
                ),

                // ── MENU GRID ─────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14,
                      childAspectRatio: 1.0,
                    ),
                    delegate: SliverChildListDelegate(_menuCards(context, svc)),
                  ),
                ),

                // ── DAILY QUEST BANNER ────────────────────────────────────
                SliverToBoxAdapter(child: _animated(5, _questBanner(context, svc))),

                const SliverToBoxAdapter(child: SizedBox(height: 28)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _animated(int index, Widget child) {
    return AnimatedBuilder(
      animation: _entranceCtrl,
      builder: (_, __) {
        final delay = index * 0.1;
        final t = ((_entranceCtrl.value - delay) / (1.0 - delay.clamp(0.0, 0.8))).clamp(0.0, 1.0);
        final slide = 40.0 * (1 - Curves.easeOutCubic.transform(t));
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(offset: Offset(0, slide), child: child),
        );
      },
    );
  }

  Widget _topBar(BuildContext context, UserProgressService svc) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          // Logo badge
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: AppColors.sky.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/Logo.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.sky, AppColors.grape]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text('🤟', style: TextStyle(fontSize: 20)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text('ISL Learning', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const Spacer(),
          _iconBtn(Icons.emoji_events_rounded, AppColors.sunshine, () => Navigator.push(context, _r(const ProgressScreen()))),
          const SizedBox(width: 8),
          _iconBtn(Icons.supervisor_account_rounded, AppColors.mint, () => Navigator.push(context, _r(const ParentReviewScreen()))),
          const SizedBox(width: 8),
          _iconBtn(Icons.settings_rounded, AppColors.grape, () => Navigator.push(context, _r(const SettingsScreen()))),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return TapBounce(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _heroCard(BuildContext context, avatar, UserProgressService svc) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF5BB8FF), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: const Color(0xFF5BB8FF).withOpacity(0.4), blurRadius: 22, offset: const Offset(0, 10))],
      ),
      child: Stack(
        children: [
          // BG decoration circles
          Positioned(right: -20, top: -20, child: Container(
            width: 100, height: 100,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), shape: BoxShape.circle),
          )),
          Positioned(right: 30, bottom: -30, child: Container(
            width: 70, height: 70,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), shape: BoxShape.circle),
          )),
          Row(
            children: [
              // Avatar ring
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: AvatarDisplay(avatar: avatar, size: 74),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hi ${avatar.name}! 👋', style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white,
                  )),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '⭐ Lv.${svc.level} · ${svc.getLevelTitle()}',
                      style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 10),
                  XPBar(
                    progress: svc.completedLetters.length / 26,
                    gradient: const [Color(0xFFFFD93D), Color(0xFFFFA500)],
                  ),
                  const SizedBox(height: 4),
                  Text('${svc.completedLetters.length}/26 letters learned 📚',
                    style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.88))),
                ],
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statsRow(UserProgressService svc) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Row(
        children: [
          Expanded(child: StatBadge(emoji: '🏆', value: '${svc.points}', label: 'Points', color: AppColors.sunshine)),
          const SizedBox(width: 10),
          Expanded(child: StatBadge(emoji: '🔥', value: '${svc.streak}', label: 'Streak', color: AppColors.coral)),
          const SizedBox(width: 10),
          Expanded(child: StatBadge(emoji: '🎖️', value: '${svc.badges.length}', label: 'Badges', color: AppColors.grape)),
          const SizedBox(width: 10),
          Expanded(child: StatBadge(emoji: '📖', value: '${svc.storiesCompleted}', label: 'Stories', color: AppColors.mint)),
        ],
      ),
    );
  }

  List<Widget> _menuCards(BuildContext context, UserProgressService svc) {
    final items = [
      _MenuItem('🌸', 'Alphabet Garden', 'A–Z Signs',
          const [Color(0xFF5ECC7B), Color(0xFF2DB87A)], const Color(0xFF5ECC7B),
          () => Navigator.push(context, _r(const AlphabetGardenScreen()))),
      _MenuItem('🔢', 'Number Park', '0–9 Signs',
          const [Color(0xFFFF9F7F), Color(0xFFFF6B6B)], const Color(0xFFFF9F7F),
          () => Navigator.push(context, _r(const NumberLearningScreen()))),
      _MenuItem('🌳', 'Daily Signs', 'Words & Phrases',
          const [Color(0xFF5BB8FF), Color(0xFF4A90E2)], const Color(0xFF5BB8FF),
          () => Navigator.push(context, _r(const WordLearningScreen()))),
      _MenuItem('🎮', 'Games', 'Play & Practice',
          const [Color(0xFFA855F7), Color(0xFF7C3AED)], const Color(0xFFA855F7),
          () => Navigator.push(context, _r(const GamesScreen()))),
      _MenuItem('📝', 'Sentence Builder', 'Form Sentences',
          const [Color(0xFF42E695), Color(0xFF3BB2B8)], const Color(0xFF42E695),
          () => Navigator.push(context, _r(const SentenceGameScreen()))),
      _MenuItem('📖', 'Stories', 'Sign Language Tales',
          const [Color(0xFFFFD93D), Color(0xFFFFA500)], const Color(0xFFFFD93D),
          () => Navigator.push(context, _r(const StoryScreen()))),
      _MenuItem('🎯', 'Daily Quests', 'Complete Goals!',
          const [Color(0xFFFF7BAC), Color(0xFFE91E8C)], const Color(0xFFFF7BAC),
          () => Navigator.push(context, _r(const DailyQuestsScreen()))),
    ];

    return items.asMap().entries.map((e) {
      final i = e.key; final item = e.value;
      return AnimatedBuilder(
        animation: _entranceCtrl,
        builder: (_, __) {
          final delay = 0.25 + i * 0.07;
          final t = ((_entranceCtrl.value - delay) / (1 - delay.clamp(0.0, 0.6))).clamp(0.0, 1.0);
          final curve = Curves.easeOutBack.transform(t);
          return Opacity(opacity: t, child: Transform.scale(scale: 0.6 + 0.4 * curve, child: _MenuCard(item: item)));
        },
      );
    }).toList();
  }

  Widget _questBanner(BuildContext context, UserProgressService svc) {
    return TapBounce(
      onTap: () => Navigator.push(context, _r(const DailyQuestsScreen())),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFFFFD93D), Color(0xFFFFA500)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: const Color(0xFFFFD93D).withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 6))],
        ),
        child: Row(children: [
          const Text('🌟', style: TextStyle(fontSize: 44)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Today's Mission!", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF5D3A00))),
            Text(
              svc.completedLetters.length < 26
                  ? 'Learn 2 more letters to level up! 🚀'
                  : 'Play a game and earn bonus stars! ⭐',
              style: const TextStyle(fontSize: 12, color: Color(0xFF7A4F00), fontWeight: FontWeight.w500),
            ),
          ])),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF5D3A00)),
          ),
        ]),
      ),
    );
  }
}

class _MenuItem {
  final String icon, title, sub;
  final List<Color> gradient;
  final Color shadow;
  final VoidCallback onTap;
  const _MenuItem(this.icon, this.title, this.sub, this.gradient, this.shadow, this.onTap);
}

class _MenuCard extends StatefulWidget {
  final _MenuItem item;
  const _MenuCard({required this.item});
  @override State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween(begin: 1.0, end: 0.93).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.item.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: widget.item.gradient,
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [BoxShadow(color: widget.item.shadow.withOpacity(0.38), blurRadius: 14, offset: const Offset(0, 7))],
          ),
          child: Stack(children: [
            Positioned(right: -15, bottom: -15, child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
            )),
            Positioned(right: 12, top: 10, child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
            )),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.item.icon, style: const TextStyle(fontSize: 38)),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.item.title, style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1,
                    )),
                    Text(widget.item.sub, style: TextStyle(
                      fontSize: 11, color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.w500,
                    )),
                  ]),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}