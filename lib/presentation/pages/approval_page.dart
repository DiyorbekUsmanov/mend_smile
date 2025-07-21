import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:mend_smile/core/route_names.dart';
import 'package:mend_smile/core/session_manager.dart';

import '../../data/firebase_service.dart';

class ApprovalPage extends StatelessWidget {
  const ApprovalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🦷 Patient Approval'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await SessionManager.clearSession();
              context.go(RouteNames.loginPage);
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseService.instance.pendingPatientsStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }

          final docs = snap.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No pending patients',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final data = docs[i].data();
              final name = data['name'] ?? 'Unknown';
              final phone = data['phone'] ?? 'No phone';
              final millis = data['surgeryDateMillis'];
              final date = millis != null
                  ? DateTime.fromMillisecondsSinceEpoch(millis).toLocal().toString().split(' ').first
                  : 'Unknown date';

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.person_outline, size: 32, color: Colors.teal),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(phone),
                      Text('Surgery Date: $date'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _confirmApproval(context, docs[i].id, name),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Approve'),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmApproval(BuildContext context, String docId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Approve Patient'),
        content: Text('Are you sure you want to approve $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseService.instance.approvePatient(docId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name has been approved.')),
      );
    }
  }
}