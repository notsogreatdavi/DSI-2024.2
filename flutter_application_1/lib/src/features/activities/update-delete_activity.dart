import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import '../../common/constants/app_colors.dart';

class UpdateDeleteActivityScreen extends StatefulWidget {
  final Map<String, dynamic> atividade;

  const UpdateDeleteActivityScreen({super.key, required this.atividade});

  @override
  _UpdateDeleteActivityScreenState createState() => _UpdateDeleteActivityScreenState();
}

class _UpdateDeleteActivityScreenState extends State<UpdateDeleteActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final MaskedTextController _dataController = MaskedTextController(mask: '00/00/0000');
  final MaskedTextController _horaController = MaskedTextController(mask: '00:00');
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tituloController.text = widget.atividade['titulo_ativi'] ?? '';
    _descricaoController.text = widget.atividade['descricao_ativi'] ?? '';
    final DateTime dateTime = DateTime.parse(widget.atividade['created_at']);
    _dataController.text = DateFormat('dd/MM/yyyy').format(dateTime);
    _horaController.text = DateFormat('HH:mm').format(dateTime);
  }

  Future<void> _updateActivity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => errorMessage = '');

    try {
      final DateTime dateTime = DateFormat('dd/MM/yyyy HH:mm').parse(
        '${_dataController.text} ${_horaController.text}',
      );

      final response = await Supabase.instance.client.from('atividade').update({
        'titulo_ativi': _tituloController.text.trim(),
        'descricao_ativi': _descricaoController.text.trim(),
        'created_at': dateTime.toIso8601String(),
      }).match({'id': widget.atividade['id']}).select().single();

      if (response.isEmpty) throw Exception('Erro ao atualizar atividade');

      Navigator.pop(context, true); // Indica que a atividade foi atualizada
    } catch (e) {
      setState(() => errorMessage = 'Erro ao atualizar atividade: $e');
    }
  }
  
Future<void> _deleteActivity() async {
  try {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Usuário não está logado');
    }

    final DateTime activityDate = DateTime.parse(widget.atividade['created_at']);

    // Verifica se há outras atividades no mesmo dia (ignorando a hora)
    final otherActivitiesResponse = await Supabase.instance.client
        .from('atividade')
        .select('id')
        .eq('grupo_id', widget.atividade['grupo_id'])
        .eq('id_aluno', userId)
        .gte('created_at', DateFormat('yyyy-MM-dd').format(activityDate) + ' 00:00:00')
        .lte('created_at', DateFormat('yyyy-MM-dd').format(activityDate) + ' 23:59:59')
        .neq('id', widget.atividade['id'])
        .limit(1) // Limita a 1 resultado para verificar a existência
        .maybeSingle();

    if (otherActivitiesResponse != null) {
      // Há outras atividades no mesmo dia, apenas apaga a atividade
      final confirm = await _confirmDeleteWithoutSequenceDecrease(
        context,
        'Tem certeza que deseja excluir esta atividade?',
      );

      if (confirm) {
        await Supabase.instance.client.from('atividade').delete().match({'id': widget.atividade['id']});
        Navigator.pop(context, true); // Indica que a atividade foi deletada
      }
      return;
    }

    // Se não há outras atividades, verifica o último dia ativo do usuário no grupo
    final grupoUsuarioResponse = await Supabase.instance.client
        .from('grupo_usuarios')
        .select('ultimo_dia_ativo, sequencia')
        .eq('grupo_id', widget.atividade['grupo_id'])
        .eq('usuario_id', userId)
        .maybeSingle();

    if (grupoUsuarioResponse == null) {
      throw Exception('Usuário não encontrado no grupo');
    }

    final Map<String, dynamic> grupoUsuario = grupoUsuarioResponse;
    final DateTime lastActiveDate = DateTime.parse(grupoUsuario['ultimo_dia_ativo']);
    final int sequenciaAtual = grupoUsuario['sequencia'];

    // Busca o valor de 'ativo' da tabela 'usuarios'
    final userResponse = await Supabase.instance.client
        .from('usuarios')
        .select('ativo')
        .eq('id', userId)
        .single();

    final int ativoAtual = userResponse['ativo'];

    // Pop-up de confirmação com diminuição de sequência
    final confirm = await _confirmDeleteWithSequenceDecrease(
      context,
      'Tem certeza que deseja excluir esta atividade?',
      'Sua sequência diminuirá.',
    );

    if (confirm) {
      await _updateUserActivityData(userId, activityDate, lastActiveDate, ativoAtual, sequenciaAtual);
      await Supabase.instance.client.from('atividade').delete().match({'id': widget.atividade['id']});
      Navigator.pop(context, true); // Indica que a atividade foi deletada
    }
  } catch (e) {
    setState(() {
      errorMessage = 'Erro ao deletar atividade: $e';
    });
  }
}

