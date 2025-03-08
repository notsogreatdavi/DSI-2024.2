import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../common/constants/app_colors.dart';
import 'dart:typed_data';

class UpdateGroupScreen extends StatefulWidget {
  final Map<String, dynamic> grupo;

  const UpdateGroupScreen({super.key, required this.grupo});

  @override
  State<UpdateGroupScreen> createState() => _UpdateGroupScreenState();
}

class _UpdateGroupScreenState extends State<UpdateGroupScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  late TextEditingController _areaController;

  Uint8List? _imagemSelecionada;
  String? _imagemUrl;

  @override
  void initState() {
    super.initState();
    _nomeController =
        TextEditingController(text: widget.grupo['nomeGroup'] ?? '');
    _descricaoController =
        TextEditingController(text: widget.grupo['descricaoGroup'] ?? '');
    _areaController =
        TextEditingController(text: widget.grupo['areaGroup'] ?? '');
    _imagemUrl = widget.grupo['fotoUrl'];
  }

  Future<void> _alterarFotoGrupo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagem = await picker.pickImage(source: ImageSource.gallery);

    if (imagem != null) {
      final bytes = await imagem.readAsBytes();
      setState(() {
        _imagemSelecionada = bytes;
      });

      final String? imagemUrl = await _fazerUploadImagem(_imagemSelecionada!);

      if (imagemUrl != null) {
        await _supabase.from('grupo').update({
          'fotoUrl': imagemUrl,
        }).match({'id': widget.grupo['id']});

        setState(() {
          _imagemUrl = imagemUrl;
        });
      }
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
      _showMessage('Erro ao enviar imagem.');
      return null;
    }
  }

  Future<void> _editarGrupo() async {
    final nome = _nomeController.text.trim();
    final descricao = _descricaoController.text.trim();
    final area = _areaController.text.trim();

    if (nome.isEmpty || descricao.isEmpty || area.isEmpty) {
      _showMessage('Por favor, preencha todos os campos obrigatórios!');
      return;
    }

    try {
      final response = await _supabase.from('grupo').update({
        'nomeGroup': nome,
        'descricaoGroup': descricao,
        'areaGroup': area,
      }).match({'id': widget.grupo['id']}).select();

      if (response.isNotEmpty) {
        _showMessage('Grupo atualizado.');
        Navigator.pop(context, response.first);
      } else {
        _showMessage('Erro ao atualizar o grupo: nenhum dado retornado.');
      }
    } catch (e) {
      _showMessage('Erro ao editar o grupo.');
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
            _imagemSelecionada != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      _imagemSelecionada!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _imagemUrl ?? '',
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _alterarFotoGrupo,
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
                'Alterar Foto do Grupo',
                style: TextStyle(
                  color: AppColors.branco,
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Nome do Grupo',
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
            ),
            const SizedBox(height: 16),
            TextField(
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
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _areaController,
              decoration: InputDecoration(
                labelText: 'Área',
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
            ),
            const SizedBox(height: 24),
            ElevatedButton(
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
              onPressed: _editarGrupo,
              child: const Text(
                'Salvar Alterações',
                style: TextStyle(
                  color: AppColors.branco,
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
