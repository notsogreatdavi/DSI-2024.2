import 'package:flutter/material.dart';
import '../../common/constants/app_colors.dart';

class CustomNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBackButtonPressed;
  final String? profileImageUrl; // Nova propriedade para a URL da imagem
  final VoidCallback onProfileButtonPressed;
  final VoidCallback onMoreButtonPressed;

  const CustomNavigationBar({
    required this.title,
    required this.onBackButtonPressed,
    this.profileImageUrl, // Opcional para permitir usar o widget sem foto de perfil
    required this.onProfileButtonPressed,
    required this.onMoreButtonPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.branco,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.azulEscuro,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppColors.branco,
            onPressed: onBackButtonPressed,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 0, top: 8.0, bottom: 8.0),
          child: GestureDetector(
            onTap: onProfileButtonPressed,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.azulEscuro,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.azulEscuro,
                backgroundImage: profileImageUrl != null
                    ? NetworkImage(profileImageUrl!)
                    : null,
                child: profileImageUrl == null
                    ? const Icon(Icons.person, color: AppColors.branco)
                    : null,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 0, right: 8.0, top: 8.0, bottom: 8.0),
          child: IconButton(
            icon: const Icon(Icons.more_vert, size: 30),
            color: AppColors.azulEscuro,
            onPressed: onMoreButtonPressed,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}