import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import '../../common/constants/app_colors.dart';

class CreateActivityScreen extends StatefulWidget {
  final Map<String, dynamic> grupo;

  const CreateActivityScreen({super.key, required this.grupo});

  @override
  _CreateActivityScreenState createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final MaskedTextController _dataController = MaskedTextController(mask: '00/00/0000');
  final MaskedTextController _horaController = MaskedTextController(mask: '00:00');
  String errorMessage = '';

  Future<void> _createActivity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      errorMessage = '';
    });

    try {
      final DateTime dateTime = DateFormat('dd/MM/yyyy HH:mm').parse(
        '${_dataController.text} ${_horaController.text}',
      );

      final DateTime now = DateTime.now();
      if (dateTime.isAfter(now)) {
        setState(() {
          errorMessage = 'A data da atividade não pode ser no futuro.';
        });
        return;
      }

      final userId = Supabase.instance.client.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('Usuário não está logado');
      }

      final fotoUrl = 'https://zvurnjqmcegutysaqrjs.supabase.co/storage/v1/object/public/imagensdsi//book-placeholder.png';

      // Verifica o último dia ativo do usuário
      final userResponse = await Supabase.instance.client
          .from('usuarios')
          .select('ativo, ultimo_dia_ativo')
          .eq('id', userId)
          .single();

      // Adiciona o método data() ao userResponse
      Map<String, dynamic> userResponseData() {
        return userResponse;
      }

      final Map<String, dynamic> user = userResponseData();
      final DateTime lastActiveDate = DateTime.parse(user['ultimo_dia_ativo']);

      // Verifica a sequência do usuário no grupo
      final grupoUsuarioResponse = await Supabase.instance.client
          .from('grupo_usuarios')
          .select('sequencia')
          .eq('grupo_id', widget.grupo['id'])
          .eq('usuario_id', userId)
          .single();

      final int sequenciaAtual = grupoUsuarioResponse['sequencia'];

      // Cria a atividade
      final activityResponse = await Supabase.instance.client.from('atividade').insert({
        'titulo_ativi': _tituloController.text.trim(),
        'descricao_ativi': _descricaoController.text.trim(),
        'grupo_id': widget.grupo['id'],
        'id_aluno': userId,
        'fotoUrlAtivi': fotoUrl,
        'created_at': dateTime.toIso8601String(),
      }).select().single();

      if (activityResponse.isEmpty) {
        throw Exception('Erro ao criar atividade');
      }

      // Atualiza os dados do usuário e do grupo se a data da nova atividade for diferente de ultimo_dia_ativo
      if (dateTime.isBefore(lastActiveDate)) {
        // A nova atividade é anterior ao último dia ativo
        final int novoAtivo = user['ativo'] + 1;
        final int novaSequencia = sequenciaAtual + 1;

        await Supabase.instance.client.from('usuarios').update({
          'ativo': novoAtivo,
        }).eq('id', userId);

        await Supabase.instance.client.from('grupo_usuarios').update({
          'sequencia': novaSequencia,
        }).eq('grupo_id', widget.grupo['id']).eq('usuario_id', userId);
      } else if (dateTime.isAfter(lastActiveDate)) {
        // A nova atividade é posterior ao último dia ativo
        final int novoAtivo = user['ativo'] + 1;
        final int novaSequencia = sequenciaAtual + 1;

        await Supabase.instance.client.from('usuarios').update({
          'ultimo_dia_ativo': DateFormat('yyyy-MM-dd').format(dateTime),
          'ativo': novoAtivo,
        }).eq('id', userId);

        await Supabase.instance.client.from('grupo_usuarios').update({
          'sequencia': novaSequencia,
        }).eq('grupo_id', widget.grupo['id']).eq('usuario_id', userId);
      }

      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao criar atividade: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Atividade'),
        centerTitle: true,
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
                  style: TextStyle(color: Colors.red),
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
                    onPressed: _createActivity,
                    child: Text(
                      'Criar Atividade',
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