import 'package:flutter/material.dart';
import '../../models/interview.dart';
import '../../services/database_service.dart';

class AllInterviewsScreen extends StatefulWidget {
  @override
  _AllInterviewsScreenState createState() => _AllInterviewsScreenState();
}

class _AllInterviewsScreenState extends State<AllInterviewsScreen> {
  late Future<List<Interview>> _interviewsFuture;
  final DatabaseService _dbService = DatabaseService();

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

  void _showAddInterviewDialog() {
    final _companyController = TextEditingController();
    final _roleController = TextEditingController();
    DateTime? _selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Add Interview'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _companyController,
                    decoration: InputDecoration(labelText: 'Company'),
                  ),
                  TextField(
                    controller: _roleController,
                    decoration: InputDecoration(labelText: 'Role'),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text(_selectedDate == null
                          ? 'Pick a date'
                          : '${_selectedDate!.toLocal()}'.split(' ')[0]),
                      Spacer(),
                      TextButton(
                        child: Text('Select Date'),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setStateDialog(() {
                              _selectedDate = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: Text('Add'),
                  onPressed: () async {
                    if (_companyController.text.isNotEmpty &&
                        _roleController.text.isNotEmpty &&
                        _selectedDate != null) {
                      await _dbService.insertInterview(
                        Interview(
                          company: _companyController.text,
                          role: _roleController.text,
                          date: _selectedDate!,
                          id: '', // id will be set by the database
                        ),
                      );
                      Navigator.of(context).pop();
                      _loadInterviews();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteInterview(String id) async {
    await _dbService.deleteInterview(id);
    _loadInterviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Interviews'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddInterviewDialog,
            tooltip: 'Add Interview',
          ),
        ],
      ),
      body: FutureBuilder<List<Interview>>(
        future: _interviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final interviews = snapshot.data ?? [];
          if (interviews.isEmpty) {
            return Center(child: Text('No interviews found.'));
          }
          return ListView.builder(
            itemCount: interviews.length,
            itemBuilder: (context, index) {
              final interview = interviews[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text('${interview.company} - ${interview.role}'),
                  subtitle: Text(interview.date.toString()),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteInterview(interview.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}