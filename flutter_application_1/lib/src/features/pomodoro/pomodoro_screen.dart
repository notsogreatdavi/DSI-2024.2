import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../common/constants/app_colors.dart';
import '../../common/widgets/custom_navigation_bar.dart';
import '../../common/widgets/custom_bottom_navigation_bar.dart';

class PomodoroScreen extends StatefulWidget {
  final Map<String, dynamic> grupo;
  final String usuarioId;
  final int grupoId;

  const PomodoroScreen({super.key, required this.usuarioId, required this.grupoId, required this.grupo});

  @override
  _PomodoroScreenState createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  final supabase = Supabase.instance.client;
  int _timeInSeconds = 25 * 60;
  int _originalTimeInSeconds = 25 * 60; // Adicionando uma variável para armazenar o tempo original
  bool _isRunning = false;
  Timer? _timer;
  late Future<List<Map<String, dynamic>>> _sessionsFuture;

  final TextEditingController _timeController = TextEditingController();
  int _selectedIndex = 0; // Índice da aba do Pomodoro

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
        _saveSession().then((_) {
          _showCompletionDialog();
        });
      }
    });
  }

  void _stopTimer() {
    setState(() => _isRunning = false);
    _timer?.cancel();
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _timeInSeconds = _originalTimeInSeconds;
    });
  }

  void _updateTime() {
    int newTime = int.tryParse(_timeController.text) ?? 25;
    setState(() {
      _timeInSeconds = newTime * 60;
      _originalTimeInSeconds = _timeInSeconds; // Atualizando o tempo original
    });
  }

  Future<void> _saveSession() async {
    await supabase.from('pomodoro_session').insert({
      'usuario_id': widget.usuarioId,
      'grupo_id': widget.grupoId,
      'duracao': (_originalTimeInSeconds ~/ 60).abs(), // Usando o tempo original
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
              _resetTimer();
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.pushNamed(context, '/activities', arguments: {'grupo': widget.grupo});
    } else if (index == 2) {
      Navigator.pushNamed(context, '/ranking', arguments: {'grupo': widget.grupo});
    } else if (index == 3) {
      Navigator.pushNamed(context, '/map', arguments: {'grupo': widget.grupo});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNavigationBar(
        title: 'Pomodoro',
        onBackButtonPressed: () => Navigator.pushNamed(context, '/home'),
        onMoreButtonPressed: () {},
        onProfileButtonPressed: () {},
      ),
      backgroundColor: AppColors.cinzaClaro,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
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
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
          border: Border.all(color: AppColors.laranja, width: 5),
        ),
        child: Center(
          child: Text(
            _formatTime(_timeInSeconds),
            style: GoogleFonts.lato(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.azulEscuro),
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
            decoration: InputDecoration(
              labelText: 'Minutos',
              border: OutlineInputBorder(),
              labelStyle: TextStyle(color: AppColors.azulEscuro),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.azulEscuro),
          onPressed: _updateTime,
          child: const Text('Definir', style: TextStyle(color: AppColors.cinzaClaro)),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton(Icons.play_arrow, 'Iniciar', _startTimer, AppColors.azulEscuro),
        const SizedBox(width: 20),
        _buildButton(Icons.pause, 'Pausar', _stopTimer, AppColors.laranja),
        const SizedBox(width: 20),
        _buildButton(Icons.refresh, 'Resetar', _resetTimer, AppColors.amarelo),
      ],
    );
  }

  Widget _buildButton(IconData icon, String label, VoidCallback onPressed, Color color) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(backgroundColor: color),
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

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Duração: ${snapshot.data![index]['duracao']} min'),
              );
            },
          );
        },
      ),
    );
  }
}
