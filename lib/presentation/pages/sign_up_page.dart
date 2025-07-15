import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mend_smile/presentation/pages/bottom_bar_pages/patient_home_page.dart';
import '../../data/firebase_service.dart';

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

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.isEmpty || _phone.text.isEmpty || _date == null) return;
    setState(() {
      _busy = true;
      _statusMessage = null;
    });
    final query = await FirebaseFirestore.instance
        .collection('patients')
        .where('name', isEqualTo: _name.text.trim())
        .where('phone', isEqualTo: _phone.text.trim())
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final status = query.docs.first.data()['status'];
      if (status == 'approved') {
        setState(() {
          _statusMessage = '✅ Patient is approved, please go to sign-in page.';
          _statusColor = Colors.green;
          _busy = false;
        });
      } else {
        setState(() {
          _statusMessage = '⛔ Patient found, but not yet approved by dentist.';
          _statusColor = Colors.red;
          _busy = false;
        });
      }
      return;
    }

    await FirebaseService.instance.createPatient(
      name: _name.text,
      phone: _phone.text,
      surgeryDate: _date!,
    );
    setState(() {
      _waiting = true;
      _busy = false;
    });

    FirebaseService.instance.patientStatusStream().listen((snap) {
      if (snap.data()?['status'] == 'approved') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const PatientHomePage()
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_waiting) {
      return Scaffold(
        body: Center(
          child: _busy
              ? const CircularProgressIndicator()
              : const Text(
                  "Your request is sent. Waiting for dentist approval...",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mend Smile - Patient Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
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
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _busy ? null : _submit,
              child: const Text('Submit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
      fillColor: Colors.grey.shade100,
    );
  }
}
