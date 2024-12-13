import 'package:flutter/material.dart';
import 'src/features/splash/splash_screen.dart';
import 'src/features/onboarding/onboarding_screen.dart';
import 'src/features/ranking/ranking_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/ranking': (context) => const RankingScreen(),
      }
    );
  }
}