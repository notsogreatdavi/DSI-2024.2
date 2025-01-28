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
      onGenerateRoute: (settings) {
        if (settings.name == '/ranking') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) {
              return RankingScreen(grupo: args['grupo']);
            },
          );
        }
        // Adicione outras rotas dinâmicas aqui, se necessário
        return null;
      },
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => LoginPage(),
        '/cadastro': (context) => CadastroPage(),
        '/home': (context) => const HomeScreen(),
        // Remova a rota estática '/ranking'
      },
    );
  }
}