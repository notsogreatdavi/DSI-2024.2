import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
//import '../../common/constants/app_colors.dart';

class DeleteClassScreen extends StatefulWidget {
  const DeleteClassScreen({super.key});

  @override
  State<DeleteClassScreen> createState() => _DeleteClassScreenState();
}

class _DeleteClassScreenState extends State<DeleteClassScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> grupos = []; // Lista para armazenar os grupos

  @override
  void initState() {
    super.initState();
    _loadGrupos(); // Carrega os grupos ao iniciar a tela
  }

  // Função para buscar os grupos no banco de dados
  Future<void> _loadGrupos() async {
    final response = await _supabase.from('grupo').select();

    setState(() {
      grupos = List<Map<String, dynamic>>.from(response);
    });
  }

  // Função para deletar o grupo selecionado
  Future<void> _deleteGrupo(int id) async {
    try {
      await _supabase.from('grupo').delete().match({'id': id});
      _showMessage('Grupo deletado com sucesso! 🎉');
      Navigator.pop(context,
          true); // Retorna à tela anterior informando que houve alteração
    } catch (e) {
      _showMessage('Erro ao deletar o grupo: $e');
    }
  }

  // Exibe uma mensagem ao usuário
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Deletar Grupo',
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
        centerTitle: true,
      ),
      body: grupos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: grupos.length,
              itemBuilder: (context, index) {
                final grupo = grupos[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(grupo['nomeGroup'] ?? 'Sem nome'),
                    subtitle: Text(grupo['descricaoGroup'] ?? 'Sem descrição'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await _confirmDelete(context);
                        if (confirm) {
                          _deleteGrupo(grupo['id']);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Diálogo de confirmação
  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar Exclusão'),
            content: const Text('Tem certeza que deseja excluir este grupo?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Excluir',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
