import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import '../../common/constants/app_colors.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.azulEscuro,
        borderRadius: BorderRadius.circular(30),
      ),
      child: GNav(
        gap: 8,
        color: Colors.white, // Cor dos ícones não selecionados
        activeColor: Colors.white, // Cor dos ícones selecionados
        backgroundColor: AppColors.azulEscuro,
        tabBackgroundColor: Colors.white.withOpacity(0.2), // Fundo do ícone selecionado
        padding: const EdgeInsets.all(16),
        selectedIndex: currentIndex,
        onTabChange: onTap,
        tabs: const [
          GButton(
            icon: FeatherIcons.clock,
            text: 'Pomodoro',
          ),
          GButton(
            icon: FeatherIcons.home,
            text: 'Atividades',
          ),
          GButton(
            icon: FeatherIcons.award,
            text: 'Ranking',
          ),
        ],
      ),
    );
  }
}
