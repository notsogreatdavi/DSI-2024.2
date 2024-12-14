import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../common/constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Lista para armazenar os grupos do Supabase
  List<Map<String, dynamic>> grupos = [];
  List<Map<String, dynamic>> filteredGrupos = [];

  @override
  void initState() {
    super.initState();
    _fetchGrupos(); // Busca os grupos no banco
    _searchController.addListener(_filterGroups);
  }

  // Função para buscar dados do Supabase
  Future<void> _fetchGrupos() async {
    final response =
        await Supabase.instance.client.from('grupo').select('*'); // Consulta

    setState(() {
      grupos = List<Map<String, dynamic>>.from(response);
      filteredGrupos = grupos; // Inicializa a lista filtrada
    });
  }

  // Função para filtrar os grupos na busca
  void _filterGroups() {
    setState(() {
      filteredGrupos = grupos
          .where((grupo) => grupo["name"]
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
        title: const Text(
          "Grupos de Estudo",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Buscar por grupo",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          Expanded(
            child: grupos.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredGrupos.length,
                    itemBuilder: (context, index) {
                      final grupo = filteredGrupos[index];
                      return CardModelo(
                        titulo: grupo["name"],
                        descricao: grupo["descricao"] ?? "Sem descrição",
                        participantes: 0, // Substitua conforme necessário
                        imagemUrl: grupo["fotoUrl"] ?? "assets/images/teste.jpg",
                        diasAtivos: 0, // Substitua conforme necessário
                      );
                    },
                  ),
          ),
        ],
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

  const CardModelo({
    required this.titulo,
    required this.descricao,
    required this.participantes,
    required this.imagemUrl,
    required this.diasAtivos,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: imagemUrl.startsWith('http')
              ? NetworkImage(imagemUrl)
              : AssetImage(imagemUrl) as ImageProvider,
        ),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(descricao),
        trailing: Text("$diasAtivos dias ativos"),
      ),
    );
  }
}
