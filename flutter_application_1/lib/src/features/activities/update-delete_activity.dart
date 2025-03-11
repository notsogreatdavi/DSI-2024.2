import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:image_picker/image_picker.dart'; // Para selecionar imagens
import 'dart:typed_data'; // Para trabalhar com os bytes da imagem
import '../../common/constants/app_colors.dart';

class UpdateDeleteActivityScreen extends StatefulWidget {
  final Map<String, dynamic> atividade;

  const UpdateDeleteActivityScreen({super.key, required this.atividade});

  @override
  _UpdateDeleteActivityScreenState createState() =>
      _UpdateDeleteActivityScreenState();
}

class _UpdateDeleteActivityScreenState
    extends State<UpdateDeleteActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final MaskedTextController _dataController =
      MaskedTextController(mask: '00/00/0000');
  final MaskedTextController _horaController =
      MaskedTextController(mask: '00:00');
  String errorMessage = '';

  // Variáveis para manipulação da imagem da atividade
  Uint8List? _imagemSelecionadaAtivi;
  String? _imagemUrlAtivi;

  @override
  void initState() {
    super.initState();
    _tituloController.text = widget.atividade['titulo_ativi'] ?? '';
    _descricaoController.text = widget.atividade['descricao_ativi'] ?? '';
    final DateTime dateTime = DateTime.parse(widget.atividade['created_at']);
    _dataController.text = DateFormat('dd/MM/yyyy').format(dateTime);
    _horaController.text = DateFormat('HH:mm').format(dateTime);
    _imagemUrlAtivi =
        widget.atividade['fotoUrlAtivi']; // Carrega a URL da foto da atividade
  }

