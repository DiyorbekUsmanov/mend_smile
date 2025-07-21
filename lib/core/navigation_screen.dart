import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/pages/bottom_bar_pages/patient_home_page.dart';
import '../utils/AppColors.dart';

class NavigationScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const NavigationScreen({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(index);
  }

  static const _destinations = [
    _NavDestination(icon: Icons.video_camera_front, label: 'Video Therapy'),
    _NavDestination(icon: Icons.fastfood, label: 'Diet Table'),
    _NavDestination(icon: Icons.home, label: 'Home'),
    _NavDestination(icon: Icons.question_answer, label: 'Questionnaire'),
    _NavDestination(icon: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(60), topRight: Radius.circular(60)),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            NavigationBar(
              height: 60,
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onTap,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              backgroundColor: AppColors().primary,
              indicatorColor: Colors.transparent,
              destinations: List.generate(_destinations.length, (index) {
                final isCenter = index == 2;
                return isCenter
                    ? const NavigationDestination(
                        icon: SizedBox.shrink(),
                        label: '',
                      ) // placeholder
                    : NavigationDestination(
                        icon: Icon(_destinations[index].icon, size: 30),
                        selectedIcon: Icon(
                          _destinations[index].icon,
                          color: Colors.white,
                          size: 30,
                        ),
                        label: _destinations[index].label,
                      );
              }),
            ),
            Positioned(
              top: -20,
              child: GestureDetector(
                onTap: () => _onTap(2),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: navigationShell.currentIndex == 2
                        ? Colors.white
                        : AppColors().primary,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.home,
                    size: 32,
                    color: navigationShell.currentIndex == 2
                        ? AppColors().primary
                        : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavDestination {
  final IconData icon;
  final String label;

  const _NavDestination({required this.icon, required this.label});
}
