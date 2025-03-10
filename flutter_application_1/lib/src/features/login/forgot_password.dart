import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/src/common/constants/app_colors.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final SupabaseClient _supabase = Supabase.instance.client;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  bool _isResetPassword = false;
  String? _resetCode;
  String? _resetEmail;

  // Métodos de exibição de mensagens
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.azulEscuro,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Atenção',
            style: TextStyle(
              color: AppColors.azulEscuro,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.azulEscuro,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppColors.laranja,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          backgroundColor: AppColors.branco,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
    _checkUrlForResetCode(); // Verifica a URL ao iniciar
  }

  void _initDeepLinkListener() async {
    _appLinks = AppLinks();

    // Verificar deep link inicial
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _handleDeepLink(initialLink);
    }

    // Escutar deep links subsequentes
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.host == 'reset-password' || uri.path == '/reset-password') {
      final code = uri.queryParameters['code'];
      final email = uri.queryParameters['email']; // Recuperar o email da URL
      if (code != null && email != null) {
        setState(() {
          _isResetPassword = true;
          _resetCode = code;
          _resetEmail = email;
          _emailController.text = email; // Preencher o campo de email
        });
      }
    }
  }

  void _checkUrlForResetCode() async {
    if (kIsWeb) {
      final uri = Uri.base; // Obtém a URL atual
      final code = uri.queryParameters['code']; // Verifica se há um parâmetro 'code'
      final email = uri.queryParameters['email']; // Verifica se há um parâmetro 'email'
      if (code != null && email != null) {
        setState(() {
          _isResetPassword = true;
          _resetCode = code;
          _resetEmail = email;
          _emailController.text = email; // Preencher o campo de email
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage('Por favor, insira seu email.');
      return;
    }

    try {
      final uri = Uri.base;
      final port = uri.port;

      final redirectTo = kIsWeb
          ? 'http://localhost:$port/reset-password?code=$_resetCode&email=$email' // URL para web
          : 'meuapp://reset-password?code=$_resetCode&email=$email'; // URL para mobile

      print('URL de redirecionamento: $redirectTo'); // Log da URL

      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectTo,
      );

      _showMessage('Um link para redefinir sua senha foi enviado para o seu email.');
    } catch (error) {
      print('Erro ao solicitar redefinição de senha.'); 
      if (error.toString().contains('rate limit exceeded')) {
        _showErrorDialog('Aguarde alguns minutos antes de solicitar um novo email.');
      } else {
        _showMessage('Erro ao solicitar redefinição de senha. Tente novamente mais tarde.');
      }
    }
  }

Future<void> _updatePassword() async {
  final newPassword = _newPasswordController.text.trim();
  final confirmPassword = _confirmPasswordController.text.trim();

  if (newPassword.isEmpty || confirmPassword.isEmpty) {
    _showMessage('Por favor, preencha todos os campos.');
    return;
  }

  if (newPassword != confirmPassword) {
    _showMessage('As senhas não coincidem.');
    return;
  }

  try {
    if (_resetCode != null && _resetEmail != null) {
      print('Código de redefinição: $_resetCode'); // Log do código de redefinição
      print('Email de redefinição: $_resetEmail'); // Log do email

      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      _showMessage('Senha atualizada.');
      setState(() {
        _isResetPassword = false;
        _resetCode = null;
        _resetEmail = null;
      });
      if (kIsWeb) {
        // Redirecionar para a página inicial ou login
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        Navigator.pop(context);
      }
    } else {
      _showMessage('Código de redefinição ou email inválido.');
    }
  } catch (error) {
    print('Erro ao atualizar a senha.'); 
    _showMessage('Erro ao atualizar a senha. Tente novamente mais tarde.');
  }
}

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.branco,
      appBar: AppBar(
        title: Text(''),
        centerTitle: true,
        backgroundColor: AppColors.branco,
        automaticallyImplyLeading: false, 
        leading: IconButton(  
          icon: Icon(Icons.arrow_back),
          color: AppColors.azulEscuro,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  SizedBox(height: 50),
                  SizedBox(
                    height: 100,
                    child: Image.asset('assets/images/RatoBrancoFundoAzul.png'),
                  ),
                  Text(
                    _isResetPassword ? 'Redefinir Senha' : 'Esqueci a Senha',
                    style: TextStyle(
                      color: AppColors.azulEscuro,
                      fontSize: 28,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
              if (!_isResetPassword)
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'exemplo@dominio.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.cinzaClaro,
                  ),
                ),
              if (_isResetPassword) ...[
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Nova Senha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.cinzaClaro,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Nova Senha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.cinzaClaro,
                  ),
                ),
              ],
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isResetPassword ? _updatePassword : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.laranja,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  ),
                  child: Text(
                    _isResetPassword ? 'Atualizar Senha' : 'Redefinir Senha',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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