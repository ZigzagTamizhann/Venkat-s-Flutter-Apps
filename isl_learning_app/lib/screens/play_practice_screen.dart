import 'package:flutter/material.dart';

class PlayPracticeScreen extends StatelessWidget {
  const PlayPracticeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Play & Practice')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGameTile(context, 'Sentence Builder', Icons.text_fields, true),
          _buildGameTile(context, 'Camera Challenge', Icons.camera_alt, true),
          _buildGameTile(context, 'Flower Collector', Icons.local_florist, true),
          _buildGameTile(context, 'Guess the Sign', Icons.question_mark, true), // Previously broken
          _buildGameTile(context, 'Memory Match', Icons.grid_view, true), // Previously broken
        ],
      ),
    );
  }

  Widget _buildGameTile(BuildContext context, String title, IconData icon, bool isEnabled) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        trailing: const Icon(Icons.play_arrow),
        enabled: isEnabled,
        onTap: isEnabled
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Starting $title...')),
                );
              }
            : null,
      ),
    );
  }
}