// lib/screens/alphabet_garden_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_progress_service.dart';
import '../models/sign_data.dart';
import '../theme/app_theme.dart';
import '../theme/color_palette.dart';
import '../widgets/kids_widgets.dart';
import 'letter_detail_screen.dart';

class AlphabetGardenScreen extends StatefulWidget {
  const AlphabetGardenScreen({Key? key}) : super(key: key);

  static final List<SignData> alphabetData = [
    SignData(letter: 'A', emoji: '', funFact: 'A looks like a small fist with thumb out!', description: 'Make a fist and stick your thumb up'),
    SignData(letter: 'B', emoji: '', funFact: 'B has all fingers up like a high five!', description: 'Flat hand with thumb folded in'),
    SignData(letter: 'C', emoji: '', funFact: 'C curves like a moon!', description: 'Curve your hand like the letter C'),
    SignData(letter: 'D', emoji: '', funFact: 'D points to the sky!', description: 'Point index finger up, other fingers touch thumb'),
    SignData(letter: 'E', emoji: '', funFact: 'E is like holding a small ball!', description: 'Curl all fingers over thumb'),
    SignData(letter: 'F', emoji: '', funFact: 'F makes an OK sign!', description: 'Touch index and thumb, others up'),
    SignData(letter: 'G', emoji: '', funFact: 'G points sideways!', description: 'Point index and thumb sideways'),
    SignData(letter: 'H', emoji: '', funFact: 'H has two fingers lying down!', description: 'Hold index and middle finger sideways'),
    SignData(letter: 'I', emoji: '', funFact: 'I is the smallest letter!', description: 'Just your pinky finger up'),
    SignData(letter: 'J', emoji: '', funFact: 'J draws the letter in the air!', description: 'Pinky up, draw a J shape'),
    SignData(letter: 'K', emoji: '', funFact: 'K looks like two sticks!', description: 'Index up, middle out, thumb between'),
    SignData(letter: 'L', emoji: '', funFact: 'L makes a square corner!', description: 'Thumb and index make an L shape'),
    SignData(letter: 'M', emoji: '', funFact: 'M has three fingers under the thumb!', description: 'Thumb over three fingers'),
    SignData(letter: 'N', emoji: '', funFact: 'N has two fingers under the thumb!', description: 'Thumb over two fingers'),
    SignData(letter: 'O', emoji: '', funFact: 'O makes a circle!', description: 'All fingers and thumb form an O'),
    SignData(letter: 'P', emoji: '', funFact: 'P points down!', description: 'Like K but pointing down'),
    SignData(letter: 'Q', emoji: '', funFact: 'Q points down and sideways!', description: 'Like G but pointing down'),
    SignData(letter: 'R', emoji: '', funFact: 'R crosses two fingers!', description: 'Cross index and middle finger'),
    SignData(letter: 'S', emoji: '', funFact: 'S is a fist with thumb wrapped!', description: 'Make a fist with thumb outside'),
    SignData(letter: 'T', emoji: '', funFact: 'T tucks the thumb!', description: 'Thumb between index and middle'),
    SignData(letter: 'U', emoji: '', funFact: 'U has two fingers together!', description: 'Index and middle together, up'),
    SignData(letter: 'V', emoji: '', funFact: 'V is for victory!', description: 'Peace sign - index and middle apart'),
    SignData(letter: 'W', emoji: '', funFact: 'W has three fingers up!', description: 'Three middle fingers up'),
    SignData(letter: 'X', emoji: '', funFact: 'X makes a hook!', description: 'Bent index finger'),
    SignData(letter: 'Y', emoji: '', funFact: 'Y says "hang loose"!', description: 'Thumb and pinky out'),
    SignData(letter: 'Z', emoji: '', funFact: 'Z draws a zigzag!', description: 'Draw a Z with index finger'),
  ];

  @override
  State<AlphabetGardenScreen> createState() => _AlphabetGardenScreenState();
}

class _AlphabetGardenScreenState extends State<AlphabetGardenScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final svc = Provider.of<UserProgressService>(context);
    final done = svc.completedLetters.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FFF4),
      appBar: KidsAppBar(
        title: 'Alphabet Garden', emoji: '',
        gradient: const [Color(0xFF5ECC7B), Color(0xFF2DB87A)],
      ),
      body: Column(children: [
        // Stats header
        Container(
          margin: const EdgeInsets.all(14),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF5ECC7B), Color(0xFF2DB87A)]),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: const Color(0xFF5ECC7B).withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 6))],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _stat('$done/26', '🌸 Letters', Colors.white),
            Container(width: 1, height: 34, color: Colors.white.withOpacity(0.3)),
            _stat('${svc.points}', '⭐ Points', Colors.white),
            Container(width: 1, height: 34, color: Colors.white.withOpacity(0.3)),
            _stat('${((done / 26) * 100).toInt()}%', '🏆 Done', Colors.white),
          ]),
        ),

        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.9,
            ),
            itemCount: AlphabetGardenScreen.alphabetData.length,
            itemBuilder: (ctx, i) {
              final sign = AlphabetGardenScreen.alphabetData[i];
              final isCompleted = svc.completedLetters.contains(sign.letter);
              final color = ColorPalette.getLetterColor(sign.letter);

              return AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) {
                  final delay = (i * 0.028).clamp(0.0, 0.75);
                  final t = ((_ctrl.value - delay) / (1 - delay)).clamp(0.0, 1.0);
                  final curve = Curves.easeOutBack.transform(t);
                  return Opacity(
                    opacity: t,
                    child: Transform.scale(
                      scale: 0.4 + 0.6 * curve,
                      child: _LetterCard(sign: sign, isCompleted: isCompleted, color: color),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _stat(String v, String l, Color c) => Column(children: [
    Text(v, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: c)),
    Text(l, style: TextStyle(fontSize: 10, color: c.withOpacity(0.85), fontWeight: FontWeight.w600)),
  ]);
}

class _LetterCard extends StatefulWidget {
  final SignData sign;
  final bool isCompleted;
  final Color color;
  const _LetterCard({required this.sign, required this.isCompleted, required this.color});
  @override State<_LetterCard> createState() => _LetterCardState();
}

class _LetterCardState extends State<_LetterCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween(begin: 1.0, end: 0.88).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        Navigator.push(context, MaterialPageRoute(builder: (_) => LetterDetailScreen(signData: widget.sign)));
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            gradient: widget.isCompleted
                ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Color(0xFF5ECC7B), Color(0xFF2DB87A)])
                : LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Colors.white, AppTheme.getLighterColor(widget.color, 0.88)]),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.isCompleted ? const Color(0xFF5ECC7B) : widget.color.withOpacity(0.35), width: 2),
            boxShadow: [BoxShadow(
              color: (widget.isCompleted ? const Color(0xFF5ECC7B) : widget.color).withOpacity(0.22),
              blurRadius: 8, offset: const Offset(0, 4),
            )],
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (widget.isCompleted)
              const Text('✅', style: TextStyle(fontSize: 18)),
            Text(widget.sign.letter, style: TextStyle(
              fontSize: widget.isCompleted ? 22 : 30,
              fontWeight: FontWeight.w900,
              color: widget.isCompleted ? Colors.white : widget.color,
            )),
          ]),
        ),
      ),
    );
  }
}