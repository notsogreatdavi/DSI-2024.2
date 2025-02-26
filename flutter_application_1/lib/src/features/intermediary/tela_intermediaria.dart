import 'package:flutter/material.dart';
import '../registers/register_class.dart';
import '../intermediary/entrar_grupo.dart'; // vamos criar essa tela a seguir
import '../../common/constants/app_colors.dart'; // Certifique-se de que AppColors está acessível

class ChooseGroupOptionScreen extends StatelessWidget {
  const ChooseGroupOptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Escolha uma opção',
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Imagem acima dos botões
              Image.asset(
                'assets/images/RatoBrancoFundoAzul.png',
                height: 150, // Ajuste o tamanho da imagem conforme necessário
                fit: BoxFit.contain, // Ajusta o conteúdo da imagem
              ),
              const SizedBox(height: 30), // Espaço entre a imagem e os botões

              // Botão para criar novo grupo
              SizedBox(
                width: 200,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.laranja,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(
                        color: AppColors.azulEscuro,
                        width: 2,
                      ),
                    ),
                  ),
                  onPressed: () async {
                    // Navega para a tela de criação
                    final novoGrupo = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegisterClassScreen()),
                    );

                    // Se voltou com algo não-nulo, significa que criou um grupo
                    // e precisamos recarregar a Home
                    Navigator.pop(context, novoGrupo != null);
                  },
                  child: const Text(
                    'Criar novo grupo',
                    style: TextStyle(
                      color: AppColors.branco,
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Botão para entrar em um grupo existente
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.laranja,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(
                        color: AppColors.azulEscuro,
                        width: 2,
                      ),
                    ),
                  ),
                  onPressed: () async {
                    final entrouEmGrupo = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const JoinExistingGroupScreen()),
                    );

                    // Se voltou com true, significa que entrou em algum grupo
                    Navigator.pop(context, entrouEmGrupo == true);
                  },
                  child: const Text(
                    'Entrar em um grupo existente',
                    style: TextStyle(
                      color: AppColors.branco,
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
