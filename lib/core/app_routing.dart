import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mend_smile/core/route_names.dart';
import 'package:mend_smile/presentation/pages/doctor_pages/test_results_page.dart';
import 'package:mend_smile/presentation/pages/doctor_pages/view_patients_page.dart';
import 'package:mend_smile/presentation/pages/sign_up_page.dart';
import 'package:mend_smile/presentation/pages/sign_in_page.dart';
import 'package:mend_smile/presentation/pages/bottom_bar_pages/diet_page.dart';
import 'package:mend_smile/presentation/pages/bottom_bar_pages/patient_home_page.dart';
import 'package:mend_smile/presentation/pages/bottom_bar_pages/profile_page.dart';
import 'package:mend_smile/presentation/pages/bottom_bar_pages/qa_page.dart';
import 'package:mend_smile/presentation/pages/bottom_bar_pages/video_page.dart';
import '../presentation/pages/doctor_pages/quiz_results_page.dart';
import '../presentation/pages/login_page.dart';

class AppRouter {
  static List<StatefulShellBranch> buildNavigationBranches() {
    final navRoutes = [
      {'path': RouteNames.videoPage, 'page': const VideoPage()},
      {'path': RouteNames.dietPage, 'page': const DietPage()},
      {'path': RouteNames.patientHomePage, 'page': const PatientHomePage()},
      {'path': RouteNames.qaPage, 'page': const QaPage()},
      {'path': RouteNames.profilePage, 'page': const ProfilePage()},
    ];

    return navRoutes
        .map(
          (route) => StatefulShellBranch(
            routes: [
              GoRoute(
                path: route['path'] as String,
                pageBuilder: (context, state) =>
                    NoTransitionPage(child: route['page'] as Widget),
              ),
            ],
          ),
        )
        .toList();
  }

  static List<GoRoute> buildStandaloneRoutes() {
    return [
      GoRoute(
        path: RouteNames.viewPatientsPage,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: ViewPatientsPage()),
      ),
      GoRoute(
        path: RouteNames.signInPage,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SignInPage()),
      ),
      GoRoute(
        path: RouteNames.signUpPage,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SignupPage()),
      ),
      GoRoute(
        path: RouteNames.loginPage,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: LoginPage()),
      ),
      GoRoute(
        path: RouteNames.quizResultDetailPage,
        pageBuilder: (context, state) {
          return const NoTransitionPage(child: QuizResultsPage());
        },
      ),
    ];
  }
}
