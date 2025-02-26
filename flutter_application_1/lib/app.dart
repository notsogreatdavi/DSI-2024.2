import 'package:flutter/material.dart';
import 'src/features/splash/splash_screen.dart';
import 'src/features/onboarding/onboarding_screen.dart';
import 'src/features/ranking/ranking_screen.dart';
import 'src/features/login/login_screen.dart';
import 'src/features/login/forgot_password.dart';
import 'src/features/cadastro/cadastro_screen.dart';
import 'src/features/home/home_screen.dart';
import 'src/features/activities/activities_screen.dart';
import 'src/features/activities/create_activity.dart';
import 'src/features/registers/update_group.dart';
import 'src/features/pomodoro/pomodoro_screen.dart';
import 'src/features/activities/update-delete_activity.dart';
import 'src/features/map/map_screen.dart';
import 'src/features/profile/profile_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/activities') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ActivitiesScreen(grupo: args['grupo']),
          );
        } else if (settings.name == '/ranking') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => RankingScreen(grupo: args['grupo']),
          );
        } else if (settings.name == '/update_group') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => UpdateGroupScreen(grupo: args['grupo']),
          );
        } else if (settings.name == '/create_activity') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => CreateActivityScreen(grupo: args['grupo']),
          );
        } else if (settings.name == '/update-delete_activity') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) =>
                UpdateDeleteActivityScreen(atividade: args['atividade']),
          );
        } else if (settings.name == '/pomodoro') {
          // ✅ Pegando os argumentos corretamente
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => PomodoroScreen(
              grupo: args['grupo'],
              usuarioId: args['usuarioId'],
              grupoId: args['grupoId'],
            ),
          );
        }
        return null;
      },
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => LoginPage(),
        '/cadastro': (context) => CadastroPage(),
        '/home': (context) => const HomeScreen(),
        '/map': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return MapScreen(grupo: args['grupo']);
        },
        '/profile': (context) => const ProfileScreen(),
        '/forgot_password': (context) => const ForgotPasswordPage(),
      },
    );
  }
}