Future<void> _updateUserActivityData(String userId, DateTime activityDate, DateTime lastActiveDate, int ativoAtual, int sequenciaAtual) async {
  final int novoAtivo = ativoAtual - 1;
  final int novaSequencia = sequenciaAtual - 1;

  if (activityDate.isBefore(lastActiveDate)) {
    // A atividade é menor que o último dia ativo
    await Supabase.instance.client.from('usuarios').update({
      'ativo': novoAtivo,
    }).eq('id', userId);

    await Supabase.instance.client.from('grupo_usuarios').update({
      'sequencia': novaSequencia,
    }).eq('grupo_id', widget.atividade['grupo_id']).eq('usuario_id', userId);
  } else {
    // A atividade é igual ao último dia ativo
    await Supabase.instance.client.from('usuarios').update({
      'ativo': novoAtivo,
    }).eq('id', userId);

    await Supabase.instance.client.from('grupo_usuarios').update({
      'sequencia': novaSequencia,
    }).eq('grupo_id', widget.atividade['grupo_id']).eq('usuario_id', userId);

    // Atualiza o último dia ativo para a atividade mais recente
    final recentActivityResponse = await Supabase.instance.client
        .from('atividade')
        .select('created_at')
        .eq('grupo_id', widget.atividade['grupo_id'])
        .eq('id_aluno', userId)
        .lt('created_at', widget.atividade['created_at']) // Atividades anteriores
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (recentActivityResponse != null) {
      final DateTime recentActivityDate = DateTime.parse(recentActivityResponse['created_at']);
      await Supabase.instance.client.from('grupo_usuarios').update({
        'ultimo_dia_ativo': DateFormat('yyyy-MM-dd').format(recentActivityDate),
      }).eq('grupo_id', widget.atividade['grupo_id']).eq('usuario_id', userId);
    }
  }
}

  Future<bool> _confirmDeleteWithoutSequenceDecrease(BuildContext context, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar Exclusão'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Excluir',
                  style: TextStyle(color: AppColors.laranja),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _confirmDeleteWithSequenceDecrease(BuildContext context, String message, String additionalMessage) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar Exclusão'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message),
                SizedBox(height: 8),
                Text(
                  additionalMessage,
                  style: TextStyle(color: AppColors.laranja),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Excluir',
                  style: TextStyle(color: AppColors.laranja),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atualizar Atividade'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.laranja),
            onPressed: _deleteActivity,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(
                  labelText: 'Título',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.azulEscuro,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.azulEscuro,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um título';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.azulEscuro,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.azulEscuro,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma descrição';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _dataController,
                decoration: InputDecoration(
                  labelText: 'Data (DD/MM/YYYY)',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.azulEscuro,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.azulEscuro,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a data';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _horaController,
                decoration: InputDecoration(
                  labelText: 'Hora (HH:MM)',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.azulEscuro,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.azulEscuro,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a hora';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: TextStyle(color: AppColors.laranja),
                ),
              SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: 210,
                  height: 45,
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
                    onPressed: _updateActivity,
                    child: Text(
                      'Atualizar Atividade',
                      style: TextStyle(
                        color: AppColors.branco,
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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