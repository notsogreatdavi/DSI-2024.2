import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../common/constants/app_colors.dart';
import '../../common/widgets/custom_navigation_bar.dart';
import '../../common/widgets/custom_bottom_navigation_bar.dart';

class MapScreen extends StatefulWidget {
  final Map<String, dynamic> grupo;

  const MapScreen({super.key, required this.grupo});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int _selectedIndex = 3; // Índice do Mapa na bottom bar
  late Map<String, dynamic> grupo;

  @override
  void initState() {
    super.initState();
    grupo = widget.grupo;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        final supabase = Supabase.instance.client;
        final usuarioId = supabase.auth.currentUser?.id;

        if (usuarioId != null) {
          Navigator.pushNamed(
            context,
            '/pomodoro',
            arguments: {
              'usuarioId': usuarioId,
              'grupoId': grupo['id'],
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro: usuário não autenticado!')),
          );
        }
      } else if (index == 2) {
        Navigator.pushNamed(context, '/ranking', arguments: {'grupo': grupo});
      } else if (index == 3) {
        Navigator.pushNamed(context, '/map');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNavigationBar(
        title: 'Mapa',
        onBackButtonPressed: () {
          Navigator.pushNamed(context, '/home');
        },
        onMoreButtonPressed: () async {
          final updatedGroup = await Navigator.pushNamed(
            context,
            '/update_group',
            arguments: {'grupo': grupo},
          );
          if (updatedGroup != null) {
            setState(() {
              grupo = updatedGroup as Map<String, dynamic>;
            });
          }
        },
        onProfileButtonPressed: () {
          // Ação para o botão de perfil, se necessário
        },
      ),
      backgroundColor: AppColors.cinzaClaro,
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(-7.842992, -34.907557),
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(-23.55052, -46.633308),
                width: 40,
                height: 40,
                child: Icon(Icons.location_pin, size: 40, color: AppColors.laranja),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
