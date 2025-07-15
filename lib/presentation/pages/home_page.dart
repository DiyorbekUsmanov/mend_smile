import 'package:flutter/material.dart';
import 'package:mend_smile/presentation/pages/welcome_page.dart';
import 'sign_up_page.dart';
import 'approval_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _showAdminDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Admin Login'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(
              ctx,
              nameCtrl.text == 'admin' && passCtrl.text == 'password',
            ),
            child: const Text('Enter'),
          ),
        ],
      ),
    );
    if (ok == true) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ApprovalPage()),
      );
    }else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid admin credentials')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 4,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Mend Smile')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              style: buttonStyle,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WelcomePage()),
              ),
              child: const Text('Patient Login'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: buttonStyle,
              onPressed: () => _showAdminDialog(context),
              child: const Text('Dentist Approval'),
            ),
          ],
        ),
      ),
    );
  }
}