Future<void> _updateActivity() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => errorMessage = '');

  try {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Usuário não está logado.');
    }

    // Data original da atividade
    final DateTime originalDate = DateTime.parse(widget.atividade['created_at']);
    final String originalDateStr = DateFormat('yyyy-MM-dd').format(originalDate);

    // Nova data da atividade
    final DateTime newDateTime = DateFormat('dd/MM/yyyy HH:mm').parse(
      '${_dataController.text} ${_horaController.text}',
    );
    final String newDateStr = DateFormat('yyyy-MM-dd').format(newDateTime);

    // Se a data não foi alterada, apenas atualize os detalhes básicos
    if (originalDateStr == newDateStr) {
      await Supabase.instance.client
          .from('atividade')
          .update({
            'titulo_ativi': _tituloController.text.trim(),
            'descricao_ativi': _descricaoController.text.trim(),
            'created_at': newDateTime.toIso8601String(),
          })
          .match({'id': widget.atividade['id']});
      
      Navigator.pop(context, true);
      return;
    }

    // Obter dados do usuário e do grupo
    final grupoUsuarioResponse = await Supabase.instance.client
        .from('grupo_usuarios')
        .select('sequencia, ultimo_dia_ativo')
        .eq('grupo_id', widget.atividade['grupo_id'])
        .eq('usuario_id', userId)
        .maybeSingle();

    if (grupoUsuarioResponse == null) {
      throw Exception('Usuário não encontrado no grupo.');
    }

    final Map<String, dynamic> grupoUsuario = grupoUsuarioResponse;
    final String? ultimoDiaAtivoString = grupoUsuario['ultimo_dia_ativo'];
    final DateTime? ultimoDiaAtivo = ultimoDiaAtivoString != null
        ? DateTime.parse(ultimoDiaAtivoString)
        : null;
    final int sequenciaAtual = grupoUsuario['sequencia'] ?? 0;

    // Busca o valor de 'ativo' da tabela 'usuarios'
    final userResponse = await Supabase.instance.client
        .from('usuarios')
        .select('ativo')
        .eq('id', userId)
        .single();
    final int ativoAtual = userResponse['ativo'];

    // 1. Verificar se há outras atividades no dia original
    final otherActivitiesOnOriginalDayResponse = await Supabase.instance.client
        .from('atividade')
        .select('id')
        .eq('grupo_id', widget.atividade['grupo_id'])
        .eq('id_aluno', userId)
        .gte('created_at', originalDateStr + ' 00:00:00')
        .lte('created_at', originalDateStr + ' 23:59:59')
        .neq('id', widget.atividade['id'])
        .limit(1)
        .maybeSingle();

    // 2. Verificar se já existe atividade no novo dia
    final activitiesOnNewDayResponse = await Supabase.instance.client
        .from('atividade')
        .select('id')
        .eq('grupo_id', widget.atividade['grupo_id'])
        .eq('id_aluno', userId)
        .gte('created_at', newDateStr + ' 00:00:00')
        .lte('created_at', newDateStr + ' 23:59:59')
        .limit(1)
        .maybeSingle();

    // 3. Atualizar os dados da atividade
    await Supabase.instance.client
        .from('atividade')
        .update({
          'titulo_ativi': _tituloController.text.trim(),
          'descricao_ativi': _descricaoController.text.trim(),
          'created_at': newDateTime.toIso8601String(),
        })
        .match({'id': widget.atividade['id']});

    // 4. Ajustar contadores conforme necessário
    int novoAtivo = ativoAtual;
    int novaSequencia = sequenciaAtual;

    // Se não houver outras atividades no dia original, diminuir contadores
    if (otherActivitiesOnOriginalDayResponse == null) {
      novoAtivo--;
      novaSequencia--;
    }

    // Se não houver atividades no novo dia, aumentar contadores
    if (activitiesOnNewDayResponse == null) {
      novoAtivo++;
      novaSequencia++;
    }

    // Atualizar contadores no banco de dados
    await Supabase.instance.client.from('usuarios').update({
      'ativo': novoAtivo,
    }).eq('id', userId);

    // 5. Verificar e atualizar último dia ativo
    String novoUltimoDiaAtivo = ultimoDiaAtivoString ?? '';

    // Se a nova data da atividade é o dia atual mais recente
    if (ultimoDiaAtivo == null || newDateTime.isAfter(ultimoDiaAtivo)) {
      novoUltimoDiaAtivo = newDateStr;
    } 
    // Se a atividade original estava no último dia ativo, precisamos encontrar o novo último dia
    else if (DateFormat('yyyy-MM-dd').format(ultimoDiaAtivo) == originalDateStr && 
             otherActivitiesOnOriginalDayResponse == null) {
      // Buscar a atividade mais recente para atualizar o último dia ativo
      final recentActivityResponse = await Supabase.instance.client
          .from('atividade')
          .select('created_at')
          .eq('grupo_id', widget.atividade['grupo_id'])
          .eq('id_aluno', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (recentActivityResponse != null) {
        final DateTime recentActivityDate =
            DateTime.parse(recentActivityResponse['created_at']);
        novoUltimoDiaAtivo = DateFormat('yyyy-MM-dd').format(recentActivityDate);
      }
    }

    // Atualizar a sequência e o último dia ativo
    await Supabase.instance.client
        .from('grupo_usuarios')
        .update({
          'sequencia': novaSequencia,
          'ultimo_dia_ativo': novoUltimoDiaAtivo,
        })
        .eq('grupo_id', widget.atividade['grupo_id'])
        .eq('usuario_id', userId);

    Navigator.pop(context, true);
  } catch (e) {
    setState(() => errorMessage = 'Erro ao atualizar atividade: ${e.toString()}');
    print('Erro detalhado: $e');
  }
}

  Future<void> _deleteActivity() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuário não está logado.');
      }

      final DateTime activityDate =
          DateTime.parse(widget.atividade['created_at']);

      // Verifica se há outras atividades no mesmo dia (ignorando a hora)
      final otherActivitiesResponse = await Supabase.instance.client
          .from('atividade')
          .select('id')
          .eq('grupo_id', widget.atividade['grupo_id'])
          .eq('id_aluno', userId)
          .gte('created_at',
              DateFormat('yyyy-MM-dd').format(activityDate) + ' 00:00:00')
          .lte('created_at',
              DateFormat('yyyy-MM-dd').format(activityDate) + ' 23:59:59')
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
          await Supabase.instance.client
              .from('atividade')
              .delete()
              .match({'id': widget.atividade['id']});
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
        throw Exception('Usuário não encontrado no grupo.');
      }

      final Map<String, dynamic> grupoUsuario = grupoUsuarioResponse;
      final DateTime lastActiveDate =
          DateTime.parse(grupoUsuario['ultimo_dia_ativo']);
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
        await _updateUserActivityData(
            userId, activityDate, lastActiveDate, ativoAtual, sequenciaAtual);
        await Supabase.instance.client
            .from('atividade')
            .delete()
            .match({'id': widget.atividade['id']});
        Navigator.pop(context, true); // Indica que a atividade foi deletada
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao deletar atividade.';
      });
    }
  }

  Future<void> _updateUserActivityData(String userId, DateTime activityDate,
      DateTime lastActiveDate, int ativoAtual, int sequenciaAtual) async {
    final int novoAtivo = ativoAtual - 1;
    final int novaSequencia = sequenciaAtual - 1;

    if (activityDate.isBefore(lastActiveDate)) {
      // A atividade é menor que o último dia ativo
      await Supabase.instance.client.from('usuarios').update({
        'ativo': novoAtivo,
      }).eq('id', userId);

      await Supabase.instance.client
          .from('grupo_usuarios')
          .update({
            'sequencia': novaSequencia,
          })
          .eq('grupo_id', widget.atividade['grupo_id'])
          .eq('usuario_id', userId);
    } else {
      // A atividade é igual ao último dia ativo
      await Supabase.instance.client.from('usuarios').update({
        'ativo': novoAtivo,
      }).eq('id', userId);

      await Supabase.instance.client
          .from('grupo_usuarios')
          .update({
            'sequencia': novaSequencia,
          })
          .eq('grupo_id', widget.atividade['grupo_id'])
          .eq('usuario_id', userId);

      // Atualiza o último dia ativo para a atividade mais recente
      final recentActivityResponse = await Supabase.instance.client
          .from('atividade')
          .select('created_at')
          .eq('grupo_id', widget.atividade['grupo_id'])
          .eq('id_aluno', userId)
          .lt('created_at',
              widget.atividade['created_at']) // Atividades anteriores
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (recentActivityResponse != null) {
        final DateTime recentActivityDate =
            DateTime.parse(recentActivityResponse['created_at']);
        await Supabase.instance.client
            .from('grupo_usuarios')
            .update({
              'ultimo_dia_ativo':
                  DateFormat('yyyy-MM-dd').format(recentActivityDate),
            })
            .eq('grupo_id', widget.atividade['grupo_id'])
            .eq('usuario_id', userId);
      }
    }
  }

  Future<bool> _confirmDeleteWithoutSequenceDecrease(
      BuildContext context, String message) async {
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

  Future<bool> _confirmDeleteWithSequenceDecrease(
      BuildContext context, String message, String additionalMessage) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar Exclusão'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message),
                const SizedBox(height: 8),
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

  Future<void> _alterarFotoAtividade() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagem = await picker.pickImage(source: ImageSource.gallery);

    if (imagem != null) {
      final bytes = await imagem.readAsBytes();
      setState(() {
        _imagemSelecionadaAtivi = bytes;
      });

      final String? imagemUrl =
          await _fazerUploadImagemAtividade(_imagemSelecionadaAtivi!);

      if (imagemUrl != null) {
        await Supabase.instance.client.from('atividade').update(
            {'fotoUrlAtivi': imagemUrl}).match({'id': widget.atividade['id']});

        setState(() {
          _imagemUrlAtivi = imagemUrl;
        });
      }
    }
  }

  Future<String?> _fazerUploadImagemAtividade(Uint8List imagemBytes) async {
    try {
      final nomeArquivo =
          'atividade_${DateTime.now().millisecondsSinceEpoch}.png';
      await Supabase.instance.client.storage.from('imagensdsi').uploadBinary(
            nomeArquivo,
            imagemBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      return Supabase.instance.client.storage
          .from('imagensdsi')
          .getPublicUrl(nomeArquivo);
    } catch (error) {
      // Aqui você pode adicionar feedback para o usuário, se desejar
      return null;
    }
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
              // Exibição da imagem da atividade
              _imagemSelecionadaAtivi != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        _imagemSelecionadaAtivi!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                  : _imagemUrlAtivi != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _imagemUrlAtivi!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const SizedBox(),
              const SizedBox(height: 16),
              // Botão para alterar a foto da atividade
              ElevatedButton(
                onPressed: _alterarFotoAtividade,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.laranja,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(
                      color: AppColors.azulEscuro,
                      width: 2,
                    ),
                  ),
                ),
                child: const Text(
                  'Alterar Foto da Atividade',
                  style: TextStyle(
                    color: AppColors.branco,
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Campos para título, descrição, data e hora
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
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
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
              const SizedBox(height: 24),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: TextStyle(color: AppColors.laranja),
                ),
              const SizedBox(height: 24),
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
                    child: const Text(
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
