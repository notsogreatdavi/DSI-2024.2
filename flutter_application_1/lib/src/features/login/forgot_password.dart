import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/src/common/constants/app_colors.dart';
import 'package:uni_links/uni_links.dart'; 
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart'; 
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
  StreamSubscription? _sub;

  bool _isResetPassword = false;

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
    _checkResetPasswordState();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _initDeepLinkListener() {
    if (kIsWeb) {
      // Verificar parâmetros da URL na web
      final uri = Uri.base;
      print('URI atual: $uri'); // Verifique a URI no console
      if (uri.queryParameters.containsKey('reset-password')) {
        _setResetPasswordState(true);
      }
    } else {
      // Usar uni_links para mobile
      _sub = uriLinkStream.listen((Uri? uri) {
        if (uri != null && uri.host == 'reset-password') {
          _setResetPasswordState(true);
        }
      }, onError: (err) {
        _showMessage('Erro ao processar o deep link: $err');
      });
    }
  }

  Future<void> _checkResetPasswordState() async {
    final prefs = await SharedPreferences.getInstance();
    final isResetPassword = prefs.getBool('isResetPassword') ?? false;
    if (isResetPassword) {
      setState(() {
        _isResetPassword = true;
      });
    }
  }

  Future<void> _setResetPasswordState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isResetPassword', value);
    setState(() {
      _isResetPassword = value;
    });
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage('Por favor, insira seu email.');
      return;
    }

    try {
      // Obter a porta dinâmica usada pelo Flutter
      final uri = Uri.base;
      final port = uri.port; // Porta atual (ex: 52050)

      final redirectTo = kIsWeb
          ? 'http://localhost:$port/reset-password?reset-password=true' // URL para web (localhost)
          : 'meuapp://reset-password'; // URL para mobile

      // Enviar email de redefinição de senha
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectTo,
      );

      _showMessage('Um link para redefinir sua senha foi enviado para o seu email.');
    } catch (error) {
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
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      _showMessage('Senha atualizada com sucesso.');
      await _setResetPasswordState(false); // Resetar o estado
      Navigator.pop(context);
    } catch (error) {
      _showMessage('Erro ao atualizar a senha. Tente novamente mais tarde.');
    }
  }

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: AppColors.branco,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.branco,
      appBar: AppBar(
        title: Text(''),
        centerTitle: true,
        backgroundColor: AppColors.branco,
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            color: AppColors.azulEscuro,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
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