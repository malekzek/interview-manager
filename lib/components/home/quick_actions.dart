import 'package:flutter/material.dart';
import 'package:flutter_application_3/components/home/practice_quiz_screen.dart';

class QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: _buildActionCard(Icons.chat_bubble, 'Practice', context),
    );
  }

  Widget _buildActionCard(IconData icon, String title, BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: InkWell(
        onTap: () {
          if (title == 'Practice') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PracticeQuizScreen()),
            );
          }
        },
        child: SizedBox(
          width: 700,
          height: 350,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40),
                SizedBox(height: 8),
                Text(title, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}