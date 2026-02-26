import 'package:flutter/material.dart';
import 'dart:math';
import 'alphabet_garden_screen.dart';
import '../models/sign_data.dart';

class QuickRecognitionScreen extends StatefulWidget {
  const QuickRecognitionScreen({Key? key}) : super(key: key);

  @override
  State<QuickRecognitionScreen> createState() => _QuickRecognitionScreenState();
}

class _QuickRecognitionScreenState extends State<QuickRecognitionScreen> {
  late SignData _currentQuestion;
  List<String> _options = [];
  int _score = 0;
  int _streak = 0;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    final data = AlphabetGardenScreen.alphabetData;
    _currentQuestion = data[_random.nextInt(data.length)];
    
    Set<String> optionsSet = {_currentQuestion.letter};
    while (optionsSet.length < 4) {
      optionsSet.add(data[_random.nextInt(data.length)].letter);
    }
    
    _options = optionsSet.toList()..shuffle();
    setState(() {});
  }

  void _checkAnswer(String selectedLetter) {
    if (selectedLetter == _currentQuestion.letter) {
      setState(() {
        _score += 10;
        _streak++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Correct! It is ${_currentQuestion.letter} 🎉'),
          backgroundColor: Colors.green,
          duration: const Duration(milliseconds: 500),
        ),
      );
      _generateQuestion();
    } else {
      setState(() {
        _streak = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oops! Try again.'),
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚡ Quick Recognition'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score: $_score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('Streak: 🔥 $_streak', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
              ],
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 120,
                        child: Image.asset(
                          'assets/${_currentQuestion.letter}.jpg',
                          errorBuilder: (context, error, stackTrace) => Text(_currentQuestion.emoji, style: const TextStyle(fontSize: 100)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "What letter is this?",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 2.5,
              children: _options.map((letter) {
                return ElevatedButton(
                  onPressed: () => _checkAnswer(letter),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade50,
                    foregroundColor: Colors.orange.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    letter,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}