import 'package:flutter/material.dart';
import '../../common/constants/app_colors.dart';
import '../../common/widgets/custom_navigation_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../common/widgets/custom_bottom_navigation_bar.dart';

class RankingScreen extends StatefulWidget {
  final Map<String, dynamic> grupo;

  const RankingScreen({super.key, required this.grupo});

  @override
  RankingScreenState createState() => RankingScreenState();
}

class RankingScreenState extends State<RankingScreen> {
  int _selectedIndex = 2;
  late Map<String, dynamic> grupo;
  List<Map<String, dynamic>> rankingList = [];
  bool isLoading = true;
  String errorMessage = '';
  String? userProfileImageUrl; // Para a foto do usuário atual
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    grupo = widget.grupo;
    _loadUserData(); // Carrega os dados do usuário atual
    _loadRanking();
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

  Future<void> _loadRanking() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Busca todos os usuários do grupo, ordenando por sequencia (pontuação)
      final List<dynamic> response = await supabase
          .from('grupo_usuarios')
          .select('usuario_id, sequencia, usuarios!inner(fotoUrlPerfil, nome)')
          .eq('grupo_id', grupo['id'])
          .order('sequencia', ascending: false);

      List<Map<String, dynamic>> allUsers =
          List<Map<String, dynamic>>.from(response);

      setState(() {
        rankingList = allUsers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao carregar ranking: $e';
        isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        final usuarioId = supabase.auth.currentUser?.id;

        if (usuarioId != null) {
          Navigator.pushNamed(
            context,
            '/pomodoro',
            arguments: {
              'usuarioId': usuarioId,
              'grupoId': grupo['id'],
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro: usuário não autenticado!')),
          );
        }
      } else if (index == 3) {
        Navigator.pushNamed(context, '/map', arguments: {'grupo': grupo});
      } else if (index == 1) {
        Navigator.pushNamed(context, '/activities', arguments: {'grupo': grupo});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNavigationBar(
        title: 'Ranking',
        profileImageUrl: userProfileImageUrl,
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isEmpty
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 0),
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
                          if (rankingList.length >= 2)
                            Container(
                              width: double.infinity,
                              height: 100,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.azulEscuro,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildTopRanking(rankingList[0], '1°'),
                                  _buildTopRanking(rankingList[1], '2°'),
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
                      child: ListView.builder(
                        itemCount: rankingList.length,
                        itemBuilder: (context, index) {
                          final usuario = rankingList[index];
                          return _buildRankingCard(usuario, index + 1);
                        },
                      ),
                    ),
                  ],
                )
              : Center(child: Text(errorMessage)),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildTopRanking(Map<String, dynamic> usuario, String posicao) {
    return Row(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(
                  usuario['usuarios']['fotoUrlPerfil'] ??
                      'assets/images/teste.jpg'), // Use uma imagem padrão caso não tenha URL
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: AppColors.pretoClaro,
                child: Text(
                  posicao,
                  style: const TextStyle(
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
        Text(
          usuario['usuarios']['nome'] ?? 'Usuário',
          style: const TextStyle(
            color: AppColors.branco,
            fontSize: 16,
            fontFamily: 'Montserrat',
          ),
        ),
      ],
    );
  }

  Widget _buildRankingCard(Map<String, dynamic> usuario, int posicao) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
              usuario['usuarios']['fotoUrlPerfil'] ??
                  'assets/images/teste.jpg'), // Use uma imagem padrão caso não tenha URL
          radius: 30,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              usuario['usuarios']['nome'] ?? 'Usuário',
              style: const TextStyle(
                fontFamily: 'Montserrat-semibold',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${usuario['sequencia']} dias ativos',
              style: const TextStyle(
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
              radius: 17,
              backgroundColor: AppColors.azulEscuro,
            ),
            Text(
              '$posicao°',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Montserrat-bold',
              ),
            ),
          ],
        ),
      ),
    );
  }
}