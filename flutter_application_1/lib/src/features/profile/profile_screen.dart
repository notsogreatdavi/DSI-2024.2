import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart'; // Importar para selecionar imagem
import '../../common/constants/app_colors.dart';
import 'dart:typed_data'; // Para lidar com a imagem em bytes

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  Map<String, dynamic>? usuario;
  bool isLoading = true;

  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _senhaController;

  Uint8List? _imagemSelecionada;
  String? _imagemUrl;

  @override
  void initState() {
    super.initState();
    _loadUsuario();
  }

  Future<void> _loadUsuario() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('Usuário não autenticado.');
        setState(() => isLoading = false);
        return;
      }

      final response = await _supabase
          .from('usuarios')
          .select('id, nome, email, fotoUrlPerfil')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        print('Nenhum dado do usuário encontrado.');
        _showMessage('Erro ao carregar dados do usuário.');
        setState(() => isLoading = false);
        return;
      }

      print('Usuário carregado: $response');

      setState(() {
        usuario = response;
        _nomeController = TextEditingController(text: usuario!['nome'] ?? '');
        _emailController = TextEditingController(text: usuario!['email'] ?? '');
        _senhaController = TextEditingController(text: '********');
        _imagemUrl = usuario!['fotoUrlPerfil']; // Carregar a URL da foto
        isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar usuário: $e');
      _showMessage('Erro ao carregar perfil.');
      setState(() => isLoading = false);
    }
  }

  Future<void> _alterarFotoPerfil() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagem = await picker.pickImage(source: ImageSource.gallery);

    if (imagem != null) {
      final bytes = await imagem.readAsBytes();
      setState(() {
        _imagemSelecionada = bytes;
      });

      // Fazer o upload da nova imagem
      final String? imagemUrl = await _fazerUploadImagem(_imagemSelecionada!);

      if (imagemUrl != null) {
        await _supabase.from('usuarios').update({
          'fotoUrlPerfil': imagemUrl,
        }).match({'id': usuario!['id']});

        // Atualizar a URL da foto no estado
        setState(() {
          _imagemUrl = imagemUrl;
        });
      }
    }
  }

  Future<String?> _fazerUploadImagem(Uint8List imagemBytes) async {
    try {
      final nomeArquivo = 'perfil_${DateTime.now().millisecondsSinceEpoch}.png';
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

  Future<void> _editarUsuario() async {
    if (usuario == null) {
      _showMessage('Erro: usuário não carregado.');
      return;
    }

    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    if (nome.isEmpty || email.isEmpty) {
      _showMessage('Nome e Email são obrigatórios!');
      return;
    }

    try {
      // Atualizar nome e email no banco de dados
      await _supabase.from('usuarios').update({
        'nome': nome,
        'email': email,
      }).match({'id': usuario!['id']});

      // Atualizar senha no Supabase Auth, se o usuário digitou uma nova senha
      if (senha.isNotEmpty && senha != '********') {
        await _supabase.auth.updateUser(
          UserAttributes(password: senha),
        );
      }

      _showMessage('Perfil atualizado com sucesso! 🎉');

      // Retorna 'true' para indicar que houve alteração
      Navigator.pop(context, true);
    } catch (e) {
      _showMessage('Erro ao editar perfil: $e');
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
        title: const Text('Editar Perfil'),
        centerTitle: true,
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    // Exibe a foto do perfil com o formato redondo
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: _imagemSelecionada != null
                            ? DecorationImage(
                                image: MemoryImage(_imagemSelecionada!),
                                fit: BoxFit.contain, // Reduz o zoom da imagem
                              )
                            : (_imagemUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(_imagemUrl!),
                                    fit: BoxFit
                                        .contain, // Altera o ajuste da imagem
                                  )
                                : null),
                      ),
                      child: (_imagemSelecionada == null && _imagemUrl == null)
                          ? Icon(Icons.person,
                              size: 50, color: Colors.grey[600])
                          : null,
                    ),

                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _alterarFotoPerfil, // Função de alterar foto
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.laranja,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side:
                              BorderSide(color: AppColors.azulEscuro, width: 2),
                        ),
                      ),
                      child: const Text(
                        'Alterar foto de perfil',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nomeController,
                      decoration: InputDecoration(
                        labelText: 'Nome',
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.azulEscuro, width: 2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.azulEscuro, width: 2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.azulEscuro, width: 2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.azulEscuro, width: 2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _senhaController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.azulEscuro, width: 2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.azulEscuro, width: 2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.laranja,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side:
                              BorderSide(color: AppColors.azulEscuro, width: 2),
                        ),
                      ),
                      onPressed: _editarUsuario,
                      child: const Text(
                        'Salvar Alterações',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
