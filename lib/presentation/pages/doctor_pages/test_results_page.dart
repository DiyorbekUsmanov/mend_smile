import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:mend_smile/core/route_names.dart';

class TestResultsPage extends StatelessWidget {
  final String patientId;
  final String name;
  final String? startDate;
  final String? endDate;

  const TestResultsPage({
    super.key,
    required this.patientId,
    required this.name,
    this.startDate,
    this.endDate,
  });

  Stream<QuerySnapshot<Map<String, dynamic>>> get quizDatesStream {
    return FirebaseFirestore.instance
        .collection('patients')
        .doc(patientId)
        .collection('qa')
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final start = startDate != null ? DateTime.parse(startDate!) : null;
    final end = endDate != null ? DateTime.parse(endDate!) : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('$name - Test Results'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.teal.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Start Date'),
                    Text(start != null ? '${start.toLocal()}'.split(' ')[0] : '-'),
                  ],
                ),
                Column(
                  children: [
                    const Text('End Date'),
                    Text(end != null ? '${end.toLocal()}'.split(' ')[0] : '-'),
                  ],
                ),
                Column(
                  children: [
                    const Text('Progress'),
                    Text(_calculateProgress(start, end)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: quizDatesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('No quiz results found.'));
                }
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final quizDate = docs[index].id;

                    return ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text('Quiz Date: $quizDate'),
                      onTap: () {
                        context.push(RouteNames.quizResultDetailPage, extra: {
                          'patientId': patientId,
                          'quizId': quizDate,
                          'quizData': data,
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                context.go(RouteNames.qaPage); // navigate back to QA page
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Re-give Quiz"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateProgress(DateTime? start, DateTime? end) {
    if (start == null || end == null) return '-';
    final total = end.difference(start).inDays + 1;
    final done = DateTime.now().difference(start).inDays + 1;
    final percent = (done / total * 100).clamp(0, 100).toStringAsFixed(0);
    return '$percent%';
  }
}
