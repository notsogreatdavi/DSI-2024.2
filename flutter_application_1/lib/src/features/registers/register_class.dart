import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _alunosController = TextEditingController();
  final TextEditingController _atividadesController = TextEditingController();
  final TextEditingController _diasAtivosController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Cria o novo grupo
      final novoGrupo = {
        "id": DateTime.now().millisecondsSinceEpoch, // ID único
        "nome": _nomeController.text,
        "descricao": _descricaoController.text,
        "area": _areaController.text,
        "foto": "assets/images/teste.jpg", // Placeholder para a imagem
        "alunos": _alunosController.text.split(','),
        "atividades": _atividadesController.text.split(','),
        "diasAtivos": int.tryParse(_diasAtivosController.text) ?? 0,
      };

      // Retorna o novo grupo para a HomeScreen
      Navigator.pop(context, novoGrupo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastro de Turma"),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Adicionar novo grupo",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: "Nome do grupo",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor, insira o nome do grupo.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: "Descrição",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor, insira uma descrição.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(
                  labelText: "Área",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor, insira a área do grupo.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _alunosController,
                decoration: const InputDecoration(
                  labelText: "Alunos (separados por vírgula)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _atividadesController,
                decoration: const InputDecoration(
                  labelText: "Atividades (separadas por vírgula)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _diasAtivosController,
                decoration: const InputDecoration(
                  labelText: "Dias ativos",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor, insira a quantidade de dias ativos.";
                  }
                  if (int.tryParse(value) == null) {
                    return "Insira um número válido.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text("Salvar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
