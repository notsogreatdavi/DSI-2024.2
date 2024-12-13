import 'package:flutter/material.dart';
import '../../common/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              AppColors.azulEscuro,
              AppColors.azulEscuro,
            ],
          ),
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Ajusta o tamanho para centralizar os filhos
          children: [
            Image.asset(
              'assets/images/RatoBrancoFundoAzul.png', // Substitua pelo caminho correto da sua imagem
              width: 220, // Ajuste o tamanho conforme necessário
              height: 220,
            ),
            const SizedBox(height: 10), // Espaçamento entre a imagem e o texto
            const Text(
              "Mind Rats",
              style: TextStyle(
                fontSize: 48.0,
                fontWeight: FontWeight.w500,
                color: Color(0xFFF0F0F0),
                fontFamily: 'Modak',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
