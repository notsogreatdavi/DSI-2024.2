import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  int _selectedIndex = 1;
  late Map<String, dynamic> grupo;
  List<Map<String, dynamic>> atividades = [];
  bool isLoading = true;
  String errorMessage = '';
  String? userProfileImageUrl;
  Map<String, dynamic>? topUser;
  Map<String, dynamic>? loggedInUser;
  int? loggedInUserRank;
  String filtro = '';
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    grupo = widget.grupo;
    _loadAtividades();
    _loadTopUserAndLoggedInUser();
    _loadUserData();
  }

Future<void> _loadUserData() async {
  try {
    final user = supabase.auth.currentUser; // Use a variável de classe
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

  Future<void> _loadAtividades() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Faz join com a tabela usuarios para obter o campo fotoUrlPerfil
      final List<dynamic> response = await Supabase.instance.client
          .from('atividade')
          .select('*, usuarios!inner(fotoUrlPerfil)')
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

      // Consulta para buscar todos os usuários do grupo utilizando a coluna sequencia
      final List<dynamic> allUsersResponse = await supabase
          .from('grupo_usuarios')
          .select('usuario_id, sequencia, usuarios!inner(fotoUrlPerfil, nome)')
          .eq('grupo_id', grupo['id']);

      List<Map<String, dynamic>> allUsers =
          List<Map<String, dynamic>>.from(allUsersResponse);
      // Ordena os usuários de forma decrescente: quanto maior a sequencia, maior a posição
      allUsers.sort((a, b) {
        final int aSequencia = a['sequencia'] is int
            ? a['sequencia']
            : int.tryParse(a['sequencia'].toString()) ?? 0;
        final int bSequencia = b['sequencia'] is int
            ? b['sequencia']
            : int.tryParse(b['sequencia'].toString()) ?? 0;
        return bSequencia.compareTo(aSequencia);
      });

      final Map<String, dynamic>? topUserFromQuery =
          allUsers.isNotEmpty ? allUsers.first : null;

      // Consulta para buscar o usuário logado utilizando a coluna sequencia
      final Map<String, dynamic>? loggedInUserResponse = await supabase
          .from('grupo_usuarios')
          .select('usuario_id, sequencia, usuarios!inner(fotoUrlPerfil, nome)')
          .eq('grupo_id', grupo['id'])
          .eq('usuario_id', userId)
          .maybeSingle();

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
      // Obtendo o ID do usuário logado
      final supabase = Supabase.instance.client;
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
    } else if (index == 2) {
      Navigator.pushNamed(context, '/ranking', arguments: {'grupo': grupo});
    }
     else if (index == 3) { 
      Navigator.pushNamed(context, '/map', arguments: {'grupo': grupo});
     }
  });
}

  /// Retorna o cabeçalho para o grupo de atividades com base na data
  String _getHeader(String dateKey) {
    DateTime date = DateTime.parse(dateKey);
    DateTime today = DateTime.now();
    DateTime yesterday = today.subtract(const Duration(days: 1));

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return "Hoje";
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return "Ontem";
    } else {
      return DateFormat('EEEE, MMM, d', 'pt_BR').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtra as atividades pelo título, se houver filtro
    final filteredAtividades = atividades.where((atividade) {
      if (filtro.isEmpty) return true;
      return atividade['titulo_ativi']
          .toString()
          .toLowerCase()
          .contains(filtro.toLowerCase());
    }).toList();

    // Agrupa as atividades pela data (considerando apenas o ano, mês e dia)
    final Map<String, List<Map<String, dynamic>>> gruposAtividades = {};
    for (var atividade in filteredAtividades) {
      DateTime createdAt = DateTime.parse(atividade['created_at']);
      String dateKey = DateFormat('yyyy-MM-dd').format(createdAt);

      if (!gruposAtividades.containsKey(dateKey)) {
        gruposAtividades[dateKey] = [];
      }
      gruposAtividades[dateKey]!.add(atividade);
    }

    // Ordena as atividades dentro de cada grupo (do mais recente para o mais antigo)
    for (var grupo in gruposAtividades.values) {
      grupo.sort((a, b) {
        DateTime aDate = DateTime.parse(a['created_at']);
        DateTime bDate = DateTime.parse(b['created_at']);
        return bDate.compareTo(aDate);
      });
    }

    // Ordena as datas (grupos) de forma decrescente: o grupo mais recente primeiro
    final sortedDateKeys = gruposAtividades.keys.toList()
      ..sort((a, b) {
        return DateTime.parse(b).compareTo(DateTime.parse(a));
      });

    // Cria uma lista de widgets para exibir cada grupo (com cabeçalho e atividades)
    List<Widget> activityWidgets = [];
    for (String dateKey in sortedDateKeys) {
      activityWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Center(
            child: Text(
              _getHeader(dateKey),
              style: const TextStyle(
                fontFamily: 'Montserrat-semibold',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.pretoClaro,
              ),
            ),
          ),
        ),
      );
      for (var atividade in gruposAtividades[dateKey]!) {
        activityWidgets.add(
          GestureDetector(
            onTap: () async {
              final result = await Navigator.pushNamed(
                context,
                '/update-delete_activity',
                arguments: {'atividade': atividade},
              );
              if (result == true) {
                _loadAtividades(); // Recarrega as atividades após atualização ou exclusão
              }
            },
            child: Card(
              color: AppColors.azulEscuro,
              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: ListTile(
                // Exibe a imagem da atividade e, sobreposta, a foto do usuário (da tabela usuarios)
                leading: atividade['fotoUrlAtivi'] != null
                    ? Stack(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage:
                                NetworkImage(atividade['fotoUrlAtivi']),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundImage: atividade['usuarios'] != null &&
                                      atividade['usuarios']['fotoUrlPerfil'] != null
                                  ? NetworkImage(atividade['usuarios']
                                      ['fotoUrlPerfil'])
                                  : null,
                              backgroundColor: AppColors.branco,
                            ),
                          ),
                        ],
                      )
                    : null,
                title: Text(
                  atividade['titulo_ativi'] ?? 'Sem título',
                  style: const TextStyle(
                    fontFamily: 'Montserrat-semibold',
                    fontSize: 18,
                    color: AppColors.branco,
                  ),
                ),
                subtitle: Text(
                  atividade['descricao_ativi'] ?? 'Sem descrição',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    color: AppColors.branco,
                  ),
                ),
                trailing: Text(
                  DateFormat("HH'h'mm").format(
                    DateTime.parse(atividade['created_at']),
                  ),
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: AppColors.branco,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return Scaffold(
      appBar: CustomNavigationBar(
        title: '',
        profileImageUrl: userProfileImageUrl,
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
        onProfileButtonPressed: () async {
          // Navega para a tela de perfil e aguarda o retorno
          final result = await Navigator.pushNamed(context, '/profile');
          
          // Se houve atualização, recarrega os dados do usuário
          if (result == true) {
            _loadUserData();
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
                                        topUser!['usuarios']['nome'] ?? 'Usuário',
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
                                              backgroundColor: AppColors.pretoClaro,
                                              child: Text(
                                                '$loggedInUserRank°',
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
                          const SizedBox(height: 16),
                          TextField(
                            decoration: InputDecoration(
                              fillColor: AppColors.cinzaClaro,
                              filled: true,
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              prefixIcon: Icon(Icons.search),
                            ),
                            onChanged: (value) {
                              setState(() {
                                filtro = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: filteredAtividades.isEmpty
                          ? const Center(
                              child: Text('Nenhuma atividade encontrada'))
                          : ListView(
                              children: activityWidgets,
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
            '/create_activity',
            arguments: {'grupo': grupo},
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