import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sign_data.dart';
import '../services/user_progress_service.dart';

class WordLearningScreen extends StatelessWidget {
  const WordLearningScreen({Key? key}) : super(key: key);

  static final List<WordSign> _wordCategories = [
    // Food Tree
    WordSign(word: 'EAT', emoji: '🍽️', category: 'FOOD TREE', description: 'Bring hand to mouth', color: Colors.red),
    WordSign(word: 'DRINK', emoji: '🥤', category: 'FOOD TREE', description: 'Tilt hand to mouth', color: Colors.blue),
    WordSign(word: 'HUNGRY', emoji: '😋', category: 'FOOD TREE', description: 'Move hand down chest', color: Colors.orange),
    WordSign(word: 'APPLE', emoji: '🍎', category: 'FOOD TREE', description: 'Twist fist at cheek', color: Colors.red),
    WordSign(word: 'WATER', emoji: '💧', category: 'FOOD TREE', description: 'W sign at mouth', color: Colors.blue),

    // Feelings Pond
    WordSign(word: 'HAPPY', emoji: '😊', category: 'FEELINGS POND', description: 'Brush chest upward twice', color: Colors.yellow),
    WordSign(word: 'SAD', emoji: '😢', category: 'FEELINGS POND', description: 'Move hands down face', color: Colors.blue),
    WordSign(word: 'LOVE', emoji: '❤️', category: 'FEELINGS POND', description: 'Cross arms over chest', color: Colors.pink),

    // School Path
    WordSign(word: 'LEARN', emoji: '📚', category: 'SCHOOL PATH', description: 'Move hand from book to head', color: Colors.purple),
    WordSign(word: 'BOOK', emoji: '📖', category: 'SCHOOL PATH', description: 'Open palms like a book', color: Colors.brown),
    WordSign(word: 'FRIEND', emoji: '👫', category: 'SCHOOL PATH', description: 'Hook index fingers', color: Colors.green),

    // Family Mountain
    WordSign(word: 'MOTHER', emoji: '👩', category: 'FAMILY MOUNTAIN', description: 'Thumb at chin', color: Colors.pink),
    WordSign(word: 'FATHER', emoji: '👨', category: 'FAMILY MOUNTAIN', description: 'Thumb at forehead', color: Colors.blue),
    WordSign(word: 'HELP', emoji: '🤝', category: 'FAMILY MOUNTAIN', description: 'Fist on palm, lift up', color: Colors.orange),
  ];

  @override
  Widget build(BuildContext context) {
    final categories = _wordCategories
        .map((w) => w.category)
        .toSet()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🌳 Daily Signs Forest'),
        backgroundColor: Colors.teal[400],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal[300]!,
              Colors.green[200]!,
            ],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final words = _wordCategories
                .where((w) => w.category == category)
                .toList();

            return _buildCategorySection(context, category, words);
          },
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    String category,
    List<WordSign> words,
  ) {
    final categoryEmoji = {
      'FOOD TREE': '🍎',
      'FEELINGS POND': '😊',
      'SCHOOL PATH': '🏫',
      'FAMILY MOUNTAIN': '👨‍👩‍👧',
    }[category] ?? '🌟';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Text(categoryEmoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 15),
              Text(
                category,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        ...words.map((word) => _buildWordCard(context, word)).toList(),
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildWordCard(BuildContext context, WordSign word) {
    final progressService = Provider.of<UserProgressService>(context);
    final isLearned = progressService.completedWords.contains(word.word);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isLearned ? Colors.green : Colors.grey[300]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: word.color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showWordDetail(context, word),
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: word.color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    word.emoji,
                    style: const TextStyle(fontSize: 35),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        word.word,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        word.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLearned)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 30,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showWordDetail(BuildContext context, WordSign word) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              word.emoji,
              style: const TextStyle(fontSize: 80),
            ),
            Text(
              word.word,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: word.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                word.description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_circle_filled, size: 60),
                    SizedBox(height: 10),
                    Text(
                      'Video Demonstration',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final progressService = Provider.of<UserProgressService>(
                      context,
                      listen: false,
                    );
                    await progressService.completeWord(word.word);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Great! You learned ${word.word}! +10 points 🎉'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
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
            ),
          ],
        ),
      ),
    );
  }
}
