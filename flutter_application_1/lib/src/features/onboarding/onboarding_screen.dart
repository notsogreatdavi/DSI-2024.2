import 'package:flutter/material.dart';
import '../../common/constants/app_colors.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          alignment: Alignment.center,
          color: AppColors.branco,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/RatoBrancoFundoAzul.png', // Substitua pelo caminho correto da sua imagem
                width: 220, // Ajuste o tamanho conforme necessário
                height: 220,
              ),
              const SizedBox(height: 10),
              const Text(
                "Mind Rats",
                style: TextStyle(
                  fontSize: 48.0,
                  fontWeight: FontWeight.w500,
                  color: AppColors.azulEscuro,
                  fontFamily: 'Modak',
                ),
              ),
              const SizedBox(height: 25),
              const Divider(
                color: AppColors.azulEscuro,
                thickness: 1.5,
                indent: 30,
                endIndent: 30,
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: 170,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.laranja,
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: AppColors.branco,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 170,
                height: 40,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.laranja),
                  ),
                  child: const Text(
                    'Cadastre-se',
                    style: TextStyle(
                      color: AppColors.laranja,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
