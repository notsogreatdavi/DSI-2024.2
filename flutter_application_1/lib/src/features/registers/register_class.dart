import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastro de Turma"),
        backgroundColor: Colors.indigo,
      ),
      body: const Center(
        child: Text("Tela de cadastro de turma."),
      ),
    );
  }
}
