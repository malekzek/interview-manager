import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/interview.dart';
import 'package:flutter_application_3/models/resource.dart';
import 'package:flutter_application_3/models/user.dart';
import 'package:flutter_application_3/profile_screen.dart';
import 'package:provider/provider.dart';
import '/services/QuizProgressProvider.dart';
import '../services/database_service.dart';
import '../components/home/greeting_section.dart';
import '../components/home/interviews_section.dart';
import '../components/home/quick_actions.dart';
import '../components/home/progress_section.dart' as progress_section;
import '../components/home/resources_section.dart';
//import 'components/home/practice_quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _dbService = DatabaseService();
  late Future<User> _userFuture;
  late Future<List<Interview>> _interviewsFuture;
  late Future<List<Resource>> _resourcesFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    print('Loading initial data...');
    _userFuture = _dbService.getUserData();
    _interviewsFuture = _dbService.getUpcomingInterviews();
    _resourcesFuture = _dbService.getFeaturedResources();
  }

  void _handleRetry() {
    print('Retrying data load...');
    setState(_loadData);
  }

  @override
  Widget build(BuildContext context) {
    final filteredQuestionsLength = context.watch<QuizProgressProvider>().accumulated;

    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: FutureBuilder(
              future: Future.wait([
                _userFuture,
                _interviewsFuture,
                _resourcesFuture,
              ]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }

                if (snapshot.hasError) {
                  print('Error loading data: ${snapshot.error}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 48),
                        SizedBox(height: 16),
                        Text(
                          'Failed to load data.',
                          style: TextStyle(fontSize: 18, color: Colors.red),
                        ),
                        SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _handleRetry,
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final user = snapshot.data![0] as User;
                // final interviews = snapshot.data![1] as List<Interview>;
                // final resources = snapshot.data![2] as List<Resource>;

                // Provide the user dynamically to GreetingSection using Provider
                return ChangeNotifierProvider<User>.value(
                  value: user, // user must be a ChangeNotifier (see above)
                  child: Column(
                    children: [
                      const GreetingSection(),
                      SizedBox(height: 20),
                      InterviewsSection(),
                      SizedBox(height: 20),
                      QuickActionsSection(),
                      SizedBox(height: 20),
                      ResourcesSection(),
                      SizedBox(height: 20),
                      progress_section.ProgressSection(filteredQuestionsLength: filteredQuestionsLength),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading interview data...'),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('InterviewReady'),
      actions: [
        IconButton(
          icon: Icon(Icons.person),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileScreen()),
          ),
        ),
      ],
    );
  }
}