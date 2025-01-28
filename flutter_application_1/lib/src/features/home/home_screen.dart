import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../common/constants/app_colors.dart';
import '../registers/register_class.dart';
import '../registers/delete_group.dart';
import '../registers/update_group.dart';
import '../ranking/ranking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> grupos = []; // Lista para os dados do Supabase
  List<Map<String, dynamic>> filteredGrupos = [];
  Map<String, dynamic>? usuario; // Armazena os dados do usuário logado

  @override
  void initState() {
    super.initState();
    _loadUsuario(); // Chama função para carregar usuário
    _loadGrupos(); // Chama função para carregar grupos
    _searchController.addListener(_filterGroups);
  }

  // Busca as informações do usuário logado no Supabase
  Future<void> _loadUsuario() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final response = await Supabase.instance.client
          .from('usuarios')
          .select('nome, ativo') // Busca a coluna 'nome' e 'ativo'
          .eq('id', user.id)
          .single();

      setState(() {
        usuario = response;
      });
    }
  }

  // Função para buscar os grupos no Supabase
  Future<void> _loadGrupos() async {
    final response = await Supabase.instance.client
        .from('grupo') // Nome da tabela
        .select();

    if (response.isNotEmpty) {
      setState(() {
        grupos = List<Map<String, dynamic>>.from(response);
        filteredGrupos = grupos; // Inicializa a lista filtrada
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.branco,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/images/teste.jpg'),
              radius: 18,
            ),
            const SizedBox(width: 5),
            IconButton(
              onPressed: () async {
                final isUpdated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeleteClassScreen(),
                  ),
                );

                if (isUpdated == true) {
                  // Recarrega os grupos se houve alteração
                  _loadGrupos();
                }
              },
              icon: const Icon(Icons.more_horiz, color: Colors.black),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Bem-vindo",
            style: TextStyle(
              color: Colors.black,
              fontFamily: "Montserrat",
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          // Card com as informações do usuário logado
          if (usuario != null)
            Container(
              alignment: Alignment.center,
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.azulEscuro,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/teste.jpg'),
                    radius: 25,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "${usuario!['nome']} | ${usuario!['ativo'] ?? 0} dias ativos",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

          // Barra de pesquisa
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Buscar por título",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 5),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Lista de grupos
          Expanded(
            child: grupos.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredGrupos.length,
                    itemBuilder: (context, index) {
                      final grupo = filteredGrupos[index];
                      return GestureDetector(
                        onTap: () {
                          // Navega para a tela de ranking, passando os dados do grupo
                          Navigator.pushNamed(
                            context,
                            '/ranking',
                            arguments: {'grupo': grupo},
                          );
                        },
                        child: CardModelo(
                          titulo: grupo["nomeGroup"] ?? "Sem título",
                          descricao: grupo["descricaoGroup"] ?? "Sem descrição",
                          participantes: 0, // Substitua por valor real
                          imagemUrl: grupo["fotoUrl"] ??
                              "https://i.im.ge/2024/12/17/zATt3f.teste.jpeg",
                          diasAtivos: grupo["diasAtivos"] ?? 0,
                          tituloStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.yellow,
                          ),
                          descricaoStyle: const TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                          ),
                          participantesStyle: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
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
          // Aguarda a criação do grupo e recebe o grupo como retorno
          final novoGrupo = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegisterClassScreen()),
          );

          // Verifica se um novo grupo foi retornado
          if (novoGrupo != null) {
            // Recarrega todos os grupos do banco para refletir o novo grupo
            await _loadGrupos();
            setState(() {
              filteredGrupos = grupos; // Atualiza a lista exibida
            });
          }
        },
        child: const Icon(
          Icons.add,
          color: AppColors.branco,
        ),
      ),
    );
  }
}

// Modelo do Card reutilizável
class CardModelo extends StatelessWidget {
  final String titulo;
  final String descricao;
  final int participantes;
  final String imagemUrl;
  final int diasAtivos;
  final TextStyle? tituloStyle;
  final TextStyle? descricaoStyle;
  final TextStyle? participantesStyle;

  const CardModelo({
    required this.titulo,
    required this.descricao,
    required this.participantes,
    required this.imagemUrl,
    required this.diasAtivos,
    this.tituloStyle,
    this.descricaoStyle,
    this.participantesStyle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF001A66),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imagemUrl,
              height: 120,
              width: 120,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        titulo,
                        style: tituloStyle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_fire_department,
                              size: 16, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            "$diasAtivos d",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  descricao,
                  style: descricaoStyle,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "$participantes participantes",
                    style: participantesStyle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}