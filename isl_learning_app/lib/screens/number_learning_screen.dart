// lib/screens/number_learning_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sign_data.dart';
import '../services/user_progress_service.dart';
import '../theme/app_theme.dart';
import '../theme/color_palette.dart';
import '../widgets/kids_widgets.dart';
import 'letter_detail_screen.dart';

class NumberLearningScreen extends StatefulWidget {
  const NumberLearningScreen({Key? key}) : super(key: key);
  @override State<NumberLearningScreen> createState() => _NumberLearningScreenState();

  static final List<SignData> numberData = [
    SignData(letter: '0', emoji: '', funFact: '0 is a perfect circle shape!', description: 'All fingers touching thumb form a circle'),
    SignData(letter: '1', emoji: '', funFact: '1 is just one finger!', description: 'Point your index finger up'),
    SignData(letter: '2', emoji: '', funFact: '2 looks like a peace sign!', description: 'Index and middle fingers up'),
    SignData(letter: '3', emoji: '', funFact: '3 uses three fingers!', description: 'Thumb, index, and middle fingers up'),
    SignData(letter: '4', emoji: '', funFact: '4 is four fingers up!', description: 'Four fingers up, thumb tucked'),
    SignData(letter: '5', emoji: '', funFact: '5 is a high five!', description: 'All five fingers open'),
    SignData(letter: '6', emoji: '', funFact: '6 connects thumb and pinky!', description: 'Thumb and pinky touching, others up'),
    SignData(letter: '7', emoji: '', funFact: '7 connects thumb and ring!', description: 'Thumb and ring finger touching'),
    SignData(letter: '8', emoji: '', funFact: '8 connects thumb and middle!', description: 'Thumb and middle finger touching'),
    SignData(letter: '9', emoji: '', funFact: '9 connects thumb and index!', description: 'Thumb and index finger touching'),
  ];
}

class _NumberLearningScreenState extends State<NumberLearningScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward(); }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final svc = Provider.of<UserProgressService>(context);
    final learned = NumberLearningScreen.numberData.where((n) => svc.completedLetters.contains(n.letter)).length;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0EE),
      appBar: KidsAppBar(title: 'Number Park', emoji: '', gradient: const [Color(0xFFFF9F7F), Color(0xFFFF6B6B)]),
      body: Column(children: [
        Container(
          margin: const EdgeInsets.all(14),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFF9F7F), Color(0xFFFF6B6B)]),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: const Color(0xFFFF9F7F).withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 6))],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Column(children: [
              Text('$learned/10', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
              const Text('Numbers 🔢', style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600)),
            ]),
            Container(width: 1, height: 34, color: Colors.white.withOpacity(0.3)),
            Column(children: [
              Text('${svc.points}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
              const Text('Points ⭐', style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600)),
            ]),
            Container(width: 1, height: 34, color: Colors.white.withOpacity(0.3)),
            Column(children: [
              Text('${((learned / 10) * 100).toInt()}%', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
              const Text('Done 🏆', style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600)),
            ]),
          ]),
        ),

        Expanded(child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.1,
          ),
          itemCount: NumberLearningScreen.numberData.length,
          itemBuilder: (ctx, i) {
            final sign = NumberLearningScreen.numberData[i];
            final done = svc.completedLetters.contains(sign.letter);
            final color = ColorPalette.getLetterColor(sign.letter);
            return AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) {
                final delay = (i * 0.06).clamp(0.0, 0.7);
                final t = ((_ctrl.value - delay) / (1 - delay)).clamp(0.0, 1.0);
                final curve = Curves.easeOutBack.transform(t);
                return Opacity(
                  opacity: t,
                  child: Transform.scale(scale: 0.5 + 0.5 * curve, child: _NumberCard(sign: sign, done: done, color: color)),
                );
              },
            );
          },
        )),
      ]),
    );
  }
}

class _NumberCard extends StatefulWidget {
  final SignData sign;
  final bool done;
  final Color color;
  const _NumberCard({required this.sign, required this.done, required this.color});
  @override State<_NumberCard> createState() => _NumberCardState();
}
class _NumberCardState extends State<_NumberCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _s;
  @override
  void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100)); _s = Tween(begin: 1.0, end: 0.9).animate(_ctrl); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); Navigator.push(context, MaterialPageRoute(builder: (_) => LetterDetailScreen(signData: widget.sign))); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(scale: _s, child: Container(
        decoration: BoxDecoration(
          gradient: widget.done
              ? const LinearGradient(colors: [Color(0xFFFF9F7F), Color(0xFFFF6B6B)])
              : LinearGradient(colors: [Colors.white, AppTheme.getLighterColor(widget.color, 0.88)]),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: widget.done ? const Color(0xFFFF9F7F) : widget.color.withOpacity(0.3), width: 2),
          boxShadow: [BoxShadow(color: widget.color.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (widget.done) const Text('✅', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(widget.sign.letter, style: TextStyle(
            fontSize: widget.done ? 28 : 42, fontWeight: FontWeight.w900,
            color: widget.done ? Colors.white : widget.color,
          )),
          Text(widget.done ? 'Learned! 🎉' : 'Tap to learn',
            style: TextStyle(fontSize: 10, color: widget.done ? Colors.white70 : AppColors.textLight, fontWeight: FontWeight.w600)),
        ]),
      )),
    );
  }
}