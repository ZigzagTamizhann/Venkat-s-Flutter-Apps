import 'package:flutter/material.dart';
import 'alphabet_garden_screen.dart';
import '../models/sign_data.dart';

class SpellNameScreen extends StatefulWidget {
  const SpellNameScreen({Key? key}) : super(key: key);

  @override
  State<SpellNameScreen> createState() => _SpellNameScreenState();
}

class _SpellNameScreenState extends State<SpellNameScreen> {
  final TextEditingController _controller = TextEditingController();
  List<SignData> _spelledSigns = [];

  void _spellName() {
    final text = _controller.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    final List<SignData> signs = [];
    
    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      try {
        final sign = AlphabetGardenScreen.alphabetData.firstWhere(
          (s) => s.letter == char,
        );
        signs.add(sign);
      } catch (e) {
        // Ignore characters not in our data
      }
    }

    setState(() {
      _spelledSigns = signs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('✍️ Spell Your Name'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.blue.shade50,
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Enter your name',
                    hintText: 'e.g., SAM',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: Colors.blue),
                      onPressed: _spellName,
                    ),
                  ),
                  onChanged: (_) => _spellName(),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Type your name to see it in signs!',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: _spelledSigns.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.back_hand, size: 64, color: Colors.blue.shade200),
                        const SizedBox(height: 16),
                        const Text(
                          'Your signs will appear here',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _spelledSigns.length,
                    itemBuilder: (context, index) {
                      final sign = _spelledSigns[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 60,
                              child: Image.asset(
                                'assets/${sign.letter}.jpg',
                                errorBuilder: (context, error, stackTrace) =>
                                    Text(sign.emoji, style: const TextStyle(fontSize: 40)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              sign.letter,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}