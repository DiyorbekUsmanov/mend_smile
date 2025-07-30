import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mend_smile/core/route_names.dart';

import '../../../data/patient_firebase.dart';
import '../../../utils/AppColors.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  final List<String> _quotes = [
    "You’re stronger than you think.",
    "Every smile begins with you.",
    "One step closer to healing.",
    "Keep going, you're doing great!",
    "Progress, not perfection.",
  ];
  int _quoteIndex = 0;
  Timer? _timer;
  String name = '';
  String phone = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() => _quoteIndex = (_quoteIndex + 1) % _quotes.length);
    });
  }

  Future<void> loadProfile() async {
    final docId = PatientFirebaseService.instance.getCurrentPatientDocId();
    if (docId != null) {
      final data = await PatientFirebaseService.instance.getPatientProfile(docId);
      if (data != null) {
        setState(() {
          name = data['name'] ?? '';
          phone = data['phone'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DateTime startDate = DateTime.now().subtract(const Duration(days: 19));
    final DateTime endDate = startDate.add(const Duration(days: 30));
    final double progress = DateTime.now().difference(startDate).inDays / 30.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors().primary,
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage('assets/images/user_placeholder.png'),
            ),
            const SizedBox(width: 12),
            isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    phone,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.notifications_none, color: Colors.white),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProgressBar(startDate, endDate, progress),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navBox(
                  icon: Icons.video_camera_front,
                  label: 'Video Therapy',
                  color: Colors.teal,
                  route: RouteNames.videoPage,
                ),
                _navBox(
                  icon: Icons.question_answer,
                  label: 'Questionnaire',
                  color: Colors.orange,
                  route: RouteNames.qaPage,
                ),
              ],
            ),
            const Spacer(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(_quoteIndex),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal),
                ),
                child: Text(
                  _quotes[_quoteIndex],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(DateTime start, DateTime end, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Mending Progress',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation(AppColors().primary),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Start: ${start.toLocal().toString().split(' ').first}"),
            Text("End: ${end.toLocal().toString().split(' ').first}"),
          ],
        ),
      ],
    );
  }

  Widget _navBox({
    required IconData icon,
    required String label,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
