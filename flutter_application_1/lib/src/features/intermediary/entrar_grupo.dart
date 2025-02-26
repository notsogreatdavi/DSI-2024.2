import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JoinExistingGroupScreen extends StatefulWidget {
  const JoinExistingGroupScreen({Key? key}) : super(key: key);

  @override
  State<JoinExistingGroupScreen> createState() =>
      _JoinExistingGroupScreenState();
}

class _JoinExistingGroupScreenState extends State<JoinExistingGroupScreen> {
  List<Map<String, dynamic>> availableGroups = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    // 1. Busca os grupos em que o usuário já está inserido
    final userGroupsResponse = await Supabase.instance.client
        .from('grupo_usuarios')
        .select('grupo_id')
        .eq('usuario_id', user.id);

    // Converte a resposta em uma lista de IDs de grupo
    final List<int> userGroupIds = (userGroupsResponse as List)
        .map((item) => item['grupo_id'] as int)
        .toList();

    // 2. Busca todos os grupos da tabela 'grupo'
    final allGroupsResponse =
        await Supabase.instance.client.from('grupo').select();
    final List<Map<String, dynamic>> allGroups = (allGroupsResponse as List)
        .map((item) => item as Map<String, dynamic>)
        .toList();

    // 3. Filtra para mostrar apenas os grupos que o usuário NÃO está inserido
    final List<Map<String, dynamic>> groupsToJoin = allGroups.where((grupo) {
      return !userGroupIds.contains(grupo['id']);
    }).toList();

    setState(() {
      availableGroups = groupsToJoin;
      isLoading = false;
    });
  }

  Future<void> _joinGroup(int grupoId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // Insere o registro na tabela 'grupo_usuarios' com sequencia 0 e data atual
    await Supabase.instance.client.from('grupo_usuarios').insert({
      'grupo_id': grupoId,
      'usuario_id': user.id,
      'sequencia': 0,
      'ultimo_dia_ativo': DateTime.now().toIso8601String(),
    });

    // Retorna para a tela anterior indicando que houve alteração
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrar em um grupo existente'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : availableGroups.isEmpty
              ? const Center(
                  child: Text(
                    'Não há grupos disponíveis para entrar.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: availableGroups.length,
                  itemBuilder: (context, index) {
                    final grupo = availableGroups[index];
                    return ListTile(
                      title: Text(grupo['nomeGroup'] ?? 'Sem nome'),
                      subtitle:
                          Text(grupo['descricaoGroup'] ?? 'Sem descrição'),
                      onTap: () => _joinGroup(grupo['id']),
                    );
                  },
                ),
    );
  }
}
