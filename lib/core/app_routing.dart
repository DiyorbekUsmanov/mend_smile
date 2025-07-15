import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mend_smile/presentation/pages/approval_page.dart';
import 'package:mend_smile/presentation/pages/sign_up_page.dart';
import 'package:mend_smile/presentation/pages/sign_in_page.dart';
import 'package:mend_smile/presentation/pages/bottom_bar_pages/diet_page.dart';
import 'package:mend_smile/presentation/pages/bottom_bar_pages/patient_home_page.dart';
import 'package:mend_smile/presentation/pages/bottom_bar_pages/profile_page.dart';
import 'package:mend_smile/presentation/pages/bottom_bar_pages/qa_page.dart';
import 'package:mend_smile/presentation/pages/bottom_bar_pages/video_page.dart';
import 'package:mend_smile/presentation/pages/home_page.dart';
import 'navigation_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/home_page',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            NavigationScreen(navigationShell: navigationShell),
        branches: _buildNavigationBranches(),
      ),..._buildStandaloneRoutes(),
    ],
  );

  static List<StatefulShellBranch> _buildNavigationBranches() {
    final navRoutes = [
      {'path': '/video_page', 'page': const VideoPage()},
      {'path': '/diet_page', 'page': const DietPage()},
      {'path': '/patient_home_page', 'page': const PatientHomePage()},
      {'path': '/qa_page', 'page': const QaPage()},
      {'path': '/profile_page', 'page': const ProfilePage()},
    ];

    return navRoutes.map((route) => StatefulShellBranch(
      routes: [
        GoRoute(
          path: route['path'] as String,
          pageBuilder: (context, state) => NoTransitionPage(
            child: route['page'] as Widget,
          ),
        ),
      ],
    )).toList();
  }

  static List<GoRoute> _buildStandaloneRoutes() {
    final otherRoutes = [
      {'path': '/home_page', 'page': const HomePage()},
      {'path': '/approval_page', 'page': const ApprovalPage()},
      {'path': '/sign_in_page', 'page': const SignInPage()},
      {'path': '/sign_up_page', 'page': const SignupPage()},
    ];

    return otherRoutes.map((route) => GoRoute(
      path: route['path'] as String,
      pageBuilder: (context, state) => NoTransitionPage(
        child: route['page'] as Widget,
      ),
    )).toList();
  }
}
