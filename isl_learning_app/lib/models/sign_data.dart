
import 'package:flutter/material.dart';

class SignData {
  final String letter;
  final String funFact;
  final String description;
  final String emoji;

  SignData({
    required this.letter,
    required this.funFact,
    required this.description,
    required this.emoji,
  });
}

class WordSign {
  final String word;
  final String emoji;
  final String category;
  final String description;
  final Color color;

  WordSign({
    required this.word,
    required this.emoji,
    required this.category,
    required this.description,
    required this.color,
  });
}

class Story {
  final String title;
  final String chapter;
  final List<StoryScene> scenes;
  final String moral;

  Story({
    required this.title,
    required this.chapter,
    required this.scenes,
    required this.moral,
  });
}

class StoryScene {
  final String avatarEmotion;
  final String signText;
  final String narrative;
  final String? interactionPrompt;
  final String? practiceSign;

  StoryScene({
    required this.avatarEmotion,
    required this.signText,
    required this.narrative,
    this.interactionPrompt,
    this.practiceSign,
  });
}

