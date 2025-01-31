import 'package:flutter/material.dart';
import '../../common/constants/app_colors.dart';
import '../../common/widgets/custom_navigation_bar.dart';
import '../../common/widgets/custom_bottom_navigation_bar.dart';

class ActivitiesScreen extends StatefulWidget {
  final Map<String, dynamic> grupo; // Recebe os dados do grupo selecionado

  const ActivitiesScreen({super.key, required this.grupo});

  @override
  _ActivitiesScreenState createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  int _selectedIndex = 2;
  late Map<String, dynamic> grupo;

  @override
  void initState() {
    super.initState();
    grupo = widget.grupo;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushNamed(context, '/pomodoro');
      } else if (index == 1) {
        // não faz nada pq já está na tela de atividades
      } else if (index == 2) {
        Navigator.pushNamed(context, '/ranking', arguments: {'grupo': grupo});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNavigationBar(
        title: 'Atividades',
        onBackButtonPressed: () {
          Navigator.pushNamed(context, '/home');
        },
        onProfileButtonPressed: () {
          // Botao tela perfil
        },
        onMoreButtonPressed: () async {
          final updatedGroup = await Navigator.pushNamed(
            context,
            '/update_group',
            arguments: {'grupo': grupo},
          );

          if (updatedGroup != null) {
            setState(() {
              grupo = updatedGroup as Map<String, dynamic>;
            });
          }
        },
      ),
      backgroundColor: AppColors.branco,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bem-vindo às Atividades!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              'Grupo: ${grupo['nomeGroup'] ?? 'Sem título'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Descrição: ${grupo['descricaoGroup'] ?? 'Sem descrição'}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex, // Define o índice atual para a aba de atividades
        onTap: _onItemTapped,
      ),
    );
  }
}