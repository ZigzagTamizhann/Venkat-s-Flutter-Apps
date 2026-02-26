// lib/screens/story_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sign_data.dart';
import '../services/user_progress_service.dart';
import '../widgets/avatar_display.dart';
import '../widgets/kids_widgets.dart';
import '../theme/app_theme.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({Key? key}) : super(key: key);

  @override
  State<StoryScreen> createState() => _StoryScreenState();

  static final List<Story> stories = [
    Story(
      title: 'The Helpful Friend',
      chapter: 'Chapter 1',
      moral: 'Helping others makes everyone happy!',
      scenes: [
        StoryScene(avatarEmotion: 'happy', signText: 'HELLO FRIEND', narrative: 'Signa meets a new friend at school.', interactionPrompt: 'Practice sign: HELLO', practiceSign: 'HELLO'),
        StoryScene(avatarEmotion: 'happy', signText: 'WANT HELP', narrative: 'The friend needs help carrying books.', interactionPrompt: 'Practice sign: HELP', practiceSign: 'HELP'),
        StoryScene(avatarEmotion: 'happy', signText: 'THANK YOU', narrative: 'The friend is grateful for the help!', interactionPrompt: 'Practice sign: THANK YOU', practiceSign: 'THANK'),
      ],
    ),
    Story(
      title: 'The Lost Teddy',
      chapter: 'Chapter 2',
      moral: "It's okay to ask for help!",
      scenes: [
        StoryScene(avatarEmotion: 'sad', signText: 'MY TEDDY WHERE', narrative: 'Signa lost her favorite teddy bear.', interactionPrompt: 'Practice sign: WHERE', practiceSign: 'WHERE'),
        StoryScene(avatarEmotion: 'sad', signText: 'HELP PLEASE', narrative: 'Signa asks mother for help.', interactionPrompt: 'Practice sign: HELP', practiceSign: 'HELP'),
        StoryScene(avatarEmotion: 'happy', signText: 'FOUND THANK YOU', narrative: 'Mother helps find teddy! Signa is happy!', interactionPrompt: 'Practice sign: THANK YOU', practiceSign: 'THANK'),
      ],
    ),
    Story(
      title: 'Sharing is Caring',
      chapter: 'Chapter 3',
      moral: 'Sharing makes friendships stronger!',
      scenes: [
        StoryScene(avatarEmotion: 'happy', signText: 'I HAVE APPLE', narrative: 'Signa has a delicious apple for lunch.', interactionPrompt: 'Practice sign: APPLE', practiceSign: 'APPLE'),
        StoryScene(avatarEmotion: 'happy', signText: 'YOU WANT SHARE', narrative: 'Signa sees friend without lunch.', interactionPrompt: 'Practice sign: SHARE', practiceSign: 'SHARE'),
        StoryScene(avatarEmotion: 'happy', signText: 'HAPPY FRIENDS', narrative: 'Both friends share and enjoy together!', interactionPrompt: 'Practice sign: FRIEND', practiceSign: 'FRIEND'),
      ],
    ),
  ];
}

