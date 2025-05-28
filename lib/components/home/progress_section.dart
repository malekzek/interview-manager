import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '/services/QuizProgressProvider.dart';

class ProgressSection extends StatefulWidget {
  final int filteredQuestionsLength;
  final int dailyGoal;

  const ProgressSection({
    super.key,
    required this.filteredQuestionsLength,
    this.dailyGoal = 20, // Default daily goal is 20
  });

  @override
  State<ProgressSection> createState() => _ProgressSectionState();
}

class _ProgressSectionState extends State<ProgressSection> {
  int _todayProgress = 0;
  String _todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadTodayProgress();
  }

  @override
  void didUpdateWidget(covariant ProgressSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filteredQuestionsLength != _todayProgress) {
      _saveTodayProgress(widget.filteredQuestionsLength);
    }
  }

  Future<void> _loadTodayProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString('progress_date');
    final savedProgress = prefs.getInt('progress_count') ?? 0;
    final today = _todayKey;

    if (savedDate == today) {
      setState(() {
        _todayProgress = savedProgress;
      });
    } else {
      // New day, reset progress
      await prefs.setString('progress_date', today);
      await prefs.setInt('progress_count', 0);
      setState(() {
        _todayProgress = 0;
      });
    }
  }

  Future<void> _saveTodayProgress(int progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('progress_date', _todayKey);
    await prefs.setInt('progress_count', progress);
    setState(() {
      _todayProgress = progress;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int filled = context.watch<QuizProgressProvider>().accumulated;
    final int total = widget.dailyGoal;

    return Column(
      children: [
        const _SectionHeader(title: 'Daily Progress'),
        const SizedBox(height: 20),
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: (total == 0) ? 0 : (filled / total).clamp(0.0, 1.0),
                strokeWidth: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              ),
              Text(
                '$filled / $total',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Text(
          'You\'ve answered $filled of $total questions today!',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        Text(
          filled >= total
              ? 'You\'ve reached your daily goal! 🎉'
              : 'Keep going to reach your daily goal!',
          style: TextStyle(
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

