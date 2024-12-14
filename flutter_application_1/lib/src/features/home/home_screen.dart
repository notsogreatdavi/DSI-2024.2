import 'package:flutter/material.dart';
import '../../common/constants/app_colors.dart';
import '../registers/register_class.dart'; // Import da tela de cadastro

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Dados dos grupos com os novos atributos
  List<Map<String, dynamic>> grupos = [
    {
      "id": 1,
      "nome": "Foco Universitário Avançado (FUA)",
      "descricao":
          "Aqui sabemos que a preparação é intensa! Por isso, nos reunimos para trocar dicas, revisar conteúdos e turbinar sua preparação para o vestibular.",
      "foto": "assets/images/teste.jpg",
      "area": "Educação",
      "alunos": ["Ronaldo", "João", "Ana"],
      "atividades": ["Revisão ENEM", "Dicas de estudo"],
      "diasAtivos": 42,
    },
    {
      "id": 2,
      "nome": "Grupo de Estudos ENEM",
      "descricao":
          "Discussões e estratégias voltadas para a aprovação no ENEM. Participe para compartilhar conhecimento e aprender mais!",
      "foto": "assets/images/teste.jpg",
      "area": "Exatas",
      "alunos": ["Carlos", "Maria"],
      "atividades": ["Simulados", "Resolução de exercícios"],
      "diasAtivos": 30,
    },
    {
      "id": 3,
      "nome": "Clube de Matemática",
      "descricao":
          "A matemática é desafiadora, mas juntos conseguimos superar qualquer equação! Junte-se ao nosso clube.",
      "foto": "assets/images/teste.jpg",
      "area": null, // Campo opcional
      "alunos": ["Lucas", "Fernanda"],
      "atividades": ["Aulas de cálculo", "Geometria prática"],
      "diasAtivos": 15,
    },
  ];

  List<Map<String, dynamic>> filteredGrupos = [];

  @override
  void initState() {
    super.initState();
    filteredGrupos = grupos; // Inicializa com todos os grupos
    _searchController.addListener(_filterGroups);
  }

  void _filterGroups() {
    setState(() {
      filteredGrupos = grupos
          .where((grupo) => grupo["nome"]
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ImagePage()),
                );
              },
              child: const CircleAvatar(
                backgroundImage: NetworkImage(
                  'assets/images/teste.jpg',
                ),
                radius: 18,
              ),
            ),
            const SizedBox(width: 5),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MenuPage()),
                );
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
          const SizedBox(height: 10),
          Container(
            alignment: Alignment.center,
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.azulEscuro,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    'assets/images/teste.jpg',
                  ),
                  radius: 40,
                ),
                SizedBox(width: 10),
                Text(
                  "Ronaldo | 42 dias ativos",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
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
          Expanded(
            child: ListView.builder(
              itemCount: filteredGrupos.length,
              itemBuilder: (context, index) {
                final grupo = filteredGrupos[index];
                return CardModelo(
                  titulo: grupo["nome"],
                  descricao: grupo["descricao"],
                  participantes: grupo["alunos"].length,
                  imagemUrl: grupo["foto"],
                  diasAtivos: grupo["diasAtivos"],
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
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.azulEscuro,
        shape: const CircleBorder(), // Garante o formato circular
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegisterScreen()),
          );
        },
        child: const Icon(Icons.add),
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
            child: Image.asset(
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
                        color: AppColors.branco,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_fire_department,
                              size: 16, color: AppColors.laranja),
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

class ImagePage extends StatelessWidget {
  const ImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Página de Imagem"),
        backgroundColor: Colors.indigo,
      ),
      body: const Center(
        child: Text("Esta é a página de imagem."),
      ),
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Página do Menu"),
        backgroundColor: Colors.indigo,
      ),
      body: const Center(
        child: Text("Esta é a página do menu."),
      ),
    );
  }
}
