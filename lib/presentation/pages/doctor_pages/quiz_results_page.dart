import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuizResultsPage extends StatelessWidget {
  const QuizResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>;
    final quizId = extra['quizId'] as String;
    final data = extra['quizData'] as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text('Results - $quizId'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _resultRow("Pain Level", data['painLevel']?.toString() ?? '-'),
            _resultRow("Has Headache", data['hasHeadache'] == true ? 'Yes' : 'No'),
            _resultRow("Meals per Day", data['mealsPerDay']?.toString() ?? '-'),
            _resultRow("Note", data['note'] ?? '-'),
            _resultRow("Submitted At", (data['submittedAt'] as Timestamp?)?.toDate().toLocal().toString() ?? '-'),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }
}
