import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:mend_smile/core/route_names.dart';
import 'package:mend_smile/core/session_manager.dart';
import 'package:mend_smile/data/doc_firebase.dart';
import 'package:mend_smile/presentation/pages/doctor_pages/test_results_page.dart';
import '../../../utils/AppColors.dart';

class ViewPatientsPage extends StatefulWidget {
  const ViewPatientsPage({Key? key}) : super(key: key);

  @override
  State<ViewPatientsPage> createState() => _ViewPatientsPageState();
}

class _ViewPatientsPageState extends State<ViewPatientsPage> {
  Future<void> _refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🦷 All Patients'),
        backgroundColor: AppColors().primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text(
                    'Log Out',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppColors().primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Log Out'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await SessionManager.clearSession();
                if (context.mounted) context.go(RouteNames.loginPage);
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Pending Patients'),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: DocFirebaseService.instance.pendingPatientsStream(),
                builder: (_, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snap.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return const Text('No pending patients.');
                  }

                  return Column(
                    children: docs
                        .map((doc) => _buildPatientTile(doc, isApproved: false))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 30),
              _buildSectionTitle('Approved Patients'),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: DocFirebaseService.instance.approvedPatientsStream(),
                builder: (_, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snap.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return const Text('No approved patients.');
                  }

                  return Column(
                    children: docs
                        .map((doc) => _buildPatientTile(doc, isApproved: true))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildPatientTile(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required bool isApproved,
  }) {
    final data = doc.data()!;
    final patientId = doc.id;
    final name = data['name'] ?? 'No Name';
    final surgeryDate = DateTime.parse(
      data['surgeryDate'],
    ).toLocal().toString().split(' ')[0];

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('Surgery: $surgeryDate'),
        trailing: isApproved
            ? const Icon(Icons.chevron_right)
            : IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () => _confirmApproval(context, patientId, name),
              ),
        onTap: isApproved
            ? () {
                final startDateStr = data['surgeryDate'];
                final endDateStr = DateTime.parse(
                  startDateStr,
                ).add(const Duration(days: 30)).toIso8601String();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TestResultsPage(
                      patientId: patientId,
                      name: name,
                      startDate: startDateStr,
                      endDate: endDateStr,
                    ),
                  ),
                );
              }
            : null,
      ),
    );
  }

  Future<void> _confirmApproval(
    BuildContext context,
    String docId,
    String name,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Approve Patient',
          style: TextStyle(color: AppColors().primary),
        ),
        content: Text('Are you sure you want to approve $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors().primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DocFirebaseService.instance.approvePatient(docId);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$name has been approved.')));
      }
    }
  }
}
