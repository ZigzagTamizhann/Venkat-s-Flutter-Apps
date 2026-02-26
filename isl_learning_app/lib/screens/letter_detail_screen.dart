// lib/screens/letter_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/isl_sign_icons.dart';
import '../models/sign_data.dart';
import '../services/user_progress_service.dart';
import '../widgets/avatar_display.dart';
import 'camera_practice_screen.dart';
import '../theme/app_theme.dart';
import '../theme/color_palette.dart';
// import '../widgets/gradient_background.dart';

class LetterDetailScreen extends StatefulWidget {
  final SignData signData;

  const LetterDetailScreen({Key? key, required this.signData}) : super(key: key);

  @override
  State<LetterDetailScreen> createState() => _LetterDetailScreenState();
}

class _LetterDetailScreenState extends State<LetterDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Color _letterColor;

  @override
  void initState() {
    super.initState();
    _letterColor = ColorPalette.getLetterColor(widget.signData.letter);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressService = Provider.of<UserProgressService>(context);
    final avatar = progressService.avatar!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Letter ${widget.signData.letter}'),
        backgroundColor: _letterColor,
        elevation: 0,
        foregroundColor: AppTheme.textWhite,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.getLighterColor(_letterColor, 0.85),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Letter Display
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        AppTheme.getLighterColor(_letterColor, 0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: _letterColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: _letterColor.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Hero(
                          tag: 'sign_${widget.signData.letter}',
                          child: Image.asset(
                            // Using the letter to build the path since your emoji field contains flower icons
                            'assets/${widget.signData.letter}.jpg',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('Error loading image for ${widget.signData.letter}: $error');
                              // If image fails, it shows the custom drawn ISL icon
                              return ISLSignIcon(
                                letter: widget.signData.letter,
                                size: 120,
                                color: Colors.white,
                                backgroundColor: _letterColor,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.signData.letter,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: _letterColor,
                          shadows: [
                            Shadow(
                              color: _letterColor.withOpacity(0.5),
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Fun Fact
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.accentYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.accentGold,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('💡', style: TextStyle(fontSize: 30)),
                        SizedBox(width: 10),
                        Text(
                          'FUN FACT',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.signData.funFact,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // How to Sign
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _letterColor.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.back_hand, color: _letterColor, size: 28),
                        const SizedBox(width: 10),
                        const Text(
                          'HOW TO SIGN',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppTheme.getLighterColor(_letterColor, 0.9),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        widget.signData.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.getDarkerColor(_letterColor, 0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Avatar Demo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryPurple.withOpacity(0.1),
                      AppTheme.primaryPink.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryPurple.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      '🎭 AVATAR DEMO',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                    const SizedBox(height: 15),
                    AvatarDisplay(avatar: avatar, size: 100),
                    const SizedBox(height: 10),
                    Text(
                      'Your avatar shows the sign!',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Practice Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CameraPracticeScreen(
                          signData: widget.signData,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _letterColor,
                    foregroundColor: AppTheme.textWhite,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                  ).copyWith(
                    shadowColor: MaterialStateProperty.all(
                      _letterColor.withOpacity(0.5),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 28),
                      SizedBox(width: 10),
                      Text(
                        '📸 Practice with Camera',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Mark as Learned Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await progressService.completeSign(widget.signData.letter);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.celebration, color: Colors.white),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Great! You learned ${widget.signData.letter}! +5 points 🎉',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: AppTheme.successGreen,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    side: BorderSide(color: AppTheme.successGreen, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    foregroundColor: AppTheme.successGreen,
                  ),
                  child: const Text(
                    '✓ I Learned This!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}