import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mend_smile/data/doc_firebase.dart';
import '../../core/route_names.dart';
import '../../core/session_manager.dart';
import '../../data/firebase_service.dart';
import '../../data/patient_firebase.dart';
import '../../utils/AppColors.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  DateTime? _date;
  bool _waiting = false;
  bool _busy = false;

  String? _statusMessage;
  Color? _statusColor;

  Stream<DocumentSnapshot<Map<String, dynamic>>>? _statusStream;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.isEmpty || _phone.text.isEmpty || _date == null) {
      setState(() {
        _statusMessage = 'Please fill in all fields.';
        _statusColor = Colors.red;
      });
      return;
    }

    FocusScope.of(context).unfocus(); // hide keyboard
    setState(() {
      _busy = true;
      _statusMessage = null;
    });

    try {
      final docId = await PatientFirebaseService.instance.createPatient(
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        surgeryDate: _date!,
      );

      setState(() {
        _waiting = true;
        _busy = false;
      });

      _statusStream = DocFirebaseService.instance.patientStatusStream(docId);
      _statusStream!.listen((snap) async {
        final data = snap.data();
        if (data != null) {
          final status = data['status'];
          if (status == 'approved') {
            await SessionManager.saveSession('patient');
            context.go(RouteNames.patientHomePage);
          } else if (status == 'duplicate') {
            setState(() {
              _statusMessage =
                  '⛔ Patient already exists. Please use the Sign In page.';
              _statusColor = Colors.red;
              _waiting = false;
            });
          }
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage =
            'Error: ${e.toString().replaceFirst('Exception: ', '')}';
        _statusColor = Colors.red;
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_waiting) {
      return Scaffold(
        body: Center(
          child: _busy
              ? const CircularProgressIndicator()
              : const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    "Your request is sent.\nWaiting for dentist approval...",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors().primary,
        foregroundColor: Colors.white,
        title: const Text('Mend Smile - Sign Up'),
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Icon(
              Icons.app_registration_rounded,
              size: 80,
              color: AppColors().primary,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _name,
              decoration: _decor('Full Name', Icons.person),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phone,
              decoration: _decor('Phone Number', Icons.phone),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _date == null
                    ? 'Select Surgery Date'
                    : 'Surgery: ${_date!.toLocal().toString().split(' ').first}',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _busy ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors().primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _busy
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Submit'),
            ),
            if (_statusMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _statusMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _statusColor, fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  InputDecoration _decor(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
