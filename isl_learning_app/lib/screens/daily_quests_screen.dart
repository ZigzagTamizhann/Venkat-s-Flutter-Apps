// lib/screens/daily_quests_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/kids_widgets.dart';

class DailyQuestsScreen extends StatefulWidget {
  const DailyQuestsScreen({Key? key}) : super(key: key);
  @override State<DailyQuestsScreen> createState() => _DailyQuestsScreenState();
}

class _DailyQuestsScreenState extends State<DailyQuestsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final List<Map<String, dynamic>> _quests = [
    {'icon': '🌅', 'title': 'Open the app today!', 'points': 5, 'done': true, 'color': AppColors.sunshine},
    {'icon': '📚', 'title': 'Learn 3 new signs', 'points': 15, 'done': false, 'color': AppColors.sky},
    {'icon': '🎮', 'title': 'Play one game', 'points': 10, 'done': false, 'color': AppColors.grape},
    {'icon': '🌸', 'title': 'Visit Alphabet Garden', 'points': 5, 'done': false, 'color': AppColors.grass},
    {'icon': '📖', 'title': 'Read a story', 'points': 20, 'done': false, 'color': AppColors.peach},
  ];

  @override
  void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward(); }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final completed = _quests.where((q) => q['done'] == true).length;
    final totalPts = _quests.where((q) => q['done'] == true).fold(0, (s, q) => s + (q['points'] as int));

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: KidsAppBar(title: 'Daily Quests', emoji: '🎯', gradient: const [Color(0xFFFFD93D), Color(0xFFFFA500)]),
      body: Column(children: [
        // Summary card
        Container(
          margin: const EdgeInsets.all(14),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFFD93D), Color(0xFFFFA500)]),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: const Color(0xFFFFD93D).withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 6))],
          ),
          child: Row(children: [
            const Text('🌟', style: TextStyle(fontSize: 48)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$completed / ${_quests.length} Quests Done!',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF5D3A00))),
              const SizedBox(height: 6),
              XPBar(progress: completed / _quests.length, gradient: const [Color(0xFF5D3A00), Color(0xFF8B5E00)], height: 8),
              const SizedBox(height: 4),
              Text('$totalPts stars earned today ⭐',
                style: const TextStyle(fontSize: 12, color: Color(0xFF7A4F00), fontWeight: FontWeight.w600)),
            ])),
          ]),
        ),

        Expanded(child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          itemCount: _quests.length,
          itemBuilder: (ctx, i) {
            final q = _quests[i];
            return AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) {
                final delay = i * 0.1;
                final t = ((_ctrl.value - delay) / (1 - delay.clamp(0, 0.6))).clamp(0.0, 1.0);
                return Opacity(
                  opacity: t,
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - Curves.easeOutCubic.transform(t))),
                    child: _QuestTile(quest: q, onToggle: () => setState(() => q['done'] = !q['done'])),
                  ),
                );
              },
            );
          },
        )),
      ]),
    );
  }
}

class _QuestTile extends StatelessWidget {
  final Map<String, dynamic> quest;
  final VoidCallback onToggle;
  const _QuestTile({required this.quest, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final done = quest['done'] as bool;
    final color = quest['color'] as Color;
    return TapBounce(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: done ? color.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: done ? color : Colors.grey.shade200, width: 2),
          boxShadow: [BoxShadow(color: color.withOpacity(done ? 0.15 : 0.05), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: done ? color : color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(quest['icon'], style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(quest['title'], style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: done ? color : AppColors.textDark,
              decoration: done ? TextDecoration.lineThrough : null,
            )),
            Text('+${quest['points']} stars ⭐', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          ])),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: done ? color : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(done ? Icons.check_rounded : Icons.circle_outlined,
              color: done ? Colors.white : Colors.grey.shade400, size: 18),
          ),
        ]),
      ),
    );
  }
}