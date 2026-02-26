import 'package:flutter/material.dart';

class TodaysGoalScreen extends StatelessWidget {
  const TodaysGoalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Today's Goal")),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Learn these 3 letters:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: const [
                _LetterCard(letter: 'A', description: 'Closed fist, thumb on side'),
                _LetterCard(letter: 'B', description: 'Flat palm, thumb tucked'),
                _LetterCard(letter: 'C', description: 'Curved hand like a C'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LetterCard extends StatelessWidget {
  final String letter;
  final String description;

  const _LetterCard({required this.letter, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Image.asset(
                'assets/$letter.jpg',
                errorBuilder: (context, error, stackTrace) => Text(letter, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue)),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Letter $letter', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}