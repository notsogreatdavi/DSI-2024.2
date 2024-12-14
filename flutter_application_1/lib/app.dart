import 'package:flutter/material.dart';
import 'src/features/splash/splash_screen.dart';
import 'src/features/onboarding/onboarding_screen.dart';
import 'src/features/ranking/ranking_screen.dart';
import 'src/features/login/login_screen.dart';
import 'src/features/cadastro/cadastro_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: LoginPage(),
      initialRoute: '/tela_cadastro',
      routes: {
        '/tela_login': (context) => LoginPage(),
        '/tela_ranking': (context) => RankingScreen(key: GlobalKey()),
        '/tela_cadastro': (context) => CadastroPage(),
        }
       );
      }
  }