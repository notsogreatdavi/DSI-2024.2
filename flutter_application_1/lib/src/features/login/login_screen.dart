import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/src/common/constants/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> _login() async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.session != null) {
        // Login bem-sucedido: redirecionar para a tela de ranking
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showMessage('Erro ao realizar login: ${response.error?.message}');
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
              Navigator.pushReplacementNamed(context, '/onboarding');
            },
          ),
        ]
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo do rato azul e texto "Login" no topo
              Column(
                children: [
                  SizedBox(height: 50), // Espaço para empurrar a logo e o texto para cima
                  SizedBox(
                    height: 100, // Ajuste o tamanho conforme necessário
                    child: Image.asset('assets/images/RatoBrancoFundoAzul.png'), // Substitua pelo caminho da sua logo
                  ),
                  Text(
                    'Login',
                    style: TextStyle(
                      color: AppColors.azulEscuro,
                      fontSize: 28, // Aumente o tamanho da fonte conforme necessário
                      fontFamily: 'Montserrat', // Defina a fonte Montserrat
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),

              // Campo de email
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
              SizedBox(height: 16),

              // Campo de senha
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.cinzaClaro,
                ),
                obscureText: true,
              ),
              SizedBox(height: 8),

              // Texto "Esqueceu a senha?" centralizado
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    // Ação para "Esqueceu a senha?"
                  },
                  child: Text(
                    'Esqueceu a senha?',
                    style: TextStyle(color: AppColors.laranja),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Botão de login
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.laranja,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20), // Aumenta a altura do botão
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Linha e texto "Não tem uma conta? Cadastre-se"
              Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Não tem uma conta?'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/cadastro');
                },
                child: Text(
                  'Cadastre-se',
                  style: TextStyle(color: AppColors.laranja),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on AuthResponse {
  get error => null;
}