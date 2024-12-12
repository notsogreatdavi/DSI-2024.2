import 'package:flutter/material.dart';
//import 'src/features/splash/splash_screen.dart';
import 'src/features/onboarding/onboarding_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: OnboardingScreen(),
    );
  }
}
