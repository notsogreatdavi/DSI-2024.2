import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../common/constants/app_colors.dart';
import '../../common/widgets/custom_navigation_bar.dart';
import '../../common/widgets/custom_bottom_navigation_bar.dart';

class ActivitiesScreen extends StatefulWidget {
  final Map<String, dynamic> grupo;

  const ActivitiesScreen({super.key, required this.grupo});

  @override
  _ActivitiesScreenState createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  int _selectedIndex = 2;
  late Map<String, dynamic> grupo;
  List<Map<String, dynamic>> atividades = [];
  bool isLoading = true;
  String errorMessage = '';
  Map<String, dynamic>? topUser;
  Map<String, dynamic>? loggedInUser;
  int? loggedInUserRank;

  @override
  void initState() {
    super.initState();
    grupo = widget.grupo;
    _loadAtividades();
    _loadTopUserAndLoggedInUser();
  }

  Future<void> _loadAtividades() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final List<dynamic> response = await Supabase.instance.client
          .from('atividade')
          .select()
          .eq('grupo_id', grupo['id']);

      setState(() {
        atividades = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao carregar atividades: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _loadTopUserAndLoggedInUser() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id ?? '';

      // Consulta única para buscar todos os usuários do grupo com os dados da tabela "usuarios"
      final List<dynamic> allUsersResponse = await supabase
          .from('grupo_usuarios')
          .select('usuario_id, usuarios!inner(fotoUrlPerfil, ativo, nome)')
          .eq('grupo_id', grupo['id']);

      // Converte para List<Map<String, dynamic>> e ordena localmente com base em usuarios.ativo de forma decrescente
      List<Map<String, dynamic>> allUsers =
          List<Map<String, dynamic>>.from(allUsersResponse);
      allUsers.sort((a, b) {
        final int aAtivo = a['usuarios']['ativo'] is int
            ? a['usuarios']['ativo']
            : int.tryParse(a['usuarios']['ativo'].toString()) ?? 0;
        final int bAtivo = b['usuarios']['ativo'] is int
            ? b['usuarios']['ativo']
            : int.tryParse(b['usuarios']['ativo'].toString()) ?? 0;
        return bAtivo.compareTo(aAtivo);
      });

      // Define o topUser como o primeiro elemento, se existir
      final Map<String, dynamic>? topUserFromQuery =
          allUsers.isNotEmpty ? allUsers.first : null;

      // Consulta para buscar o usuário logado (mesmo que já possa ser filtrado da lista acima)
      final Map<String, dynamic> loggedInUserResponse = await supabase
          .from('grupo_usuarios')
          .select('usuario_id, usuarios!inner(fotoUrlPerfil, ativo, nome)')
          .eq('grupo_id', grupo['id'])
          .eq('usuario_id', userId)
          .single();

      // Calcula a posição (rank) do usuário logado na lista ordenada
      final int userRank =
          allUsers.indexWhere((user) => user['usuario_id'] == userId) + 1;

      setState(() {
        topUser = topUserFromQuery;
        loggedInUser = loggedInUserResponse;
        loggedInUserRank = userRank;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao carregar dados do usuário: $e';
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushNamed(context, '/pomodoro');
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
        onMoreButtonPressed: () async {
          final updatedGroup = await Navigator.pushNamed(
            context,
            '/update_group',
            arguments: {'grupo': grupo},
          );

          if (updatedGroup != null) {
            setState(() {
              grupo = updatedGroup as Map<String, dynamic>;
              _loadAtividades();
              _loadTopUserAndLoggedInUser();
            });
          }
        },
        onProfileButtonPressed: () {
          // Botão para a tela de perfil
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
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  grupo['nomeGroup'] ?? 'Sem título',
                                  style: TextStyle(
                                    color: AppColors.pretoClaro,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.azulEscuro,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  grupo['areaGroup'] ?? 'Sem área',
                                  style: TextStyle(
                                    color: AppColors.branco,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            grupo['descricaoGroup'] ?? 'Sem descrição',
                            style: TextStyle(
                              color: AppColors.pretoClaro,
                              fontSize: 16,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (topUser != null && loggedInUser != null)
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
                                  Row(
                                    children: [
                                      Stack(
                                        children: [
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundImage: NetworkImage(
                                                topUser!['usuarios']
                                                    ['fotoUrlPerfil']),
                                          ),
                                          const Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: CircleAvatar(
                                              radius: 10,
                                              backgroundColor:
                                                  AppColors.pretoClaro,
                                              child: Text(
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
                                      Text(
                                        topUser!['usuarios']['nome'] ??
                                            'Usuário',
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
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundImage: NetworkImage(
                                                loggedInUser!['usuarios']
                                                    ['fotoUrlPerfil']),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: CircleAvatar(
                                              radius: 10,
                                              backgroundColor:
                                                  AppColors.pretoClaro,
                                              child: Text(
                                                '${loggedInUserRank}°',
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
                      'Atividades',
                      style: TextStyle(
                        fontFamily: 'Montserrat-semibold',
                        fontSize: 24,
                        color: AppColors.pretoClaro,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: atividades.isEmpty
                          ? const Center(
                              child: Text('Nenhuma atividade encontrada'))
                          : ListView.builder(
                              itemCount: atividades.length,
                              itemBuilder: (context, index) {
                                final atividade = atividades[index];
                                return Card(
                                  margin: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    leading: atividade['fotoUrlAtivi'] != null
                                        ? Image.network(
                                            atividade['fotoUrlAtivi'],
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                    title: Text(
                                      atividade['titulo_ativi'] ?? 'Sem título',
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat-semibold',
                                        fontSize: 18,
                                      ),
                                    ),
                                    subtitle: Text(
                                      atividade['descricao_ativi'] ??
                                          'Sem descrição',
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.azulEscuro,
        shape: const CircleBorder(),
        onPressed: () async {
          final novaAtividade = await Navigator.pushNamed(
            context,
            '/register_activity',
            arguments: {'grupoId': grupo['id']},
          );

          if (novaAtividade != null) {
            await _loadAtividades();
          }
        },
        child: const Icon(
          Icons.add,
          color: AppColors.branco,
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
