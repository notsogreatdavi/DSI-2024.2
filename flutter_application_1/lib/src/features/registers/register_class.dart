import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../common/constants/app_colors.dart';

class RegisterClassScreen extends StatefulWidget {
  const RegisterClassScreen({super.key});

  @override
  RegisterClassScreenState createState() => RegisterClassScreenState();
}

class RegisterClassScreenState extends State<RegisterClassScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _atividadesController = TextEditingController();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Função para registrar o grupo
  Future<void> _registrarGrupo() async {
    final nome = _nomeController.text.trim();
    final descricao = _descricaoController.text.trim();
    final area = _areaController.text.trim();
    final atividades = _atividadesController.text.trim();

    if (nome.isEmpty || descricao.isEmpty || area.isEmpty) {
      _showMessage('Por favor, preencha todos os campos obrigatórios!');
      return;
    }

    try {
      // Insere o grupo no banco de dados
      final response = await _supabase
          .from('grupo')
          .insert({
            'nomeGroup': nome,
            'descricaoGroup': descricao,
            'areaGroup': area,
            'atividades': atividades.isNotEmpty ? atividades.split(',') : [],
          })
          .select()
          .single();

      final grupoId = response['id'];
      final userId = _supabase.auth.currentUser?.id;

      if (userId != null) {
        // Associa o usuário logado ao grupo recém-criado
        await _supabase.from('grupo_usuarios').insert({
          'grupo_id': grupoId,
          'usuario_id': userId,
        });
      }

      _showMessage('Grupo cadastrado com sucesso! 🎉');

      // Volta para a tela anterior (home) com um sinal para recarregar os dados
      if (mounted) {
        Navigator.pop(context, true); // Passa 'true' como flag para recarregar
      }
    } catch (error) {
      _showMessage('Erro inesperado: $error');
    }
  }

  // Função para exibir mensagens
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cadastro de Grupo',
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Campo para o nome do grupo
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Nome do Grupo',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: AppColors.azulEscuro, width: 2), // Borda azul
                  borderRadius: BorderRadius.circular(4),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: AppColors.azulEscuro, width: 2), // Borda azul
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Campo para a descrição do grupo
            TextField(
              controller: _descricaoController,
              decoration: InputDecoration(
                labelText: 'Descrição',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: AppColors.azulEscuro, width: 2), // Borda azul
                  borderRadius: BorderRadius.circular(4),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: AppColors.azulEscuro, width: 2), // Borda azul
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),

            // Campo para a área do grupo
            TextField(
              controller: _areaController,
              decoration: InputDecoration(
                labelText: 'Área',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: AppColors.azulEscuro, width: 2), // Borda azul
                  borderRadius: BorderRadius.circular(4),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: AppColors.azulEscuro, width: 2), // Borda azul
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Campo para as atividades do grupo
            TextField(
              controller: _atividadesController,
              decoration: InputDecoration(
                labelText: 'Atividades (separadas por vírgula)',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: AppColors.azulEscuro, width: 2), // Borda azul
                  borderRadius: BorderRadius.circular(4),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.blue, width: 2), // Borda azul
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            SizedBox(height: 24),

            // Botão para registrar o grupo
            Center(
              child: SizedBox(
                width: 180, // Define a largura fixa do botão
                height: 30, // Define a altura fixa do botão
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.laranja,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30), // Arredondando o botão
                      side: BorderSide(
                          color: AppColors.azulEscuro,
                          width: 2), // Borda do botão
                    ),
                  ),
                  onPressed: _registrarGrupo,
                  child: Text(
                    'Registrar Grupo',
                    style: TextStyle(
                        color: AppColors.branco,
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}