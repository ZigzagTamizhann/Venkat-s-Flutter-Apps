import 'package:flutter/material.dart';
import 'dart:math';
import 'alphabet_garden_screen.dart';
import '../models/sign_data.dart';

class FlowerCollectorScreen extends StatefulWidget {
  const FlowerCollectorScreen({Key? key}) : super(key: key);

  @override
  State<FlowerCollectorScreen> createState() => _FlowerCollectorScreenState();
}

class _FlowerCollectorScreenState extends State<FlowerCollectorScreen> {
  final List<String> _collectedFlowers = [];
  late SignData _targetSign;
  List<SignData> _options = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateRound();
  }

  void _generateRound() {
    final data = AlphabetGardenScreen.alphabetData;
    _targetSign = data[_random.nextInt(data.length)];
    
    // Create options: 1 correct + 2 wrong
    Set<SignData> optionsSet = {_targetSign};
    while (optionsSet.length < 3) {
      optionsSet.add(data[_random.nextInt(data.length)]);
    }
    _options = optionsSet.toList()..shuffle();
  }

  void _startNewRound() {
    _generateRound();
    setState(() {});
  }

  void _collectFlower(SignData selected) {
    if (selected.letter == _targetSign.letter) {
      setState(() {
        _collectedFlowers.add(selected.emoji);
      });
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not that one! Try again.')),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Flower Collected! 🌸'),
        content: Text('You found the letter ${_targetSign.letter}!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startNewRound();
            },
            child: const Text('Next Flower'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌸 Flower Collector'),
        backgroundColor: Colors.pink,
      ),
      body: Column(
        children: [
          // Basket Area
          Container(
            height: 120,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.pink.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My Basket (${_collectedFlowers.length})', 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.pink)),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _collectedFlowers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(_collectedFlowers[index], style: const TextStyle(fontSize: 32)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          const Text(
            'Find the sign for:',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          Text(
            _targetSign.letter,
            style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.pink),
          ),
          
          const Spacer(),
          
          // Garden Options
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: _options.map((sign) {
              return GestureDetector(
                onTap: () => _collectFlower(sign),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green.shade200, width: 3),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/${sign.letter}.jpg',
                    errorBuilder: (context, error, stackTrace) => Text(sign.emoji, style: const TextStyle(fontSize: 40)),
                  ),
                ),
              );
            }).toList(),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}