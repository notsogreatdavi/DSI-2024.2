import 'package:flutter/material.dart';
import '../../common/constants/app_colors.dart';
import '../../common/widgets/custom_navigation_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../common/widgets/custom_bottom_navigation_bar.dart';

class RankingScreen extends StatefulWidget {
  final Map<String, dynamic> grupo; // Recebe os dados do grupo selecionado

  const RankingScreen({super.key, required this.grupo});

  @override
  RankingScreenState createState() => RankingScreenState();
}

class RankingScreenState extends State<RankingScreen> {
  int _selectedIndex = 2;
  late Map<String, dynamic> grupo;
  String? userProfileImageUrl; // Para a foto do usuário atual
  final supabase = Supabase.instance.client; // Instância do Supabase

  @override
  void initState() {
    super.initState();
    grupo = widget.grupo;
    _loadUserData(); // Carrega os dados do usuário atual
  }
  
  // Método para carregar os dados do usuário atual
  Future<void> _loadUserData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final userData = await supabase
            .from('usuarios')
            .select('fotoUrlPerfil')
            .eq('id', user.id)
            .maybeSingle();
        
        if (userData != null && mounted) {
          setState(() {
            userProfileImageUrl = userData['fotoUrlPerfil'];
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
    }
  }
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        // Obtendo o ID do usuário logado
        final usuarioId = supabase.auth.currentUser?.id;

        if (usuarioId != null) {
          Navigator.pushNamed(
            context,
            '/pomodoro',
            arguments: {
              'grupo': grupo,
              'usuarioId': usuarioId,
              'grupoId': grupo['id'], // Pegando o ID do grupo atual
            },
          );
        } else {
          // Tratar erro caso o usuário não esteja autenticado
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro: usuário não autenticado!')),
          );
        }
      } else if (index == 3) {
        Navigator.pushNamed(context, '/map', arguments: {'grupo': grupo});
      }
       else if (index == 1) { 
        Navigator.pushNamed(context, '/activities', arguments: {'grupo': grupo});
       }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNavigationBar(
        title: 'Ranking',
        profileImageUrl: userProfileImageUrl, // Usar a URL da imagem do usuário
        onBackButtonPressed: () {
          Navigator.pushNamed(context, '/home');
        },
        onProfileButtonPressed: () async {
          // Navega para a tela de perfil e aguarda o retorno
          final result = await Navigator.pushNamed(context, '/profile');
          
          // Se houve atualização, recarrega os dados do usuário
          if (result == true) {
            _loadUserData();
          }
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grupo['nomeGroup'] ?? 'Sem título',
                  style: const TextStyle(
                    color: AppColors.pretoClaro,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.azulEscuro,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Stack(
                            children: [
                              const CircleAvatar(
                                radius: 30,
                                backgroundImage: AssetImage('assets/images/gato_rosa.jpg'),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: 10,
                                  backgroundColor: AppColors.pretoClaro,
                                  child: const Text(
                                    '1°',
                                    style: TextStyle(
                                      color: AppColors.branco,
                                      fontSize: 12,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Ronaldo',
                            style: TextStyle(
                              color: AppColors.branco,
                              fontSize: 16,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Stack(
                            children: [
                              const CircleAvatar(
                                radius: 30,
                                backgroundImage: AssetImage('assets/images/teste.jpg'),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: 10,
                                  backgroundColor: AppColors.pretoClaro,
                                  child: const Text(
                                    '2°',
                                    style: TextStyle(
                                      color: AppColors.branco,
                                      fontSize: 12,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Você',
                            style: TextStyle(
                              color: AppColors.branco,
                              fontSize: 16,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Ranking',
            style: TextStyle(
              fontFamily: 'Montserrat-semibold',
              fontSize: 24,
              color: AppColors.pretoClaro,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Column(
              children: [
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundImage: AssetImage('assets/images/gato_rosa.jpg'),
                      radius: 30, // Aumenta o tamanho da imagem
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Ronaldo Ribeiro',
                          style: TextStyle(
                            fontFamily: 'Montserrat-semibold',
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '42 dias ativos',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                    trailing: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 17, // Aumenta o tamanho do círculo
                          backgroundColor: AppColors.azulEscuro,
                        ),
                        const Text(
                          '1°', // Número do ranking
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Montserrat-bold',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundImage: AssetImage('assets/images/teste.jpg'),
                      radius: 30, // Aumenta o tamanho da imagem
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Guilherme Leonardo',
                          style: TextStyle(
                            fontFamily: 'Montserrat-semibold',
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '25 dias ativos',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                    trailing: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 17, // Aumenta o tamanho do círculo
                          backgroundColor: AppColors.azulEscuro,
                        ),
                        const Text(
                          '2°', // Número do ranking
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Montserrat-bold',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundImage: AssetImage('assets/images/gato_real.jpg'),
                      radius: 30, // Aumenta o tamanho da imagem
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Davi Vieira',
                          style: TextStyle(
                            fontFamily: 'Montserrat-semibold',
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '24 dias ativos',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                    trailing: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 17, // Aumenta o tamanho do círculo
                          backgroundColor: AppColors.azulEscuro,
                        ),
                        const Text(
                          '3°', // Número do ranking
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Montserrat-bold',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}