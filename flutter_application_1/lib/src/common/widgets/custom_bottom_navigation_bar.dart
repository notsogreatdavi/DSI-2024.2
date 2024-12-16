import 'package:flutter/material.dart';
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
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.access_time, color: AppColors.branco),
          label: 'Relógio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: AppColors.branco),
          label: 'Casa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.emoji_events, color: AppColors.branco),
          label: 'Ranking',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: AppColors.branco,
      backgroundColor: AppColors.azulEscuro,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: onTap,
    );
  }
}