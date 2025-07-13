import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart'; // Import provider
import 'core/theme/app_theme.dart';
import 'modules/auth/pages/login_page.dart';
import 'modules/formulario/pages/forms/userform_onboarding.dart';
import 'modules/home/pages/home_page.dart';
import 'modules/auth/provider/auth_provider.dart'; // Import your AuthProvider


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final AuthProvider authProvider = context.read<AuthProvider>();

    _router = GoRouter(
      refreshListenable: authProvider,
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/formulario-recepcao',
          builder: (context, state) => const OnboardingUserForm(
            targetCollectionName:'receptoras',
            formularioId: '492fb264-2f51-4122-a55f-8d8b01c222d7',
          ),
        ),
        GoRoute(
          path: '/formulario-doadoras',
          builder: (context, state) => const OnboardingUserForm(
            targetCollectionName:'doadoras',
            formularioId: '83949a81-60b8-472c-b39a-22b6b21878c0',
          ),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => LoginPage(),
        ),
      ],
      redirect: (BuildContext context, GoRouterState state) {
        final loggedIn = authProvider.user != null;

        // Use state.matchedLocation or state.fullPath
        // matchedLocation is the path of the current route (e.g., '/', '/login')
        // fullPath includes query parameters and fragments, which might be overkill for simple path checks.
        final String currentLocation = state.matchedLocation;

        final bool goingToLogin = currentLocation == '/login';
        final bool goingToFormulario = currentLocation == '/formulario-recepcao';

        // User is NOT logged in
        if (!loggedIn) {
          if (goingToFormulario) {
            return null; // Allow access to the form without login
          }
          return goingToLogin ? null : '/login'; // Redirect to login if not already there
        }

        // User IS logged in
        if (goingToLogin) {
          return '/'; // If logged in and trying to go to login, redirect to home
        }

        return null; // Otherwise, allow navigation
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      title: 'Sonhar+',
      theme: AppTheme.themeData,
    );
  }
}