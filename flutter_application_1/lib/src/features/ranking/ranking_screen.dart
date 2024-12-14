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
                Navigator.pop(context, '/home');
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
                Text(
                  'Grupo 2',
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
                                backgroundImage: AssetImage('assets/images/ronaldo_teste.jpg'),
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
                      backgroundImage: AssetImage('assets/images/ronaldo_teste.jpg'),
                      radius: 30, // Aumenta o tamanho da imagem
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ronaldo Agaraucho',
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
                          radius: 17,
                          backgroundColor: AppColors.azulEscuro,
                        ),
                        const Text(
                          '1°', // Número do ranking
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
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
                          'Guilherme Leopardo',
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
                          radius: 17,
                          backgroundColor: AppColors.azulEscuro,
                        ),
                        const Text(
                          '2°', // Número do ranking
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
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
                      backgroundImage: AssetImage('assets/images/RatoBrancoFundoAzul.png'),
                      radius: 30, // Aumenta o tamanho da imagem
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Davi Vivieira',
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
                          radius: 17,
                          backgroundColor: AppColors.azulEscuro,
                        ),
                        const Text(
                          '3°', // Número do ranking
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
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
    );
  }
}