class _StoryScreenState extends State<StoryScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  // Story card gradients — warm, inviting colors
  static const _gradients = [
    [Color(0xFFFFD93D), Color(0xFFFFA500)],
    [Color(0xFFFF7BAC), Color(0xFFE91E8C)],
    [Color(0xFF5BB8FF), Color(0xFF4A90E2)],
  ];

  static const _emojis = ['📖', '🧸', '🍎'];
  // static const _scenes = ['3 scenes', '3 scenes', '3 scenes'];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: KidsAppBar(
        title: 'Stories',
        emoji: '📖',
        gradient: const [Color(0xFFFFD93D), Color(0xFFFFA500)],
      ),
      body: Column(children: [
        // Header banner
        Container(
          margin: const EdgeInsets.fromLTRB(14, 14, 14, 0),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF3CD), Color(0xFFFFE0A0)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFD93D).withOpacity(0.4)),
          ),
          child: Row(children: [
            const Text('✨', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Sign Language Stories!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF5D3A00))),
              Text('Read, learn signs & have fun! 🌟',
                style: const TextStyle(fontSize: 12, color: Color(0xFF7A4F00), fontWeight: FontWeight.w500)),
            ])),
          ]),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: StoryScreen.stories.length,
            itemBuilder: (ctx, i) {
              final story = StoryScreen.stories[i];
              final gradient = _gradients[i % _gradients.length];
              final emoji = _emojis[i % _emojis.length];

              return AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) {
                  final delay = i * 0.12;
                  final t = ((_ctrl.value - delay) / (1 - delay.clamp(0.0, 0.6))).clamp(0.0, 1.0);
                  final slide = 40.0 * (1 - Curves.easeOutCubic.transform(t));
                  return Opacity(
                    opacity: t,
                    child: Transform.translate(
                      offset: Offset(0, slide),
                      child: _StoryCard(
                        story: story,
                        gradient: gradient,
                        emoji: emoji,
                        index: i,
                      ),
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
}

class _StoryCard extends StatefulWidget {
  final Story story;
  final List<Color> gradient;
  final String emoji;
  final int index;

  const _StoryCard({required this.story, required this.gradient, required this.emoji, required this.index});

  @override
  State<_StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<_StoryCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween(begin: 1.0, end: 0.95).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        Navigator.push(context, PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (_, __, ___) => StoryDetailScreen(story: widget.story, gradient: widget.gradient),
          transitionsBuilder: (_, anim, __, child) => SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ));
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(color: widget.gradient[0].withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 7)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Stack(children: [
              // Gradient background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: widget.gradient,
                  ),
                ),
              ),
              // Decorative circles
              Positioned(right: -24, top: -24, child: Container(
                width: 110, height: 110,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
              )),
              Positioned(right: 20, bottom: -20, child: Container(
                width: 70, height: 70,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), shape: BoxShape.circle),
              )),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(children: [
                  // Book icon circle
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Text(widget.emoji, style: const TextStyle(fontSize: 34))),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(widget.story.chapter, style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white,
                      )),
                    ),
                    const SizedBox(height: 6),
                    Text(widget.story.title, style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1,
                    )),
                    const SizedBox(height: 4),
                    Row(children: [
                      Text('📚 ${widget.story.scenes.length} scenes', style: TextStyle(
                        fontSize: 12, color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.w600,
                      )),
                      const SizedBox(width: 10),
                      Text('⭐ +20 pts', style: TextStyle(
                        fontSize: 12, color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.w600,
                      )),
                    ]),
                  ])),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), shape: BoxShape.circle),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 26),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ─── Story Detail Screen ──────────────────────────────────────────────────────

class StoryDetailScreen extends StatefulWidget {
  final Story story;
  final List<Color> gradient;

