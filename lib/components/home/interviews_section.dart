import 'package:flutter/material.dart';
import 'package:flutter_application_3/components/home/all_interviews_screen.dart';
import 'package:flutter_application_3/components/home/practice_quiz_screen.dart';
import '../../models/interview.dart';
import '../../services/database_service.dart';

class InterviewsSection extends StatefulWidget {
  const InterviewsSection({Key? key}) : super(key: key);

  @override
  State<InterviewsSection> createState() => _InterviewsSectionState();
}

class _InterviewsSectionState extends State<InterviewsSection> {
  late Future<List<Interview>> _interviewsFuture;
  final DatabaseService _dbService = DatabaseService();
  bool _showInsertForm = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInterviews();
  }

  void _loadInterviews() {
    setState(() {
      _interviewsFuture = _dbService.getUpcomingInterviews();
    });
  }

  Future<void> _insertInterview(String company, String role, DateTime date) async {
    final interview = Interview(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      company: company,
      role: role,
      date: date,
    );
    await _dbService.insertInterview(interview);
    setState(() {
      _showInsertForm = false;
      // Do not reload interviews here so it doesn't display immediately
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Interview>>(
      future: _interviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final interviews = snapshot.data ?? [];
        if (interviews.isEmpty && !_showInsertForm) {
          return Column(
            children: [
              const SizedBox(height: 20),
              const Text('No interviews found.'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showInsertForm = true;
                  });
                },
                child: const Text('Insert Interview'),
              ),
            ],
          );
        }
        if (_showInsertForm) {
          return _InsertInterviewForm(
            onInsert: (company, role, date) async {
              await _insertInterview(company, role, date);
            },
            onCancel: () {
              setState(() {
                _showInsertForm = false;
              });
            },
          );
        }
        return Column(
          children: [
            _buildSectionHeader(context, 'Upcoming Interviews', 'View All'),
            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              child: interviews.isEmpty
                  ? const Center(child: Text('No interviews found.'))
                  : 
                  Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: interviews.length,
                        itemBuilder: (context, index) =>
                            _buildInterviewCard(interviews[index]),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18)),
        TextButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AllInterviewsScreen()),
            );
            _loadInterviews();
          },
          child: Text(actionText),
        ),
      ],
    );
  }

  Widget _buildInterviewCard(Interview interview) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(interview.date.toString()),
          Text(interview.company, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(interview.role),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PracticeQuizScreen()));
              },
              child: const Text('Prepare Now'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsertInterviewForm extends StatefulWidget {
  final void Function(String company, String role, DateTime date) onInsert;
  final VoidCallback onCancel;

  const _InsertInterviewForm({
    required this.onInsert,
    required this.onCancel,
  });

  @override
  State<_InsertInterviewForm> createState() => _InsertInterviewFormState();
}

class _InsertInterviewFormState extends State<_InsertInterviewForm> {
  final _formKey = GlobalKey<FormState>();
  String _company = '';
  String _role = '';
  DateTime _date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Company'),
              onChanged: (val) => _company = val,
              validator: (val) => val == null || val.isEmpty ? 'Enter company' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Role'),
              onChanged: (val) => _role = val,
              validator: (val) => val == null || val.isEmpty ? 'Enter role' : null,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Date:'),
                const SizedBox(width: 10),
                Text('${_date.toLocal()}'.split(' ')[0]),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        _date = picked;
                      });
                    }
                  },
                  child: const Text('Pick Date'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Call the insertInterview function from DatabaseService directly
                      await DatabaseService().insertInterview(
                        Interview(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          company: _company,
                          role: _role,
                          date: _date,
                        ),
                      );
                      widget.onInsert(_company, _role, _date); // Optionally keep this if you want to trigger parent logic
                    }
                  },
                  child: const Text('Insert'),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}