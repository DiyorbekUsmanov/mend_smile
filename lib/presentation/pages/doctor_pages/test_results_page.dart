import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:mend_smile/core/route_names.dart';

class TestResultsPage extends StatefulWidget {
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

  @override
  State<TestResultsPage> createState() => _TestResultsPageState();
}

class _TestResultsPageState extends State<TestResultsPage> {
  bool isTestGiven = false;


  Stream<QuerySnapshot<Map<String, dynamic>>> get quizDatesStream {
    return FirebaseFirestore.instance
        .collection('patients')
        .doc(widget.patientId)
        .collection('qa')
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final start = widget.startDate != null
        ? DateTime.parse(widget.startDate!)
        : null;
    final end = widget.endDate != null ? DateTime.parse(widget.endDate!) : null;
    final now = DateTime.now();
    final isTestFinished = end != null && now.isAfter(end);

    return Scaffold(
      appBar: AppBar(title: Text('${widget.name} - Test Results')),
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
                    Text(
                      start != null ? '${start.toLocal()}'.split(' ')[0] : '-',
                    ),
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
                        context.push(
                          RouteNames.quizResultDetailPage,
                          extra: {
                            'patientId': widget.patientId,
                            'quizId': quizDate,
                            'quizData': data,
                          },
                        );
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
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('patients')
                    .doc(widget.patientId)
                    .update({'forceQaAccess': true});

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isTestFinished
                          ? 'Test re-enabled for patient.'
                          : 'QA access granted.',
                    ),
                  ),
                );
              },
              icon: Icon(
                isTestFinished ? Icons.restart_alt : Icons.check_circle,
              ),
              label: Text(
                isTestFinished
                    ? 'Re-give the Test'
                    : 'The test is still available',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isTestFinished ? Colors.orange : Colors.green,
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
