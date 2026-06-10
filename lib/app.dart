import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'state/providers.dart';
import 'ui/screens/onboarding_screen.dart';
import 'ui/screens/session_list_screen.dart';

class ShowCommApp extends ConsumerWidget {
  const ShowCommApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    return MaterialApp(
      title: 'ShowComm',
      theme: AppTheme.dark(),
      debugShowCheckedModeBanner: false,
      home: appState.isLoading
          ? const _SplashScreen()
          : appState.isOnboarded
              ? const SessionListScreen()
              : const OnboardingScreen(),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
