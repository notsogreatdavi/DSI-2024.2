import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../common/constants/app_colors.dart';
import '../registers/delete_group.dart';
import '../intermediary/tela_intermediaria.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> grupos = [];
  List<Map<String, dynamic>> filteredGrupos = [];
  Map<String, dynamic>? usuario;

  @override
  void initState() {
    super.initState();
    _loadUsuario();
    _loadGrupos();
    _searchController.addListener(_filterGroups);
  }

  Future<void> _loadUsuario() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final response = await Supabase.instance.client
          .from('usuarios')
          .select('nome, ativo, fotoUrlPerfil')
          .eq('id', user.id)
          .single();

      setState(() {
        usuario = response;
      });
    }
  }

  Future<void> _loadGrupos() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // Busca todos os grupos
    final responseGrupos = await Supabase.instance.client
        .from('grupo_usuarios')
        .select('grupo_id')
        .eq('usuario_id', user.id);

    if (responseGrupos.isNotEmpty) {
      List<Map<String, dynamic>> gruposTemp = [];

      for (var grupoUsuario in responseGrupos) {
        final grupoId = grupoUsuario['grupo_id'];

        final responseGrupo = await Supabase.instance.client
            .from('grupo')
            .select()
            .eq('id', grupoId)
            .single();

        if (responseGrupo.isNotEmpty) {
          gruposTemp.add(responseGrupo);
        }
      }
      // Para cada grupo, buscar a sequência do usuário logado
      for (var grupo in gruposTemp) {
        final responseSequencia = await Supabase.instance.client
            .from('grupo_usuarios')
            .select('sequencia')
            .eq('grupo_id', grupo['id']) // Filtra pelo grupo
            .eq('usuario_id', user.id) // Filtra pelo usuário logado
            .maybeSingle(); // Retorna um único resultado ou null

        grupo['sequencia'] =
            responseSequencia != null ? responseSequencia['sequencia'] : 0;
      }

      setState(() {
        grupos = gruposTemp;
        filteredGrupos = grupos;
      });
    }
  }

  Future<int> _countParticipantes(int grupoId) async {
    final response = await Supabase.instance.client
        .from('grupo_usuarios')
        .select('usuario_id')
        .eq('grupo_id', grupoId);

    return response.length;
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
            GestureDetector(
              onTap: () async {
                // Navegar para a tela de perfil e aguardar o retorno
                final isUpdated =
                    await Navigator.pushNamed(context, '/profile');

                // Verifica se houve atualização ao voltar da tela de perfil
                if (isUpdated == true) {
                  setState(() {
                    // Recarrega as informações do usuário após alteração
                    _loadUsuario();
                  });
                }
              },
              child: CircleAvatar(
                backgroundImage:
                    usuario != null && usuario!['fotoUrlPerfil'] != null
                        ? NetworkImage(usuario!['fotoUrlPerfil'])
                        : const AssetImage('assets/images/teste.jpg')
                            as ImageProvider,
                radius: 18,
              ),
            ),
            const SizedBox(width: 5),
            IconButton(
              onPressed: () async {
                final isUpdated = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeleteClassScreen()),
                );

                if (isUpdated == true) {
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
                mainAxisAlignment:
                    MainAxisAlignment.center, // Alinhamento centralizado
                children: [
                  CircleAvatar(
                    backgroundImage:
                        usuario != null && usuario!['fotoUrlPerfil'] != null
                            ? NetworkImage(usuario!['fotoUrlPerfil'])
                            : const AssetImage('assets/images/teste.jpg')
                                as ImageProvider,
                    radius: 25,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "${usuario!['nome']} | ${usuario!['ativo'] ?? 0} dias ativos",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
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
          Expanded(
            child: grupos.isEmpty
                ? const Center(
                    child: Text(
                      "Nenhum grupo encontrado",
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredGrupos.length,
                    itemBuilder: (context, index) {
                      final grupo = filteredGrupos[index];
                      return FutureBuilder<int>(
                        future: _countParticipantes(grupo['id']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final participantes = snapshot.data ?? 0;
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/activities',
                                arguments: {'grupo': grupo},
                              );
                            },
                            child: CardModelo(
                              titulo: grupo["nomeGroup"] ?? "Sem título",
                              descricao:
                                  grupo["descricaoGroup"] ?? "Sem descrição",
                              participantes: participantes,
                              imagemUrl: grupo["fotoUrl"] ??
                                  "https://i.im.ge/2024/12/17/zATt3f.teste.jpeg",
                              diasAtivos: grupo["sequencia"] ?? 0,
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
          // Vai para a tela que pergunta o que o usuário quer fazer
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ChooseGroupOptionScreen()),
          );

          // Se a tela de opção retornou true, significa que algo foi criado ou alterado
          if (resultado == true) {
            await _loadGrupos();
            setState(() {
              filteredGrupos = grupos;
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
