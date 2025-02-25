import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
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
  final MaskedTextController _dataController =
      MaskedTextController(mask: '00/00/0000');
  final MaskedTextController _horaController =
      MaskedTextController(mask: '00:00');
  String errorMessage = '';

  Uint8List? _imagemSelecionada;
  //String? _imagemUrl;

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> _selecionarImagem() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagem = await picker.pickImage(source: ImageSource.gallery);
    if (imagem != null) {
      final bytes = await imagem.readAsBytes();
      setState(() {
        _imagemSelecionada = bytes;
      });
    }
  }

  Future<String?> _fazerUploadImagem(Uint8List imagemBytes) async {
    try {
      final nomeArquivo =
          'atividade_${DateTime.now().millisecondsSinceEpoch}.png';
      await _supabase.storage.from('imagensdsi').uploadBinary(
            nomeArquivo,
            imagemBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      return _supabase.storage.from('imagensdsi').getPublicUrl(nomeArquivo);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar imagem: $error')),
      );
      return null;
    }
  }

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

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuário não está logado');
      }

      // Se uma imagem foi selecionada, faz o upload e obtém a URL
      String? uploadedFotoUrl;
      if (_imagemSelecionada != null) {
        uploadedFotoUrl = await _fazerUploadImagem(_imagemSelecionada!);
      }
      // Usa a URL enviada ou, se não houver, o placeholder padrão
      final String fotoUrl = uploadedFotoUrl ??
          'https://zvurnjqmcegutysaqrjs.supabase.co/storage/v1/object/public/imagensdsi//book-placeholder.png';

      // Verifica o último dia ativo do usuário no grupo
      final grupoUsuarioResponse = await _supabase
          .from('grupo_usuarios')
          .select('sequencia, ultimo_dia_ativo')
          .eq('grupo_id', widget.grupo['id'])
          .eq('usuario_id', userId)
          .maybeSingle();

      if (grupoUsuarioResponse == null) {
        throw Exception('Usuário não encontrado no grupo');
      }

      final Map<String, dynamic> grupoUsuario = grupoUsuarioResponse;
      final String? ultimoDiaAtivoString = grupoUsuario['ultimo_dia_ativo'];
      final DateTime? lastActiveDate = ultimoDiaAtivoString != null
          ? DateTime.parse(ultimoDiaAtivoString)
          : null;

      final int sequenciaAtual = grupoUsuario['sequencia'] ?? 0;

      // Busca o valor de 'ativo' da tabela 'usuarios'
      final userResponse = await _supabase
          .from('usuarios')
          .select('ativo')
          .eq('id', userId)
          .single();
      final int ativoAtual = userResponse['ativo'];

      // Verifica se já existe uma atividade no mesmo dia
      final existingActivityResponse = await _supabase
          .from('atividade')
          .select('id')
          .eq('grupo_id', widget.grupo['id'])
          .eq('id_aluno', userId)
          .gte('created_at',
              DateFormat('yyyy-MM-dd').format(dateTime) + ' 00:00:00')
          .lte('created_at',
              DateFormat('yyyy-MM-dd').format(dateTime) + ' 23:59:59')
          .limit(1)
          .maybeSingle();

      // Cria a atividade, incluindo a URL da imagem selecionada (ou o placeholder)
      final activityResponse = await _supabase
          .from('atividade')
          .insert({
            'titulo_ativi': _tituloController.text.trim(),
            'descricao_ativi': _descricaoController.text.trim(),
            'grupo_id': widget.grupo['id'],
            'id_aluno': userId,
            'fotoUrlAtivi': fotoUrl,
            'created_at': dateTime.toIso8601String(),
          })
          .select()
          .single();

      if (activityResponse.isEmpty) {
        throw Exception('Erro ao criar atividade');
      }

      // Verifica se a nova atividade está no mesmo dia do último dia ativo
      final bool isSameDayAsLastActive = lastActiveDate != null &&
          DateFormat('yyyy-MM-dd').format(dateTime) ==
              DateFormat('yyyy-MM-dd').format(lastActiveDate);

      // Atualiza os dados do usuário e do grupo conforme a data da nova atividade
      if (lastActiveDate == null || dateTime.isAfter(lastActiveDate)) {
        if (existingActivityResponse == null) {
          final int novoAtivo = ativoAtual + 1;
          final int novaSequencia = sequenciaAtual + 1;

          await _supabase.from('usuarios').update({
            'ativo': novoAtivo,
          }).eq('id', userId);

          await _supabase
              .from('grupo_usuarios')
              .update({
                'ultimo_dia_ativo': DateFormat('yyyy-MM-dd').format(dateTime),
                'sequencia': novaSequencia,
              })
              .eq('grupo_id', widget.grupo['id'])
              .eq('usuario_id', userId);
        }
      } else if (dateTime.isBefore(lastActiveDate)) {
        if (existingActivityResponse == null) {
          final int novoAtivo = ativoAtual + 1;
          final int novaSequencia = sequenciaAtual + 1;

          await _supabase.from('usuarios').update({
            'ativo': novoAtivo,
          }).eq('id', userId);

          await _supabase
              .from('grupo_usuarios')
              .update({
                'sequencia': novaSequencia,
              })
              .eq('grupo_id', widget.grupo['id'])
              .eq('usuario_id', userId);
        }
      } else if (isSameDayAsLastActive) {
        // Se a atividade for no mesmo dia, não é necessário atualizar os contadores
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
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 16),
              // Exibição da imagem selecionada (se houver)
              if (_imagemSelecionada != null)
                Image.memory(
                  _imagemSelecionada!,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 10),
              // Botão para selecionar a imagem
              Center(
                child: SizedBox(
                  width: 200,
                  height: 35,
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
                    onPressed: _selecionarImagem,
                    child: Text(
                      'Selecionar Imagem',
                      style: TextStyle(
                        color: AppColors.branco,
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
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
