// lib/screens/avatar_customization_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_avatar.dart';
import '../services/user_progress_service.dart';
import '../widgets/avatar_display.dart';
import '../widgets/rgb_color_picker.dart';
import '../widgets/kids_widgets.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class AvatarCustomizationScreen extends StatefulWidget {
  const AvatarCustomizationScreen({Key? key}) : super(key: key);
  @override
  State<AvatarCustomizationScreen> createState() => _AvatarCustomizationScreenState();
}

class _AvatarCustomizationScreenState extends State<AvatarCustomizationScreen>
    with SingleTickerProviderStateMixin {

  final _nameCtrl = TextEditingController();
  String _gender  = 'male';
  Color _skin     = const Color(0xFFFFDBB4);
  Color _hair     = const Color(0xFF5C3317);
  Color _shirt    = const Color(0xFF5BB8FF);

  late AnimationController _popCtrl;
  late Animation<double> _popAnim;

  @override
  void initState() {
    super.initState();
    _popCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 460));
    _popAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.20), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.20, end: 0.93), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.93, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _popCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _nameCtrl.dispose(); _popCtrl.dispose(); super.dispose(); }

  void _pop() => _popCtrl.forward(from: 0);

  UserAvatar get _preview => UserAvatar(
    name: _nameCtrl.text.isEmpty ? (_gender == 'male' ? 'Boy' : 'Girl') : _nameCtrl.text,
    skinColor: _skin, hairColor: _hair, shirtColor: _shirt, gender: _gender,
  );

  Future<void> _pickColor(String type) async {
    final initial = type == 'skin' ? _skin : type == 'hair' ? _hair : _shirt;
    final picked  = await showRgbPicker(context, initial: initial);
    if (picked != null) {
      setState(() {
        if (type == 'skin')  _skin  = picked;
        if (type == 'hair')  _hair  = picked;
        if (type == 'shirt') _shirt = picked;
      });
      _pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMale = _gender == 'male';
    final themeGrad = isMale
        ? const [Color(0xFF5BB8FF), Color(0xFF4A90E2)]
        : const [Color(0xFFFF7BAC), Color(0xFFE91E8C)];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [...themeGrad, themeGrad.last],
          ),
        ),
        child: SafeArea(child: Column(children: [

          // ── Top bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(children: [
              if (Navigator.canPop(context))
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(width: 38, height: 38,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.22), shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16)),
                )
              else const SizedBox(width: 38),
              const Expanded(child: Center(
                child: Text('✨ Create Your Avatar',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Colors.white)),
              )),
              const SizedBox(width: 38),
            ]),
          ),

          const SizedBox(height: 16),

          // ── Gender Toggle ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 52),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
              ),
              child: Row(children: [
                _GenderBtn(emoji: '👦', label: 'Boy',  value: 'male',   selected: _gender,
                  onTap: () { setState(() { _gender='male';   _shirt=AppColors.sky;  }); _pop(); }),
                _GenderBtn(emoji: '👧', label: 'Girl', value: 'female', selected: _gender,
                  onTap: () { setState(() { _gender='female'; _shirt=AppColors.rose; }); _pop(); }),
              ]),
            ),
          ),

          const SizedBox(height: 14),

          // ── Avatar preview ────────────────────────────────────────────
          ScaleTransition(
            scale: _popAnim,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: themeGrad),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 22, offset: const Offset(0, 8))],
              ),
              child: Container(
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                padding: const EdgeInsets.all(6),
                child: AvatarDisplay(avatar: _preview, size: 108),
              ),
            ),
          ),

          const SizedBox(height: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              _nameCtrl.text.isEmpty ? (isMale ? '👦 Your Boy!' : '👧 Your Girl!') : 'Hi, ${_nameCtrl.text}! 👋',
              key: ValueKey(_nameCtrl.text + _gender),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),

          const SizedBox(height: 12),

          // ── Panel ─────────────────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8F5FF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Center(child: Container(width: 44, height: 5,
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)))),

                  const SizedBox(height: 18),

                  // Name
                  _label('👤 Your Name'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nameCtrl,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'Type your name...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w400),
                      filled: true, fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(color: themeGrad.first, width: 2)),
                      prefixIcon: const Padding(padding: EdgeInsets.all(12),
                        child: Text('✏️', style: TextStyle(fontSize: 20))),
                    ),
                  ),

                  const SizedBox(height: 26),

                  // Color pickers
                  _label('🎨 Customize Colors'),
                  const SizedBox(height: 14),

                  _ColorTile(label: 'Skin Tone',
                    emoji: '🧑', color: _skin, onTap: () => _pickColor('skin')),
                  const SizedBox(height: 12),
                  _ColorTile(label: 'Hair Color',
                    emoji: '💇', color: _hair, onTap: () => _pickColor('hair')),
                  const SizedBox(height: 12),
                  _ColorTile(
                    label: isMale ? 'Shirt Color' : 'Dress Color',
                    emoji: isMale ? '👕' : '👗', color: _shirt, onTap: () => _pickColor('shirt')),

                  const SizedBox(height: 32),

                  KidsButton(
                    text: "Let's Go! 🎉",
                    color: themeGrad.first,
                    gradient: themeGrad,
                    onTap: _save,
                    fontSize: 19,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                ]),
              ),
            ),
          ),
        ])),
      ),
    );
  }

  Widget _label(String t) => Text(t,
    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark));

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please enter your name! 😊'),
        backgroundColor: AppColors.coral, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ));
      return;
    }
    final svc = Provider.of<UserProgressService>(context, listen: false);
    await svc.saveAvatar(UserAvatar(
      name: name, skinColor: _skin, hairColor: _hair,
      shirtColor: _shirt, gender: _gender,
    ));
    if (mounted) {
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: CurvedAnimation(parent: anim, curve: Curves.easeInOut), child: child),
      ));
    }
  }
}

// ─── Color Tile (tap to open RGB picker) ─────────────────────────────────────
class _ColorTile extends StatelessWidget {
  final String label, emoji;
  final Color color;
  final VoidCallback onTap;
  const _ColorTile({required this.label, required this.emoji, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          // Emoji icon
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 14),
          // Label
          Expanded(child: Text(label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark))),
          // Color preview swatch
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200, width: 2),
              boxShadow: [BoxShadow(color: color.withOpacity(0.40), blurRadius: 8, spreadRadius: 1)],
            ),
          ),
          const SizedBox(width: 10),
          // Arrow
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.colorize_rounded, size: 16, color: Color(0xFF888888)),
          ),
        ]),
      ),
    );
  }
}

// ─── Gender Button ────────────────────────────────────────────────────────────
class _GenderBtn extends StatelessWidget {
  final String emoji, label, value, selected;
  final VoidCallback onTap;
  const _GenderBtn({required this.emoji, required this.label, required this.value,
      required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSel = value == selected;
    final selColor = value == 'male' ? const Color(0xFF4A90E2) : const Color(0xFFE91E8C);
    return Expanded(child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: isSel ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          boxShadow: isSel ? [BoxShadow(color: selColor.withOpacity(0.22), blurRadius: 10, offset: const Offset(0, 3))] : [],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w800,
            color: isSel ? selColor : Colors.white.withOpacity(0.80),
          )),
        ]),
      ),
    ));
  }
}