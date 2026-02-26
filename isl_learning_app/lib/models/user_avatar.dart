// lib/models/user_avatar.dart
import 'package:flutter/material.dart';

class UserAvatar {
  final String name;
  final Color skinColor;
  final Color hairColor;
  final Color shirtColor;
  final String accessory;
  final int level;
  final String gender; // 'male' or 'female'

  UserAvatar({
    required this.name,
    this.skinColor = const Color(0xFFFFDBB4),
    this.hairColor = const Color(0xFF5C3317),
    this.shirtColor = const Color(0xFF5BB8FF),
    this.accessory = 'none',
    this.level = 1,
    this.gender = 'male',
  });

  UserAvatar copyWith({
    String? name, Color? skinColor, Color? hairColor, Color? shirtColor,
    String? accessory, int? level, String? gender,
  }) {
    return UserAvatar(
      name: name ?? this.name, skinColor: skinColor ?? this.skinColor,
      hairColor: hairColor ?? this.hairColor, shirtColor: shirtColor ?? this.shirtColor,
      accessory: accessory ?? this.accessory, level: level ?? this.level,
      gender: gender ?? this.gender,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name, 'skinColor': skinColor.value, 'hairColor': hairColor.value,
    'shirtColor': shirtColor.value, 'accessory': accessory, 'level': level, 'gender': gender,
  };

  factory UserAvatar.fromJson(Map<String, dynamic> json) => UserAvatar(
    name: json['name'] ?? 'Friend',
    skinColor: Color(json['skinColor'] ?? 0xFFFFDBB4),
    hairColor: Color(json['hairColor'] ?? 0xFF5C3317),
    shirtColor: Color(json['shirtColor'] ?? 0xFF5BB8FF),
    accessory: json['accessory'] ?? 'none',
    level: json['level'] ?? 1,
    gender: json['gender'] ?? 'male',
  );
}