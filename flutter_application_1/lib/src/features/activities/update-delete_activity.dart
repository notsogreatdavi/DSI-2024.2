import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import '../../common/constants/app_colors.dart';

class UpdateDeleteActivityScreen extends StatefulWidget {
  final Map<String, dynamic> atividade;

  const UpdateDeleteActivityScreen({super.key, required this.atividade});

  @override
  _UpdateDeleteActivityScreenState createState() => _UpdateDeleteActivityScreenState();
}

class _UpdateDeleteActivityScreenState extends State<UpdateDeleteActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final MaskedTextController _dataController = MaskedTextController(mask: '00/00/0000');
  final MaskedTextController _horaController = MaskedTextController(mask: '00:00');
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tituloController.text = widget.atividade['titulo_ativi'] ?? '';
    _descricaoController.text = widget.atividade['descricao_ativi'] ?? '';
    final DateTime dateTime = DateTime.parse(widget.atividade['created_at']);
    _dataController.text = DateFormat('dd/MM/yyyy').format(dateTime);
    _horaController.text = DateFormat('HH:mm').format(dateTime);
  }

  Future<void> _updateActivity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      errorMessage = '';
    });

    try {
      final DateTime dateTime = DateFormat('dd/MM/yyyy HH:mm').parse(
        '${_dataController.text} ${_horaController.text}',
      );

      final response = await Supabase.instance.client.from('atividade').update({
        'titulo_ativi': _tituloController.text.trim(),
        'descricao_ativi': _descricaoController.text.trim(),
        'created_at': dateTime.toIso8601String(),
      }).match({'id': widget.atividade['id']}).select().single();

      if (response.isEmpty) {
        throw Exception('Erro ao atualizar atividade');
      }

      Navigator.pop(context, true); // Indica que a atividade foi atualizada
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao atualizar atividade: $e';
      });
    }
  }

  Future<void> _deleteActivity() async {
    try {
      await Supabase.instance.client.from('atividade').delete().match({'id': widget.atividade['id']});
      Navigator.pop(context, true); // Indica que a atividade foi deletada
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao deletar atividade: $e';
      });
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar Exclusão'),
            content: const Text('Tem certeza que deseja excluir esta atividade?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Excluir',
                  style: TextStyle(color: AppColors.laranja),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atualizar Atividade'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.laranja),
            onPressed: () async {
              final confirm = await _confirmDelete(context);
              if (confirm) {
                _deleteActivity();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(
                  labelText: 'Título',
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um título';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma descrição';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _dataController,
                decoration: InputDecoration(
                  labelText: 'Data (DD/MM/YYYY)',
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a data';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _horaController,
                decoration: InputDecoration(
                  labelText: 'Hora (HH:MM)',
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a hora';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: TextStyle(color: AppColors.laranja),
                ),
              SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: 210, 
                  height: 45, 
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.laranja,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(
                          color: AppColors.azulEscuro,
                          width: 2,
                        ),
                      ),
                    ),
                    onPressed: _updateActivity,
                    child: Text(
                      'Atualizar Atividade',
                      style: TextStyle(
                        color: AppColors.branco,
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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