  const StoryDetailScreen({Key? key, required this.story, required this.gradient}) : super(key: key);

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> with TickerProviderStateMixin {
  int _sceneIndex = 0;
  bool _hasInteracted = false;
  late AnimationController _sceneCtrl, _practiceCtrl;
  late Animation<double> _sceneFade, _sceneSlide, _practiceScale;

  StoryScene get _scene => widget.story.scenes[_sceneIndex];
  bool get _isLast => _sceneIndex == widget.story.scenes.length - 1;

  @override
  void initState() {
    super.initState();
    _sceneCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _sceneFade = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _sceneCtrl, curve: Curves.easeOut));
    _sceneSlide = Tween(begin: 30.0, end: 0.0).animate(CurvedAnimation(parent: _sceneCtrl, curve: Curves.easeOut));
    _practiceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _practiceScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 50),
    ]).animate(_practiceCtrl);
    _sceneCtrl.forward();
  }

  @override
  void dispose() { _sceneCtrl.dispose(); _practiceCtrl.dispose(); super.dispose(); }

  void _nextScene() {
    if (!_hasInteracted && _scene.interactionPrompt != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('👋 Practice the sign first!'),
        backgroundColor: AppColors.coral,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ));
      return;
    }
    if (_isLast) {
      _completeStory();
    } else {
      _sceneCtrl.reset();
      setState(() { _sceneIndex++; _hasInteracted = false; });
      _sceneCtrl.forward();
    }
  }

  void _practiceSign() {
    _practiceCtrl.forward(from: 0);
    setState(() => _hasInteracted = true);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('🎉 Amazing signing! +5 stars!'),
      backgroundColor: AppColors.grass,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      duration: const Duration(seconds: 2),
    ));
  }

  void _completeStory() {
    final svc = Provider.of<UserProgressService>(context, listen: false);
    svc.completeStory();

    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: widget.gradient),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('🎉', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 8),
            const Text('Story Complete!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(18)),
              child: Column(children: [
                const Text('💡 Moral of the Story', style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(widget.story.moral, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ]),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(20)),
              child: const Text('⭐ +20 Stars Earned!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () { Navigator.pop(context); Navigator.pop(context); },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50)),
                child: Text('Finish! 🏠', style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w900,
                  color: widget.gradient[0],
                )),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final svc = Provider.of<UserProgressService>(context);
    final avatar = svc.avatar!;
    final progress = (_sceneIndex + 1) / widget.story.scenes.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: KidsAppBar(
        title: widget.story.title,
        emoji: '📖',
        gradient: widget.gradient,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('${_sceneIndex + 1}/${widget.story.scenes.length}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
        ],
      ),
      body: Column(children: [
        // Progress bar
        Container(
          margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
          child: Column(children: [
            XPBar(progress: progress, gradient: widget.gradient, height: 10),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Scene ${_sceneIndex + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: widget.gradient[0])),
              Text('${(progress * 100).toInt()}% done', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: widget.gradient[0].withOpacity(0.7))),
            ]),
          ]),
        ),

        // Scene content
        Expanded(
          child: AnimatedBuilder(
            animation: _sceneCtrl,
            builder: (_, __) => Opacity(
              opacity: _sceneFade.value,
              child: Transform.translate(
                offset: Offset(0, _sceneSlide.value),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                  child: Column(children: [
                    // Avatar card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                          colors: [widget.gradient[0].withOpacity(0.12), widget.gradient[1].withOpacity(0.06)],
                        ),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: widget.gradient[0].withOpacity(0.2), width: 2),
                      ),
                      child: Column(children: [
                        AvatarDisplay(avatar: avatar, size: 130, emotion: _scene.avatarEmotion),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: widget.gradient),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(_scene.signText, style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1,
                          ), textAlign: TextAlign.center),
                        ),
                      ]),
                    ),

                    const SizedBox(height: 12),

                    // Narrative bubble
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [BoxShadow(color: widget.gradient[0].withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Row(children: [
                        Text(
                          _scene.avatarEmotion == 'sad' ? '😢' : '😊',
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: Text(_scene.narrative, style: const TextStyle(
                          fontSize: 16, height: 1.5, color: AppColors.textDark, fontWeight: FontWeight.w500,
                        ))),
                      ]),
                    ),

                    const SizedBox(height: 12),

                    // Practice sign card
                    if (_scene.interactionPrompt != null)
                      ScaleTransition(
                        scale: _hasInteracted ? _practiceScale : const AlwaysStoppedAnimation(1.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _hasInteracted ? AppColors.grass.withOpacity(0.1) : AppColors.sunshine.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: _hasInteracted ? AppColors.grass : AppColors.sunshine,
                              width: 2,
                            ),
                          ),
                          child: Column(children: [
                            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text(_hasInteracted ? '✅' : '👋', style: const TextStyle(fontSize: 28)),
                              const SizedBox(width: 8),
                              Text(
                                _hasInteracted ? 'Great job!' : 'Your turn!',
                                style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w800,
                                  color: _hasInteracted ? AppColors.grass : const Color(0xFF7A4F00),
                                ),
                              ),
                            ]),
                            const SizedBox(height: 8),
                            Text(_scene.interactionPrompt!, textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14, color: AppColors.textMid, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 14),
                            if (!_hasInteracted)
                              KidsButton(
                                text: 'Practice Sign',
                                emoji: '🤟',
                                color: widget.gradient[0],
                                gradient: [widget.gradient[0], widget.gradient[1]],
                                onTap: _practiceSign,
                                fontSize: 16,
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                              ),
                          ]),
                        ),
                      ),

                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ),
          ),
        ),

        // Bottom next button
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8F0),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
          ),
          child: SizedBox(
            width: double.infinity,
            child: KidsButton(
              text: _isLast ? 'Finish Story! 🎉' : 'Next Scene →',
              color: widget.gradient[0],
              gradient: widget.gradient,
              onTap: _nextScene,
              fontSize: 18,
              padding: const EdgeInsets.symmetric(vertical: 20),
            ),
          ),
        ),
      ]),
    );
  }
}