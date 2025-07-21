import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'core/app_routing.dart';
import 'core/navigation_screen.dart';
import 'core/route_names.dart';
import 'core/session_manager.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final isLoggedIn = await SessionManager.isLoggedIn();
  final userType = await SessionManager.getUserType();
  final initialRoute = isLoggedIn ? (userType == 'admin'? RouteNames.approvalPage : RouteNames.patientHomePage) : RouteNames.loginPage;

  final router = GoRouter(
    initialLocation: initialRoute,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            NavigationScreen(navigationShell: navigationShell),
        branches: AppRouter.buildNavigationBranches(),
      ),
      ...AppRouter.buildStandaloneRoutes(),
    ],
  );

  runApp(MyApp(router: router));
}

class MyApp extends StatelessWidget {
  final GoRouter router;

  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(useMaterial3: true),
    );
  }
}
