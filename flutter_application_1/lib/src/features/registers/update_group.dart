import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../common/constants/app_colors.dart';

class EditGroupScreen extends StatefulWidget {
  final Map<String, dynamic> grupo; // Recebe os dados do grupo selecionado

  EditGroupScreen({required this.grupo});

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
      // print('Atualizando o grupo no banco...');
      final response = await _supabase.from('grupo').update({
        'nomeGroup': nome,
        'descricaoGroup': descricao,
        'areaGroup': area,
        'atividades': atividades.isNotEmpty ? atividades.split(',') : [],
      }).match({'id': widget.grupo['id']}).select();

      // print('Resposta do banco: $response');

      if (response.isNotEmpty) {
        // print('Grupo atualizado com sucesso!');
        _showMessage('Grupo atualizado com sucesso! 🎉');
        Navigator.pop(context, response.first);
      } else {
        // print('Nenhum dado retornado pelo banco.');
        _showMessage('Erro ao atualizar o grupo: Nenhum dado retornado!');
      }
    } catch (e) {
      // print('Erro ao editar o grupo: $e');
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
