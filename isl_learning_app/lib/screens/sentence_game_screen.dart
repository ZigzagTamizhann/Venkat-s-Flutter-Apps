// lib/screens/sentence_game_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_progress_service.dart';
import '../widgets/kids_widgets.dart';
// import '../theme/app_theme.dart';

class SentenceGameScreen extends StatefulWidget {
  const SentenceGameScreen({Key? key}) : super(key: key);

  @override
  State<SentenceGameScreen> createState() => _SentenceGameScreenState();
}

class _SentenceGameScreenState extends State<SentenceGameScreen>
    with TickerProviderStateMixin {
  // ── Sentences — each maps to one of the 5 GIFs ───────────────────────────
  final List<Map<String, dynamic>> _sentences = [
    {
      'sentence': 'KEEP CALM',
      'emoji': '😌',
      'gif': 'assets/gifs/keep calm.gif',
      'gradient': [const Color(0xFF5BB8FF), const Color(0xFF4A90E2)],
      'shadow': const Color(0xFF5BB8FF),
      'words': ['KEEP', 'CALM'],
      'tip': 'Stay steady and sign smoothly!',
    },
    {
      'sentence': 'THANK YOU',
      'emoji': '🙏',
      'gif': 'assets/gifs/thank-you.gif',
      'gradient': [const Color(0xFF5ECC7B), const Color(0xFF2DB87A)],
      'shadow': const Color(0xFF5ECC7B),
      'words': ['THANK', 'YOU'],
      'tip': 'Touch your chin and move forward!',
    },
    {
      'sentence': 'HOW ARE YOU',
      'emoji': '😊',
      'gif': 'assets/gifs/how r u.gif',
      'gradient': [const Color(0xFFA855F7), const Color(0xFF7C3AED)],
      'shadow': const Color(0xFFA855F7),
      'words': ['HOW', 'ARE', 'YOU'],
      'tip': 'A friendly greeting in ISL!',
    },
    {
      'sentence': 'NICE TO MEET YOU',
      'emoji': '🤝',
      'gif': 'assets/gifs/nice to meet you.gif',
      'gradient': [const Color(0xFFFF9F7F), const Color(0xFFFF6B6B)],
      'shadow': const Color(0xFFFF9F7F),
      'words': ['NICE', 'TO', 'MEET', 'YOU'],
      'tip': 'Show warmth and friendship!',
    },
    {
      'sentence': 'I AM HAPPY',
      'emoji': '😄',
      'gif': 'assets/gifs/i_am_happy.gif',
      'gradient': [const Color(0xFFFFD93D), const Color(0xFFFFA500)],
      'shadow': const Color(0xFFFFD93D),
      'words': ['I', 'AM', 'HAPPY'],
      'tip': 'Express joy with your face too!',
    },
  ];

  int _sentenceIndex = 0;
  int _wordIndex = 0;
  int _score = 0;
  bool _gifVisible = true;

  late AnimationController _cardCtrl, _scoreCtrl, _gifCtrl;
  late Animation<double> _cardScale, _scoreAnim, _gifBounce;

  Map<String, dynamic> get _cur => _sentences[_sentenceIndex];
  String get _currentWord => _cur['words'][_wordIndex];
  bool get _isLastWord => _wordIndex == (_cur['words'] as List).length - 1;
  bool get _isLastSentence => _sentenceIndex == _sentences.length - 1;

  @override
  void initState() {
    super.initState();
    _sentences.shuffle();

    _cardCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _cardScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.92), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut));

    _scoreCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _scoreAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _scoreCtrl, curve: Curves.easeOut));

    _gifCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _gifBounce = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.08), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _gifCtrl, curve: Curves.easeOut));

    _gifCtrl.forward();
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    _scoreCtrl.dispose();
    _gifCtrl.dispose();
    super.dispose();
  }

  // ── Signed the current word ───────────────────────────────────────────────
  void _onSigned() async {
    _cardCtrl.forward(from: 0);
    _scoreCtrl.forward(from: 0);

    if (_isLastWord) {
      // Sentence complete
      setState(() { _score += 10; });
      await Future.delayed(const Duration(milliseconds: 300));
      if (_isLastSentence) {
        _showAllDoneDialog();
      } else {
        _showSentenceDoneDialog();
      }
    } else {
      // Next word
      setState(() {
        _wordIndex++;
        _gifVisible = false;
      });
      await Future.delayed(const Duration(milliseconds: 120));
      setState(() => _gifVisible = true);
      _gifCtrl.forward(from: 0);
    }
  }

  void _advanceToNextSentence() {
    setState(() {
      _sentenceIndex++;
      _wordIndex = 0;
      _gifVisible = true;
    });
    _gifCtrl.forward(from: 0);
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────
  void _showSentenceDoneDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: List<Color>.from(_cur['gradient'])),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(_cur['emoji'], style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 8),
            const Text('Sentence Done!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.22), borderRadius: BorderRadius.circular(20)),
              child: const Text('⭐ +10 Stars!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: () { Navigator.pop(context); _advanceToNextSentence(); },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50)),
                child: Text('Next Sentence →', style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w900,
                  color: (_cur['gradient'] as List<Color>).first,
                )),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _showAllDoneDialog() {
    final svc = Provider.of<UserProgressService>(context, listen: false);
    svc.addPoints(_score);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF5BB8FF), Color(0xFFA855F7)],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('🏆', style: TextStyle(fontSize: 64)),
            const Text('All Done!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 8),
            const Text('You signed all sentences!', style: TextStyle(fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.22), borderRadius: BorderRadius.circular(22)),
              child: Text('🎉 $_score Stars Earned!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () { Navigator.pop(context); Navigator.pop(context); },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50)),
                child: const Text('Finish! 🏠', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF5BB8FF))),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_sentenceIndex >= _sentences.length) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final grad = List<Color>.from(_cur['gradient']);
    final shadow = _cur['shadow'] as Color;
    final progress = (_sentenceIndex + 1) / _sentences.length;
    final words = _cur['words'] as List;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: KidsAppBar(
        title: 'Sentence Builder',
        emoji: '💬',
        gradient: grad,
        actions: [
          AnimatedBuilder(
            animation: _scoreCtrl,
            builder: (_, __) => Transform.scale(
              scale: _scoreAnim.value.clamp(0.0, 2.0),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('⭐ $_score', style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
      body: Column(children: [
        // ── Progress bar ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(children: [
            XPBar(progress: progress, gradient: grad, height: 10),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Sentence ${_sentenceIndex + 1} of ${_sentences.length}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: grad.first)),
              Text('Word ${_wordIndex + 1} of ${words.length}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: grad.first.withOpacity(0.7))),
            ]),
          ]),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(children: [

              // ── Full sentence with word pills ──────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [grad.first.withOpacity(0.1), grad.last.withOpacity(0.05)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: grad.first.withOpacity(0.25), width: 2),
                ),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(_cur['emoji'], style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(_cur['sentence'], style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w900, color: grad.first,
                    )),
                  ]),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: List.generate(words.length, (i) {
                      final isDone = i < _wordIndex;
                      final isCurrent = i == _wordIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isDone
                              ? const LinearGradient(colors: [Color(0xFF5ECC7B), Color(0xFF2DB87A)])
                              : isCurrent
                                  ? LinearGradient(colors: grad)
                                  : null,
                          color: isDone || isCurrent ? null : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: isCurrent ? [BoxShadow(color: grad.first.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))] : [],
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          if (isDone) ...[
                            const Text('✅', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                          ],
                          Text(words[i], style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800,
                            color: (isDone || isCurrent) ? Colors.white : Colors.grey.shade500,
                          )),
                        ]),
                      );
                    }),
                  ),
                ]),
              ),

              const SizedBox(height: 14),

              // ── GIF demonstration card ────────────────────────────────
              ScaleTransition(
                scale: _gifBounce,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [BoxShadow(color: shadow.withOpacity(0.22), blurRadius: 18, offset: const Offset(0, 8))],
                  ),
                  child: Column(children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: grad),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                      ),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('Sign this word:', style: TextStyle(
                            fontSize: 12, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600)),
                        ),
                        const Spacer(),
                        Text(_currentWord, style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white,
                        )),
                      ]),
                    ),

                    // GIF area
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(0)),
                      child: _gifVisible
                          ? Image.asset(
                              _cur['gif'],
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => _gifPlaceholder(grad),
                            )
                          : _gifPlaceholder(grad),
                    ),

                    // Tip banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: grad.first.withOpacity(0.08),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
                      ),
                      child: Row(children: [
                        Text('💡', style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_cur['tip'], style: TextStyle(
                          fontSize: 12, color: grad.first, fontWeight: FontWeight.w600,
                        ))),
                      ]),
                    ),
                  ]),
                ),
              ),

              const SizedBox(height: 16),

              // ── Sign button ───────────────────────────────────────────
              ScaleTransition(
                scale: _cardScale,
                child: KidsButton(
                  text: _isLastWord ? 'Sentence Done! 🎉' : 'I Signed It! ✅',
                  emoji: '🤟',
                  color: grad.first,
                  gradient: grad,
                  onTap: _onSigned,
                  fontSize: 19,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
              ),

              const SizedBox(height: 8),

              // Skip word
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_isLastWord) {
                      if (_isLastSentence) {
                        _showAllDoneDialog();
                      } else {
                        _showSentenceDoneDialog();
                      }
                    } else {
                      _wordIndex++;
                      _gifVisible = false;
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (mounted) { setState(() => _gifVisible = true); _gifCtrl.forward(from: 0); }
                      });
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('Skip this word →', style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade400, fontWeight: FontWeight.w600,
                  )),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _gifPlaceholder(List<Color> grad) {
    return Container(
      height: 220,
      width: double.infinity,
      color: grad.first.withOpacity(0.06),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(_cur['emoji'], style: const TextStyle(fontSize: 64)),
        const SizedBox(height: 12),
        Text(_currentWord, style: TextStyle(
          fontSize: 28, fontWeight: FontWeight.w900, color: grad.first,
        )),
        const SizedBox(height: 6),
        Text('Watch & sign!', style: TextStyle(fontSize: 13, color: grad.first.withOpacity(0.6))),
      ]),
    );
  }
}