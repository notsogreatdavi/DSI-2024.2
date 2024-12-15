import 'package:flutter/material.dart';
import 'src/features/splash/splash_screen.dart';
import 'src/features/onboarding/onboarding_screen.dart';
import 'src/features/ranking/ranking_screen.dart';
import 'src/features/login/login_screen.dart';
import 'src/features/cadastro/cadastro_screen.dart';
import 'src/features/home/home_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => LoginPage(),
        '/cadastro': (context) => CadastroPage(),
        '/home': (context) => const HomeScreen(),
        '/ranking': (context) => const RankingScreen(),
      }
    );
  }
}