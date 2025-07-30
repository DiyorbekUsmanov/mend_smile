import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation_screen.dart';
import '../../core/route_names.dart';
import '../../core/session_manager.dart';
import '../../utils/AppColors.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> _showAdminDialog(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final nameCtrl = TextEditingController();
        final passCtrl = TextEditingController();

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          title: Text(
            'Admin Login',
            style: TextStyle(
              color: AppColors().primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person, color: AppColors().primary),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors().primary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock, color: AppColors().primary),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors().primary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.only(right: 12, bottom: 8),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel',style: TextStyle(color: AppColors().primary),),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors().primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                final isValid = nameCtrl.text == 'admin' && passCtrl.text == 'password';
                Navigator.pop(ctx, isValid);
              },
              child: const Text('Enter'),
            ),
          ],
        );
      },
    );

    if (ok == true) {
      await SessionManager.saveSession('admin');
      if (context.mounted) context.go(RouteNames.viewPatientsPage);
    } else if (ok == false) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid admin credentials')),
        );
      }
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
