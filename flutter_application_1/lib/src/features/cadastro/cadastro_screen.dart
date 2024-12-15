import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
        Navigator.pushReplacementNamed(context, '/tela_login');
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
      appBar: AppBar(
        title: Text('Cadastro'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _senhaController,
              decoration: InputDecoration(
                labelText: 'Senha',
                border: OutlineInputOutline(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _cadastrar,
              child: Text('Cadastrar'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

OutlineInputOutline() {
}

extension on AuthResponse {
  get error => null;
}
