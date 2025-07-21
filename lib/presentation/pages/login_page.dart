import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation_screen.dart';
import '../../core/route_names.dart';
import '../../core/session_manager.dart';
import '../../utils/AppColors.dart';
import '../../data/firebase_service.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> _showAdminDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Admin Login'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final isValid = nameCtrl.text == 'admin' && passCtrl.text == 'password';
              Navigator.pop(ctx, isValid);
            },
            child: const Text('Enter'),
          ),
        ],
      ),
    );

    nameCtrl.dispose();
    passCtrl.dispose();

    if (ok == true) {
      await SessionManager.saveSession('admin');
      context.push(RouteNames.approvalPage);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid admin credentials')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: AppColors().primary,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 56),
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors().primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors().primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Image.asset("assets/images/logo.png", width: 160, height: 160),
                        const SizedBox(height: 24),
                        Text(
                          'Welcome to Mend Smile',
                          style: TextStyle(
                            color: AppColors().primary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.login),
                          label: const Text('Sign In'),
                          onPressed: () => context.push(RouteNames.signInPage),
                          style: buttonStyle,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.admin_panel_settings),
                          label: const Text('Sign in as Admin'),
                          onPressed: () => _showAdminDialog(context),
                          style: buttonStyle.copyWith(
                            backgroundColor: MaterialStateProperty.all(Colors.deepOrange),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () => context.push(RouteNames.signUpPage),
                          child: Text(
                            "Don't have an account? Sign Up",
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors().primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
