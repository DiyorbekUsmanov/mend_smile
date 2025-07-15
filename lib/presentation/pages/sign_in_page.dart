import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _name = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    final query = await FirebaseFirestore.instance
        .collection('patients')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      setState(() {
        _error = 'No patient found with that name.';
        _busy = false;
      });
    } else if (query.docs.first.data()['status'] != 'approved') {
      setState(() {
        _error = 'Patient found, but not yet approved by dentist.';
        _busy = false;
      });
    } else {
      setState(() => _busy = false);
      context.go('/patient_home_page');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mend Smile - Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            TextField(
              controller: _name,
              decoration: InputDecoration(
                labelText: 'Enter your full name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _busy ? null : _signIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _busy
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
