import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/src/common/constants/app_colors.dart';

class CadastroPage extends StatefulWidget {
  @override
  _CadastroPageState createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> _cadastrar() async {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
      _showMessage('Por favor, preencha todos os campos!');
      return;
    }

    try {
      // Criar usuário no sistema de autenticação
      final response = await _supabase.auth.signUp(
        email: email,
        password: senha,
      );

      if (response.user != null) {
        // Sincronizar dados na tabela personalizada "usuarios"
        await _supabase.from('usuarios').insert({
          'id': response.user!.id, // ID do usuário autenticado
          'nome': nome,
          'email': email,
        });

        _showMessage('Cadastro realizado com sucesso! 🎉');
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        _showMessage('Erro no cadastro: ${response.error?.message}');
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
              // Logo do rato azul e texto "Cadastro" no topo
              Column(
                children: [
                  SizedBox(height: 50), // Espaço para empurrar a logo e o texto para cima
                  SizedBox(
                    height: 100, // Ajuste o tamanho conforme necessário
                    child: Image.asset('assets/images/RatoBrancoFundoAzul.png'), // Substitua pelo caminho da sua logo
                  ),
                  Text(
                    'Cadastro',
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

              // Campo de nome
              TextField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.cinzaClaro,
                ),
              ),
              SizedBox(height: 16),

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
                controller: _senhaController,
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
              SizedBox(height: 24),

              // Botão de cadastro
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _cadastrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.laranja,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20), // Aumenta a altura do botão
                  ),
                  child: Text(
                    'Cadastrar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Linha e texto "Já possui uma conta? Login"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Já possui uma conta? '),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(color: AppColors.laranja),
                    ),
                  ),
                ],
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