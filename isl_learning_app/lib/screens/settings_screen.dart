// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_avatar.dart';
import '../services/user_progress_service.dart';
import '../widgets/avatar_display.dart';
import '../widgets/rgb_color_picker.dart';
import '../widgets/kids_widgets.dart';
import '../theme/app_theme.dart';
import 'intro_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  bool _notifs = true, _sound = true, _haptic = true;
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Widget _anim(int i, Widget child) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) {
      final delay = i * 0.08;
      final t = ((_ctrl.value - delay) / (1 - delay.clamp(0.0, 0.6))).clamp(0.0, 1.0);
      return Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 20 * (1 - Curves.easeOutCubic.transform(t))), child: child),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final svc = Provider.of<UserProgressService>(context);
    final avatar = svc.avatar!;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      appBar: KidsAppBar(
        title: 'Settings',
        emoji: '⚙️',
        gradient: const [Color(0xFF94A3B8), Color(0xFF64748B)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // Avatar preview card
          _anim(0, Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF5BB8FF), Color(0xFFA855F7)],
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [BoxShadow(color: const Color(0xFF5BB8FF).withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 7))],
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), shape: BoxShape.circle),
                child: AvatarDisplay(avatar: avatar, size: 70),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(avatar.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: Text('Level ${svc.level} · ${svc.getLevelTitle()}',
                    style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ])),
            ]),
          )),

          const SizedBox(height: 20),
          _anim(1, _sectionLabel('👤 My Account')),
          _anim(2, _tile('Edit Avatar', '🎨', AppColors.grape,
              onTap: () => _showEditAvatar(context, svc, avatar))),
          _anim(3, _tile('Change Name', '✏️', AppColors.sky,
              onTap: () => _showChangeName(context, svc, avatar))),

          const SizedBox(height: 20),
          _anim(4, _sectionLabel('🔔 Preferences')),
          _anim(5, _switchTile('Daily Reminders', '🔔', AppColors.grass, _notifs,
              (v) => setState(() => _notifs = v))),
          _anim(6, _switchTile('Sound Effects', '🔊', AppColors.sunshine, _sound,
              (v) => setState(() => _sound = v))),
          _anim(7, _switchTile('Haptic Feedback', '📳', AppColors.peach, _haptic,
              (v) => setState(() => _haptic = v))),

          const SizedBox(height: 20),
          _anim(8, _sectionLabel('ℹ️ About')),
          _anim(9, _tile('About ISL Learning', 'ℹ️', AppColors.sky, onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'ISL Learning',
              applicationVersion: '2.0.0',
              applicationIcon: const Text('🤟', style: TextStyle(fontSize: 40)),
              children: [const Text('A joyful app for learning Indian Sign Language 🌟')],
            );
          })),
          _anim(10, _tile('Rate the App', '⭐', AppColors.sunshine, onTap: () {})),

          const SizedBox(height: 28),
          _anim(11, KidsButton(
            text: 'Logout',
            emoji: '👋',
            color: Colors.red,
            gradient: const [Color.fromARGB(255, 255, 0, 0), Color.fromARGB(255, 255, 64, 0)],
            onTap: () => _showLogoutConfirm(context),
          )),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Edit Avatar (RGB Picker) ──────────────────────────────────────────────
  void _showEditAvatar(BuildContext context, UserProgressService svc, UserAvatar avatar) {
    Color skin  = avatar.skinColor;
    Color hair  = avatar.hairColor;
    Color shirt = avatar.shirtColor;

    final isFemale = avatar.gender == 'female';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {

          Future<void> pickColor(String type) async {
            final initial = type == 'skin' ? skin : type == 'hair' ? hair : shirt;
            final picked  = await showRgbPicker(ctx, initial: initial);
            if (picked != null) setSheet(() {
              if (type == 'skin')  skin  = picked;
              if (type == 'hair')  hair  = picked;
              if (type == 'shirt') shirt = picked;
            });
          }

          return Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F5FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 44, height: 5,
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8))),
                const SizedBox(height: 16),

                // Title + live preview
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFF5BB8FF), Color(0xFFA855F7)]),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      padding: const EdgeInsets.all(4),
                      child: AvatarDisplay(
                        avatar: UserAvatar(
                          name: avatar.name, gender: avatar.gender,
                          skinColor: skin, hairColor: hair, shirtColor: shirt,
                          level: avatar.level,
                        ),
                        size: 72,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('🎨 Edit Avatar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                    SizedBox(height: 4),
                    Text('Tap any color to change it', style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
                  ]),
                ]),

                const SizedBox(height: 20),

                // Color tiles
                _SettingsColorTile(label: 'Skin Tone', emoji: '🧑', color: skin,
                  onTap: () => pickColor('skin')),
                const SizedBox(height: 10),
                _SettingsColorTile(label: 'Hair Color', emoji: '💇', color: hair,
                  onTap: () => pickColor('hair')),
                const SizedBox(height: 10),
                _SettingsColorTile(
                  label: isFemale ? 'Dress Color' : 'Shirt Color',
                  emoji: isFemale ? '👗' : '👕', color: shirt,
                  onTap: () => pickColor('shirt')),

                const SizedBox(height: 22),

                KidsButton(
                  text: 'Save Changes',
                  emoji: '✅',
                  color: AppColors.grape,
                  gradient: const [Color(0xFF5BB8FF), Color(0xFFA855F7)],
                  fontSize: 17,
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  onTap: () async {
                    final updated = avatar.copyWith(skinColor: skin, hairColor: hair, shirtColor: shirt);
                    await svc.saveAvatar(updated);
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      _showSnack(context, 'Avatar updated! 🎨', AppColors.grass);
                    }
                  },
                ),
              ]),
            ),
          );
        },
      ),
    );
  }


  // ── Change Name ──────────────────────────────────────────────────────────
  void _showChangeName(BuildContext context, UserProgressService svc, UserAvatar avatar) {
    final ctrl = TextEditingController(text: avatar.name);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('✏️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            const Text('Change Name', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(height: 18),
            TextField(
              controller: ctrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: 'Enter your name...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: const Color(0xFFF0F9FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('😊', style: TextStyle(fontSize: 22)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(18)),
                  child: const Center(child: Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textMid))),
                ),
              )),
              const SizedBox(width: 12),
              Expanded(child: GestureDetector(
                onTap: () async {
                  final name = ctrl.text.trim();
                  if (name.isEmpty) {
                    _showSnack(context, 'Name cannot be empty! 😊', AppColors.coral);
                    return;
                  }
                  await svc.saveAvatar(avatar.copyWith(name: name));
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    _showSnack(context, 'Name changed to $name! ✏️', AppColors.grass);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF5BB8FF), Color(0xFF4A90E2)]),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: const Color(0xFF5BB8FF).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: const Center(child: Text('Save ✅', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white))),
                ),
              )),
            ]),
          ]),
        ),
      ),
    );
  }

  // ── Logout Confirm ───────────────────────────────────────────────────────
  void _showLogoutConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('👋', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 8),
            const Text('Leaving so soon?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(height: 8),
            const Text('Your progress is saved!\nCome back and keep signing! 🤟',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textMid)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(18)),
                  child: const Center(child: Text('Stay 😊', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textMid))),
                ),
              )),
              const SizedBox(width: 12),
              Expanded(child: GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const IntroScreen()), (_) => false);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF9F7F)]),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: const Color(0xFFFF6B6B).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: const Center(child: Text('Logout 👋', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white))),
                ),
              )),
            ]),
          ]),
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      duration: const Duration(seconds: 2),
    ));
  }

  Widget _sectionLabel(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(t, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textMid)),
  );

  Widget _tile(String title, String emoji, Color color, {required VoidCallback onTap}) {
    return TapBounce(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(children: [
          Container(width: 40, height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20)))),
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark))),
          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
        ]),
      ),
    );
  }

  Widget _switchTile(String title, String emoji, Color color, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(children: [
        Container(width: 40, height: 40,
          decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20)))),
        const SizedBox(width: 14),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark))),
        Switch(value: value, onChanged: onChanged, activeColor: color),
      ]),
    );
  }
}

// ─── Settings Color Tile ──────────────────────────────────────────────────────
class _SettingsColorTile extends StatelessWidget {
  final String label, emoji;
  final Color color;
  final VoidCallback onTap;
  const _SettingsColorTile({required this.label, required this.emoji, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(children: [
          Container(width: 40, height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20)))),
          const SizedBox(width: 14),
          Expanded(child: Text(label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark))),
          Container(width: 34, height: 34,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200, width: 2),
              boxShadow: [BoxShadow(color: color.withOpacity(0.40), blurRadius: 8)])),
          const SizedBox(width: 10),
          Container(padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.colorize_rounded, size: 15, color: Color(0xFF888888))),
        ]),
      ),
    );
  }
}