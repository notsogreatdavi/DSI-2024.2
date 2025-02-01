import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../common/constants/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:io';
import 'dart:html' as html;

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
      final response = await _supabase.storage.from('imagensdsi').uploadBinary(
            nomeArquivo,
            imagemBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      if (response.isEmpty) return null;
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
      String? imagemUrl;
      if (_imagemSelecionada != null) {
        imagemUrl = await _fazerUploadImagem(_imagemSelecionada!);
      }

      await _supabase
          .from('grupo')
          .insert({
            'nomeGroup': nome,
            'descricaoGroup': descricao,
            'areaGroup': area,
            'atividades': atividades.isNotEmpty ? atividades.split(',') : [],
            'fotoUrl': imagemUrl,
          })
          .select()
          .single();

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
            Center(
              child: Column(
                children: [
                  if (_imagemSelecionada != null)
                    Image.memory(_imagemSelecionada!,
                        height: 100, fit: BoxFit.cover),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _selecionarImagem,
                    child: Text('Selecionar Imagem'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _registrarGrupo,
                child: Text('Registrar Grupo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
