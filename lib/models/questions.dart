class Question {
  final int id;
  final String question;
  final String answer;
  final String category;
  final String difficulty;

  Question({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    required this.difficulty,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['Question Number'] as int,
      question: map['Question'] as String,
      answer: map['Answer'] as String,
      category: map['Category'] as String,
      difficulty: map['Difficulty'] as String,
    );
  }
}