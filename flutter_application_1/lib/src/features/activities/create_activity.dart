import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../common/widgets/custom_navigation_bar.dart';

class CreateActivityScreen extends StatefulWidget {
  final Map<String, dynamic> grupo;

  const CreateActivityScreen({super.key, required this.grupo});

  @override
  _CreateActivityScreenState createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  String titulo = '';
  String descricao = '';
  bool isLoading = false;
  String errorMessage = '';

  Future<void> _createActivity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await Supabase.instance.client.from('atividade').insert({
        'titulo_ativi': titulo,
        'descricao_ativi': descricao,
        'grupo_id': widget.grupo['id'],
      });

      if (response.error != null) {
        throw response.error!;
      }

      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao criar atividade: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNavigationBar(
        title: 'Criar Atividade',
        onBackButtonPressed: () {
          Navigator.pop(context);
        },
        onProfileButtonPressed: () {
          // Adicione a ação desejada aqui
        },
        onMoreButtonPressed: () {
          // Adicione a ação desejada aqui
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um título';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    titulo = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Descrição'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma descrição';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    descricao = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _createActivity,
                      child: Text('Criar Atividade'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}