import 'package:flutter/material.dart';

class QuizProgressProvider extends ChangeNotifier {
  int _accumulated = 0;

  int get accumulated => _accumulated;

  /// Call this ONCE per quiz session, with the number of new questions answered.
  void accumulate(int value, {int dailyGoal = 20}) {
    if (_accumulated < dailyGoal) {
      int allowed = (_accumulated + value > dailyGoal)
          ? dailyGoal - _accumulated
          : value;
      if (allowed > 0) {
        _accumulated += allowed;
        debugPrint('Accumulated $allowed, total now $_accumulated');
        notifyListeners();
      }
    }
  }

  void reset() {
    _accumulated = 0;
    notifyListeners();
  }
}