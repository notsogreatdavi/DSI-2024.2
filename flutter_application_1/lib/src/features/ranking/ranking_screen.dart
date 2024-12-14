import 'package:flutter/material.dart';
import '../../common/constants/app_colors.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.branco,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.azulEscuro,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: AppColors.branco,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 0, top: 8.0, bottom: 8.0),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.azulEscuro,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.person),
                color: AppColors.branco,
                onPressed: () {
                  // Botao TelaPerfil
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 0, right: 8.0, top: 8.0, bottom: 8.0),
            child: IconButton(
              icon: const Icon(Icons.more_vert, size: 30),
              color: AppColors.azulEscuro,
              onPressed: () {
                // Botao tela EditeUmGrupo
              },
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.branco,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(alignment: Alignment.centerLeft),
                Text(
                  'Grupo 2',
                  style: TextStyle(
                    color: AppColors.pretoClaro, 
                    fontSize: 20, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8), 
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Container(
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
                            backgroundImage: AssetImage('assets/images/RatoBrancoFundoAzul.png'),
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
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.azulEscuro,
              foregroundColor: AppColors.azulClaro1,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Botão clicado!')),
              );
            },
            child: const Text('Clique aqui'),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Número de itens no ranking
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.azulEscuro,
                      child: Text(
                        '${index + 1}', // Número do ranking
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text('Jogador ${index + 1}'),
                    subtitle: Text('Pontos: ${100 - index * 10}'), // Exemplo de pontos
                    trailing: const Icon(Icons.star, color: AppColors.azulEscuro),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}