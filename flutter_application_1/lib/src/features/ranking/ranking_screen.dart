import 'package:flutter/material.dart';
import '../../common/constants/app_colors.dart';
import '../../common/widgets/custom_navigation_bar.dart';
import '../../common/widgets/custom_bottom_navigation_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../registers/update_group.dart';

class RankingScreen extends StatefulWidget {
  final Map<String, dynamic> grupo; // Recebe os dados do grupo selecionado

  const RankingScreen({super.key, required this.grupo});

  @override
  RankingScreenState createState() => RankingScreenState();
}

class RankingScreenState extends State<RankingScreen> {
  int _selectedIndex = 2;
  List<Map<String, dynamic>> grupos = [];
  List<Map<String, dynamic>> filteredGrupos = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGrupos();
    _searchController.addListener(_filterGroups);
  }

  Future<void> _loadGrupos() async {
    final response = await Supabase.instance.client
        .from('grupo')
        .select();

    if (response.isNotEmpty) {
      setState(() {
        grupos = List<Map<String, dynamic>>.from(response);
        filteredGrupos = grupos;
      });
    }
  }

  void _filterGroups() {
    setState(() {
      filteredGrupos = grupos
          .where((grupo) => grupo["nomeGroup"]
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterGroups);
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushNamed(context, '/pomodoro');
      } else if (index == 1) {
        Navigator.pushNamed(context, '/home');
      } else if (index == 2) {
        Navigator.pushNamed(context, '/ranking');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final grupo = widget.grupo; // Recebe o grupo passado pela HomeScreen

    return Scaffold(
      appBar: CustomNavigationBar(
        title: 'Ranking',
        onBackButtonPressed: () {
          Navigator.pushNamed(context, '/home');
        },
        onProfileButtonPressed: () {
          // Botao tela perfil
        },
        onMoreButtonPressed: () async {
          final isUpdated = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditGroupScreen(grupo: grupo),
            ),
          );

          if (isUpdated == true) {
            _loadGrupos();
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
                  style: TextStyle(
                    color: AppColors.pretoClaro,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Montserrat',
                  ),
                ),
                SizedBox(height: 8),
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
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: AssetImage('assets/images/gato_rosa.jpg'),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: 10,
                                  backgroundColor: AppColors.pretoClaro,
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
                          SizedBox(width: 10),
                          Text(
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
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: AssetImage('assets/images/teste.jpg'),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: 10,
                                  backgroundColor: AppColors.pretoClaro,
                                  child: Text(
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
                          SizedBox(width: 10),
                          Text(
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
                    leading: CircleAvatar(
                      backgroundImage: AssetImage('assets/images/gato_rosa.jpg'),
                      radius: 30, // Aumenta o tamanho da imagem
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ronaldo Ribeiro',
                          style: TextStyle(
                            fontFamily: 'Montserrat-semibold',
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
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
                    leading: CircleAvatar(
                      backgroundImage: AssetImage('assets/images/teste.jpg'),
                      radius: 30, // Aumenta o tamanho da imagem
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Guilherme Leonardo',
                          style: TextStyle(
                            fontFamily: 'Montserrat-semibold',
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
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
                    leading: CircleAvatar(
                      backgroundImage: AssetImage('assets/images/gato_real.jpg'),
                      radius: 30, // Aumenta o tamanho da imagem
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Davi Vieira',
                          style: TextStyle(
                            fontFamily: 'Montserrat-semibold',
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
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

class EditGroupScreen extends StatefulWidget {
  final Map<String, dynamic> grupo; // Recebe os dados do grupo selecionado

  const EditGroupScreen({super.key, required this.grupo});

  @override
  State<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  late TextEditingController _areaController;
  late TextEditingController _atividadesController;

  @override
  void initState() {
    super.initState();
    // Inicializa os controladores com os dados do grupo selecionado
    _nomeController =
        TextEditingController(text: widget.grupo['nomeGroup'] ?? '');
    _descricaoController =
        TextEditingController(text: widget.grupo['descricaoGroup'] ?? '');
    _areaController =
        TextEditingController(text: widget.grupo['areaGroup'] ?? '');
    _atividadesController = TextEditingController(
        text: (widget.grupo['atividades'] as List<dynamic>?)?.join(',') ?? '');
  }

  // Função para atualizar o grupo no banco de dados
  Future<void> _editarGrupo() async {
    final nome = _nomeController.text.trim();
    final descricao = _descricaoController.text.trim();
    final area = _areaController.text.trim();
    final atividades = _atividadesController.text.trim();

    if (nome.isEmpty || descricao.isEmpty || area.isEmpty) {
      _showMessage('Por favor, preencha todos os campos obrigatórios!');
      return;
    }

    try {
      final response = await _supabase.from('grupo').update({
        'nomeGroup': nome,
        'descricaoGroup': descricao,
        'areaGroup': area,
        'atividades': atividades.isNotEmpty ? atividades.split(',') : [],
      }).match({'id': widget.grupo['id']}).select();

      if (response.isNotEmpty) {
        _showMessage('Grupo atualizado com sucesso! 🎉');
        Navigator.pop(context, response.first);
      } else {
        _showMessage('Erro ao atualizar o grupo: Nenhum dado retornado!');
      }
    } catch (e) {
      _showMessage('Erro ao editar o grupo: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Grupo'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Nome do Grupo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descricaoController,
              decoration: InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _areaController,
              decoration: InputDecoration(
                labelText: 'Área',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _atividadesController,
              decoration: InputDecoration(
                labelText: 'Atividades (separadas por vírgula)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.laranja,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _editarGrupo,
              child: const Text(
                'Salvar Alterações',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}