class Interview {
  final String id;
  final String company;
  final String role;
  final DateTime date;

  Interview({
    required this.id,
    required this.company,
    required this.role,
    required this.date,
  });

  factory Interview.fromMap(Map<String, dynamic> data) {
    return Interview(
      id: data['id'].toString(),
      company: data['company'],
      role: data['role'],
      date: DateTime.parse(data['date']),
    );
  }
}