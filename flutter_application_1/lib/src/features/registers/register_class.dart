import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterClassScreen extends StatefulWidget {
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
            'fotoUrl': 'assets/images/teste.jpg', // Imagem padrão
          })
          .select()
          .single();

      // Se o grupo for registrado com sucesso, retorna os dados para a tela anterior
      if (response != null) {
        if (mounted) {
          _showMessage('Grupo cadastrado com sucesso! 🎉');
          Navigator.pop(context, {
            'nomeGroup': nome,
            'descricaoGroup': descricao,
            'areaGroup': area,
            'atividades': atividades.isNotEmpty ? atividades.split(',') : [],
            'fotoUrl': 'assets/images/teste.jpg',
            'diasAtivos': 0, // Pode ser alterado conforme a lógica do seu app
          });
        }
      } else {
        if (mounted) {
          _showMessage('Erro ao cadastrar o grupo.');
        }
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
        title: Text('Cadastro de Grupo'),
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
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Campo para a descrição do grupo
            TextField(
              controller: _descricaoController,
              decoration: InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),

            // Campo para a área do grupo
            TextField(
              controller: _areaController,
              decoration: InputDecoration(
                labelText: 'Área',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Campo para as atividades do grupo
            TextField(
              controller: _atividadesController,
              decoration: InputDecoration(
                labelText: 'Atividades (separadas por vírgula)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),

            // Botão para registrar o grupo
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: _registrarGrupo,
              child: Text('Registrar Grupo'),
            ),
          ],
        ),
      ),
    );
  }
}
