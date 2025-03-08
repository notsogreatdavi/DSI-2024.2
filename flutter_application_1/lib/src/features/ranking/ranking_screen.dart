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
  String? userProfileImageUrl;
  final supabase = Supabase.instance.client;
  String? loggedInUserId;
  int loggedInUserRank = 0;

  @override
  void initState() {
    super.initState();
    grupo = widget.grupo;
    loggedInUserId = supabase.auth.currentUser?.id;
    _loadUserData();
    _loadRanking();
  }

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
      print('Erro ao carregar dados do usuário.');
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
          .select('usuario_id, sequencia, ultimo_dia_ativo, usuarios!inner(fotoUrlPerfil, nome)')
          .eq('grupo_id', grupo['id'])
          .order('sequencia', ascending: false);

      List<Map<String, dynamic>> allUsers =
          List<Map<String, dynamic>>.from(response);
      
      // Encontrar o índice do usuário logado
      if (loggedInUserId != null) {
        int index = allUsers.indexWhere((user) => user['usuario_id'] == loggedInUserId);
        if (index != -1) {
          loggedInUserRank = index + 1;
        }
      }

      setState(() {
        rankingList = allUsers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao carregar ranking.';
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
            const SnackBar(content: Text('Erro: usuário não autenticado.')),
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
          : errorMessage.isNotEmpty 
              ? Center(child: Text(errorMessage))
              : Column(
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
                          // Exibe o top 2 usuários
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
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  // Primeiro colocado
                                  _buildTopRanking(rankingList[0], '1°'),
                                  // Segundo colocado
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
                    // Lista de todos os usuários
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
                ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  // Widget para exibir usuários no topo da tela
  Widget _buildTopRanking(Map<String, dynamic> usuario, String posicao) {
    final bool isLoggedUser = usuario['usuario_id'] == loggedInUserId;
    return Row(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: usuario['usuarios']['fotoUrlPerfil'] != null
                  ? NetworkImage(usuario['usuarios']['fotoUrlPerfil'])
                  : const AssetImage('assets/images/teste.jpg') as ImageProvider,
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
          isLoggedUser ? 'Você' : (usuario['usuarios']['nome'] ?? 'Usuário'),
          style: const TextStyle(
            color: AppColors.branco,
            fontSize: 16,
            fontFamily: 'Montserrat',
          ),
        ),
      ],
    );
  }

  // Widget para o card de cada usuário na lista
  Widget _buildRankingCard(Map<String, dynamic> usuario, int posicao) {
    final bool isLoggedUser = usuario['usuario_id'] == loggedInUserId;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: usuario['usuarios']['fotoUrlPerfil'] != null
              ? NetworkImage(usuario['usuarios']['fotoUrlPerfil'])
              : const AssetImage('assets/images/teste.jpg') as ImageProvider,
          radius: 30,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isLoggedUser ? 'Você' : (usuario['usuarios']['nome'] ?? 'Usuário'),
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