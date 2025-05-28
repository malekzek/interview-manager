// ignore_for_file: unnecessary_null_comparison

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/questions.dart';
import '../../services/database_service.dart';
import '../../services/QuizProgressProvider.dart';

class PracticeQuizScreen extends StatefulWidget {
  @override
  State<PracticeQuizScreen> createState() => _PracticeQuizScreenState();
}

class _PracticeQuizScreenState extends State<PracticeQuizScreen> {
  late Future<List<Question>> _questionsFuture;
  List<Question> _questions = [];
  List<String> _categories = [];
  List<String> _difficulties = [];
  String? selectedCategory;
  String? selectedDifficulty;
  int currentQuestion = 0;
  int score = 0;
  bool showResult = false;
  String? selectedOption;
  Map<int, List<String>> _questionOptions = {}; // Store options for each question by its id

  @override
  void initState() {
    super.initState();
    _questionsFuture = DatabaseService().getQuestions();
    _loadCategoriesAndDifficulties();
  }

  Future<void> _loadCategoriesAndDifficulties() async {
    final allQuestions = await DatabaseService().getQuestions();
    setState(() {
      _categories = allQuestions
          .map((q) => q.category)
          .where((c) => c != null && c.toString().trim().isNotEmpty)
          .toSet()
          .cast<String>()
          .toList();
      _difficulties = allQuestions
          .map((q) => q.difficulty)
          .where((d) => d != null && d.toString().trim().isNotEmpty)
          .toSet()
          .cast<String>()
          .toList();
    });
  }

  List<Question> get filteredQuestions {
    final filtered = _questions.where((q) {
      final catMatch = selectedCategory == null || q.category == selectedCategory;
      final diffMatch = selectedDifficulty == null || q.difficulty == selectedDifficulty;
      return catMatch && diffMatch;
    }).toList();
    return filtered.take(5).toList(); // MCQ quiz out of 5
  }

  /// Generates a shuffled list of 3 random incorrect answers and 1 correct answer for the current question.
  List<String> generateMcqOptions(Question currentQ) {
    List<String> allAnswers = _questions
        .where((q) => q.id != currentQ.id && q.answer.trim().isNotEmpty)
        .map((q) => q.answer)
        .toSet()
        .toList();

    allAnswers.shuffle(Random());
    List<String> options = allAnswers.take(3).toList();
    options.add(currentQ.answer);
    options.shuffle(Random());
    return options;
  }

  void _prepareOptionsForCurrentQuestion() {
    final question = filteredQuestions[currentQuestion];
    if (!_questionOptions.containsKey(question.id)) {
      _questionOptions[question.id] = generateMcqOptions(question);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Question>>(
      future: _questionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('Practice Quiz')),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('Practice Quiz')),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }
        _questions = (snapshot.data ?? []).where((q) => q != null).toList();

        if (selectedCategory != null && !_categories.contains(selectedCategory)) {
          selectedCategory = null;
        }
        if (selectedDifficulty != null && !_difficulties.contains(selectedDifficulty)) {
          selectedDifficulty = null;
        }

        if (filteredQuestions.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text('Practice Quiz')),
            body: Center(child: Text('No questions found for selected filters.')),
          );
        }

        final question = filteredQuestions[currentQuestion];
        _prepareOptionsForCurrentQuestion();
        final options = _questionOptions[question.id]!;

        // Update provider after build to avoid setState during build
      //  WidgetsBinding.instance.addPostFrameCallback((_) {
          //Provider.of<QuizProgressProvider>(context, listen: false)
            //  .accumulate(filteredQuestions.length);
       // });

        return Scaffold(
          appBar: AppBar(title: Text('Practice Quiz')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: showResult
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Quiz Complete!', style: TextStyle(fontSize: 24)),
                      SizedBox(height: 16),
                      Text('Score: $score / ${filteredQuestions.length}', style: TextStyle(fontSize: 20)),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _restart,
                        child: Text('Restart'),
                      ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Back'),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButton<String>(
                        value: selectedCategory,
                        hint: Text('Select Category'),
                        items: _categories
                            .map((cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat),
                                ))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedCategory = val;
                            currentQuestion = 0;
                            score = 0;
                            showResult = false;
                            selectedOption = null;
                            _questionOptions.clear();
                          });
                        },
                      ),
                      DropdownButton<String>(
                        value: selectedDifficulty,
                        hint: Text('Select Difficulty'),
                        items: _difficulties
                            .map((diff) => DropdownMenuItem(
                                  value: diff,
                                  child: Text(diff),
                                ))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedDifficulty = val;
                            currentQuestion = 0;
                            score = 0;
                            showResult = false;
                            selectedOption = null;
                            _questionOptions.clear();
                          });
                        },
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Q${question.id}: ${question.question}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      ...options.map((option) {
                        return RadioListTile<String>(
                          title: Text(option),
                          value: option,
                          groupValue: selectedOption,
                          onChanged: (val) {
                            setState(() {
                              selectedOption = val;
                            });
                          },
                        );
                      }).toList(),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: selectedOption == null ? null : _answer,
                        child: Text('Submit'),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  void _answer() {
    if (selectedOption == filteredQuestions[currentQuestion].answer) {
      score++;
    }
    if (currentQuestion < filteredQuestions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedOption = null;
      });
    } else {
      setState(() {
        showResult = true;
      });
    }

    // After quiz completion, e.g. in your _answer() or showResult logic:
    //final quizLength = filteredQuestions.length;
    Provider.of<QuizProgressProvider>(context, listen: false)
        .accumulate(1, dailyGoal: 20);
  }

  void _restart() {
    setState(() {
      currentQuestion = 0;
      score = 0;
      showResult = false;
      selectedOption = null;
      _questionOptions.clear(); // Clear options cache on restart
    });
    Provider.of<QuizProgressProvider>(context, listen: false).reset();
  }
}

class ProgressSection extends StatelessWidget {
  final int currentScore;
  const ProgressSection({Key? key, required this.currentScore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Score: $currentScore',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          ElevatedButton(
            onPressed: () {
              // Add your onPressed code here!
            },
            child: Text('Next Question'),
          ),
        ],
      ),
    );
  }
}