import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_progress_service.dart';
import '../widgets/avatar_display.dart';

class ParentReviewScreen extends StatelessWidget {
  const ParentReviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progressService = Provider.of<UserProgressService>(context);
    final avatar = progressService.avatar!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('👨‍👩‍👧 Family Zone'),
        backgroundColor: Colors.teal[400],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal[200]!,
              Colors.cyan[100]!,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      '👋 Parent/Teacher Review',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Review ${avatar.name}'s learning progress",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Child Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    AvatarDisplay(avatar: avatar, size: 100),
                    const SizedBox(height: 15),
                    Text(
                      avatar.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Level ${progressService.level} - ${progressService.getLevelTitle()}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Overall Progress
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('📊', style: TextStyle(fontSize: 24)),
                        SizedBox(width: 10),
                        Text(
                          'OVERALL PROGRESS',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildProgressCard(
                      '🔤 Alphabet',
                      '${progressService.completedLetters.length} / 26 letters',
                      progressService.completedLetters.length / 26,
                      Colors.blue,
                    ),
                    const SizedBox(height: 15),
                    _buildProgressCard(
                      '💬 Words',
                      '${progressService.completedWords.length} words learned',
                      progressService.completedWords.isEmpty ? 0 : 1,
                      Colors.green,
                    ),
                    const SizedBox(height: 15),
                    _buildProgressCard(
                      '📖 Stories',
                      '${progressService.storiesCompleted} stories completed',
                      progressService.storiesCompleted / 10,
                      Colors.purple,
                    ),
                    const SizedBox(height: 15),
                    _buildProgressCard(
                      '⭐ Total Points',
                      '${progressService.points} points earned',
                      progressService.points / 500,
                      Colors.orange,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Streak & Consistency
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('🔥', style: TextStyle(fontSize: 24)),
                        SizedBox(width: 10),
                        Text(
                          'CONSISTENCY',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatBox(
                            '${progressService.streak}',
                            'Day Streak',
                            Colors.red,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildStatBox(
                            '${(progressService.streak / 7).floor()}',
                            'Weeks',
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: progressService.streak >= 7
                            ? Colors.green[50]
                            : Colors.orange[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: progressService.streak >= 7
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            progressService.streak >= 7
                                ? Icons.check_circle
                                : Icons.info,
                            color: progressService.streak >= 7
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              progressService.streak >= 7
                                  ? '${avatar.name} is practicing consistently! 🎉'
                                  : 'Encourage daily practice for better results',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Achievements & Badges
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('🏆', style: TextStyle(fontSize: 24)),
                        SizedBox(width: 10),
                        Text(
                          'ACHIEVEMENTS',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    if (progressService.badges.isEmpty)
                      Text(
                        'No badges earned yet. Keep learning!',
                        style: TextStyle(color: Colors.grey[600]),
                      )
                    else
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: progressService.badges.map((badge) {
                          final badgeInfo = _getBadgeInfo(badge);
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(badgeInfo['emoji']!,
                                    style: const TextStyle(fontSize: 24)),
                                const SizedBox(width: 8),
                                Text(
                                  badgeInfo['name']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Learning Recommendations
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('💡', style: TextStyle(fontSize: 24)),
                        SizedBox(width: 10),
                        Text(
                          'RECOMMENDATIONS',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    ..._getRecommendations(progressService)
                        .map((rec) => _buildRecommendationItem(rec))
                        .toList(),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Support Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal[400]!, Colors.cyan[400]!],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  children: [
                    Text(
                      '👨‍👩‍👧 Tips for Parents',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      '• Practice together for 10-15 minutes daily\n'
                      '• Use signs in everyday conversations\n'
                      '• Celebrate small achievements\n'
                      '• Be patient and encouraging\n'
                      '• Make learning fun and interactive',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(
    String title,
    String subtitle,
    double progress,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String recommendation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.arrow_right, color: Colors.teal),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              recommendation,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _getBadgeInfo(String badgeId) {
    final badges = {
      'alphabet_master': {'emoji': '🏅', 'name': 'Alphabet Master'},
      'expression_expert': {'emoji': '🎭', 'name': 'Expression Expert'},
      'story_hero': {'emoji': '📖', 'name': 'Story Hero'},
      'practice_champion': {'emoji': '⭐', 'name': 'Practice Champion'},
    };
    return badges[badgeId] ?? {'emoji': '🏆', 'name': 'Achievement'};
  }

  List<String> _getRecommendations(UserProgressService progressService) {
    final recommendations = <String>[];

    if (progressService.completedLetters.length < 26) {
      recommendations.add(
        'Continue alphabet learning - ${26 - progressService.completedLetters.length} letters remaining',
      );
    }

    if (progressService.completedWords.isEmpty) {
      recommendations.add('Start word learning to build vocabulary');
    }

    if (progressService.storiesCompleted < 3) {
      recommendations.add('Interactive stories help with context and emotions');
    }

    if (progressService.streak < 7) {
      recommendations.add('Try to practice daily for better retention');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Excellent progress! Keep up the great work!');
      recommendations.add('Try more advanced sentence building games');
      recommendations.add('Practice with real-life conversations');
    }

    return recommendations;
  }
}
