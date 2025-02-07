import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PomodoroScreen extends StatefulWidget {
  final String usuarioId;
  final int grupoId;

  const PomodoroScreen({super.key, required this.usuarioId, required this.grupoId});

  @override
  _PomodoroScreenState createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  final supabase = Supabase.instance.client;
  int _timeInSeconds = 25 * 60;
  bool _isRunning = false;
  Timer? _timer;
  late Future<List<Map<String, dynamic>>> _sessionsFuture;

  final TextEditingController _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sessionsFuture = _fetchSessions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeInSeconds > 0) {
        setState(() => _timeInSeconds--);
      } else {
        _stopTimer();
        _saveSession();
        _showCompletionDialog();
      }
    });
  }

  void _stopTimer() {
    setState(() => _isRunning = false);
    _timer?.cancel();
  }

  void _resetTimer() {
    _stopTimer();
    setState(() => _timeInSeconds = 25 * 60);
  }

  void _updateTime() {
    int newTime = int.tryParse(_timeController.text) ?? 25;
    setState(() => _timeInSeconds = newTime * 60);
  }

  Future<void> _saveSession() async {
    await supabase.from('pomodoro_session').insert({
      'usuario_id': widget.usuarioId,
      'grupo_id': widget.grupoId,
      'duracao': (_timeInSeconds ~/ 60).abs(), // Garante que a duração não seja negativa
      'concluido': true,
      'created_at': DateTime.now().toIso8601String(),
    });
    _reloadSessions();
  }

  Future<List<Map<String, dynamic>>> _fetchSessions() async {
    final response = await supabase
        .from('pomodoro_session')
        .select()
        .eq('usuario_id', widget.usuarioId)
        .eq('grupo_id', widget.grupoId)
        .order('created_at', ascending: false);
    return response;
  }

  Future<void> _deleteSession(int id) async {
    await supabase.from('pomodoro_session').delete().eq('id', id);
    _reloadSessions();
  }

  void _reloadSessions() {
    setState(() {
      _sessionsFuture = _fetchSessions();
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Pomodoro Concluído!"),
        content: const Text("Parabéns! Você concluiu uma sessão de Pomodoro."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetTimer(); // Reseta o tempo após o usuário fechar o alerta
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Pomodoro Timer',
          style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTimerDisplay(),
          const SizedBox(height: 20),
          _buildTimeInput(),
          const SizedBox(height: 20),
          _buildControls(),
          const SizedBox(height: 30),
          _buildSessionHistory(),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay() {
    return Center(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.red, width: 5),
        ),
        child: Center(
          child: Text(
            _formatTime(_timeInSeconds),
            style: GoogleFonts.lato(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          child: TextField(
            controller: _timeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Minutos',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _updateTime,
          child: const Text('Definir'),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton(Icons.play_arrow, 'Iniciar', _startTimer, Colors.green),
        const SizedBox(width: 20),
        _buildButton(Icons.pause, 'Pausar', _stopTimer, Colors.orange),
        const SizedBox(width: 20),
        _buildButton(Icons.refresh, 'Resetar', _resetTimer, Colors.red),
      ],
    );
  }

  Widget _buildButton(IconData icon, String label, VoidCallback onPressed, Color color) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      onPressed: onPressed,
    );
  }

  Widget _buildSessionHistory() {
    return Expanded(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma sessão encontrada'));
          }

          final sessions = snapshot.data!;
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return ListTile(
                title: Text('Duração: ${session['duracao']} min', style: const TextStyle(color: Colors.black)),
                subtitle: Text('Data: ${session['created_at']}', style: const TextStyle(color: Colors.grey)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteSession(session['id']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
