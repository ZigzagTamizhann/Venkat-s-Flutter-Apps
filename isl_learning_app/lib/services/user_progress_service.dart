import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_avatar.dart';

class UserProgressService extends ChangeNotifier {
  UserAvatar? _avatar;
  int _points = 0;
  int _streak = 0;
  List<String> _badges = [];
  Set<String> _completedLetters = {};
  Set<String> _completedWords = {};
  int _storiesCompleted = 0;

  UserAvatar? get avatar => _avatar;
  int get points => _points;
  int get streak => _streak;
  List<String> get badges => _badges;
  Set<String> get completedLetters => _completedLetters;
  Set<String> get completedWords => _completedWords;
  int get storiesCompleted => _storiesCompleted;
  int get level => (_points / 100).floor() + 1;

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();

    final avatarJson = prefs.getString('avatar');
    if (avatarJson != null) {
      _avatar = UserAvatar.fromJson(json.decode(avatarJson));
    }

    _points = prefs.getInt('points') ?? 0;
    _streak = prefs.getInt('streak') ?? 0;
    _badges = prefs.getStringList('badges') ?? [];
    _completedLetters = (prefs.getStringList('completedLetters') ?? []).toSet();
    _completedWords = (prefs.getStringList('completedWords') ?? []).toSet();
    _storiesCompleted = prefs.getInt('storiesCompleted') ?? 0;

    notifyListeners();
  }

  Future<void> saveAvatar(UserAvatar avatar) async {
    _avatar = avatar;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatar', json.encode(avatar.toJson()));
    notifyListeners();
  }

  Future<void> addPoints(int points) async {
    _points += points;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('points', _points);

    // Check for level up
    final newLevel = level;
    if (_avatar != null && newLevel > _avatar!.level) {
      _avatar = _avatar!.copyWith(level: newLevel);
      await prefs.setString('avatar', json.encode(_avatar!.toJson()));
    }

    notifyListeners();
  }

  Future<void> completeSign(String letter) async {
    _completedLetters.add(letter);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('completedLetters', _completedLetters.toList());
    await addPoints(5);

    // Check for alphabet master badge
    if (_completedLetters.length >= 26 && !_badges.contains('alphabet_master')) {
      await addBadge('alphabet_master');
    }
  }

  Future<void> completeWord(String word) async {
    _completedWords.add(word);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('completedWords', _completedWords.toList());
    await addPoints(10);
  }

  Future<void> completeStory() async {
    _storiesCompleted++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('storiesCompleted', _storiesCompleted);
    await addPoints(20);

    if (_storiesCompleted >= 10 && !_badges.contains('story_hero')) {
      await addBadge('story_hero');
    }
  }

  Future<void> addBadge(String badge) async {
    if (!_badges.contains(badge)) {
      _badges.add(badge);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('badges', _badges);
      notifyListeners();
    }
  }

  Future<void> updateStreak() async {
    _streak++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('streak', _streak);
    notifyListeners();
  }

  String getLevelTitle() {
    if (level < 5) return 'Sign Beginner';
    if (level < 10) return 'Sign Explorer';
    if (level < 15) return 'Sign Master';
    return 'Sign Champion';
  }
}
