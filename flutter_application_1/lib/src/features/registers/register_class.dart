import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../common/constants/app_colors.dart';
import 'dart:typed_data';

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

  Uint8List? _imagemSelecionada;
  String? _imagemUrl;

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
      final nomeArquivo = 'grupo_${DateTime.now().millisecondsSinceEpoch}.png';
      await _supabase.storage.from('imagensdsi').uploadBinary(
            nomeArquivo,
            imagemBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      return _supabase.storage.from('imagensdsi').getPublicUrl(nomeArquivo);
    } catch (error) {
      _showMessage('Erro ao enviar imagem: $error');
      return null;
    }
  }

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
      if (_imagemSelecionada != null) {
        _imagemUrl = await _fazerUploadImagem(_imagemSelecionada!);
      }

      final response = await _supabase
          .from('grupo')
          .insert({
            'nomeGroup': nome,
            'descricaoGroup': descricao,
            'areaGroup': area,
            'atividades': atividades.isNotEmpty ? atividades.split(',') : [],
            'fotoUrl': _imagemUrl,
          })
          .select()
          .single();

      final grupoId = response['id'];
      final userId = _supabase.auth.currentUser?.id;

      if (userId != null) {
        await _supabase.from('grupo_usuarios').insert({
          'grupo_id': grupoId,
          'usuario_id': userId,
        });
      }

      _showMessage('Grupo cadastrado com sucesso! 🎉');
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (error) {
      _showMessage('Erro inesperado: $error');
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
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Nome do Grupo',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.azulEscuro, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.azulEscuro, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descricaoController,
              decoration: InputDecoration(
                labelText: 'Descrição',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.azulEscuro, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.azulEscuro, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _areaController,
              decoration: InputDecoration(
                labelText: 'Área',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.azulEscuro, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.azulEscuro, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            SizedBox(height: 16),
            if (_imagemSelecionada != null)
              Image.memory(
                _imagemSelecionada!,
                height: 100,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 10),
            Center(
              child: SizedBox(
                width: 200,
                height: 30,
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
            SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: 200,
                height: 30,
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
                  onPressed: _registrarGrupo,
                  child: Text(
                    'Registrar Grupo',
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
          ],
        ),
      ),
    );
  }
}
