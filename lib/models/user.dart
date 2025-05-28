import 'package:flutter/material.dart';

class User extends ChangeNotifier {
  final String id;
  String name;
  final String gender;
  final String? avatarUrl;
  final DateTime? createdAt;
  final String age;
  final int currentScore;

  User({
    required this.id,
    required this.name,
    required this.gender,
    this.avatarUrl,
    this.createdAt,
    required this.age,
    this.currentScore = 0,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      id: data['id']?.toString() ?? '',
      name: data['name'] ?? 'User',
      gender: data['gender'] ?? 'gender',
      age: data['age'] ?? 'age',
      currentScore: data['current_score'] ?? 0,
      avatarUrl: data['avatar_url'],
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'age': age,
      'current_score': currentScore,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  void updateName(String newName) {
    name = newName;
    notifyListeners();
  }
}