import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
  String? userProfileImageUrl;
  List<Map<String, dynamic>> pontosInteresse = [];
  final TextEditingController localController = TextEditingController();

  @override
  void initState() {
    super.initState();
    grupo = widget.grupo;
    _loadUserData();
    _loadPontosInteresse();
  }

  Future<void> _loadUserData() async {
    // Simulação de carregamento de dados do usuário
    setState(() {
      userProfileImageUrl = 'https://example.com/user_profile_image.png';
    });
  }

  Future<void> _loadPontosInteresse() async {
    final prefs = await SharedPreferences.getInstance();
    final pontosInteresseString = prefs.getString('pontosInteresse');
    if (pontosInteresseString != null) {
      setState(() {
        pontosInteresse = List<Map<String, dynamic>>.from(json.decode(pontosInteresseString));
      });
    }
  }

  Future<void> _savePontosInteresse() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('pontosInteresse', json.encode(pontosInteresse));
  }

  Future<void> _addPontoInteresse() async {
    try {
      final local = localController.text;
      if (local.isEmpty) {
        print('Nome do local inválido.');
        return;
      }

      final coordinates = await _getCoordinatesFromLocation(local);
      if (coordinates == null) {
        print('Não foi possível obter as coordenadas.');
        return;
      }

      final ponto = {
        'grupo_id': grupo['id'],
        'latitude': coordinates.latitude,
        'longitude': coordinates.longitude,
        'nome': local,
      };

      setState(() {
        pontosInteresse.add(ponto);
      });
      await _savePontosInteresse();
    } catch (e) {
      print('Erro ao adicionar ponto de interesse: $e');
    }
  }

  Future<LatLng?> _getCoordinatesFromLocation(String location) async {
    final url = 'https://nominatim.openstreetmap.org/search?q=$location&format=json&limit=1';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lng = double.parse(data[0]['lon']);
          return LatLng(lat, lng);
        } else {
          print('Nenhum resultado encontrado para a localização fornecida.');
        }
      } else {
        print('Erro na solicitação da API: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao chamar a API do Nominatim: $e');
    }
    return null;
  }

  Future<void> _updatePontoInteresse(int index, LatLng newLocation) async {
    try {
      setState(() {
        pontosInteresse[index]['latitude'] = newLocation.latitude;
        pontosInteresse[index]['longitude'] = newLocation.longitude;
      });
      await _savePontosInteresse();
    } catch (e) {
      print('Erro ao atualizar ponto de interesse: $e');
    }
  }

  Future<void> _deletePontoInteresse(int index) async {
    try {
      setState(() {
        pontosInteresse.removeAt(index);
      });
      await _savePontosInteresse();
    } catch (e) {
      print('Erro ao deletar ponto de interesse: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushNamed(context, '/pomodoro', arguments: {
        'usuarioId': 'usuarioId',
        'grupoId': widget.grupo['id'],
        'grupo': widget.grupo,
      });
    } else if (index == 1) {
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
        title: 'Mapa',
        profileImageUrl: userProfileImageUrl,
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
        onProfileButtonPressed: () async {
          // Navega para a tela de perfil e aguarda o retorno
          final result = await Navigator.pushNamed(context, '/profile');
          
          // Se houve atualização, recarrega os dados do usuário
          if (result == true) {
            _loadUserData();
          }
        },
      ),
      backgroundColor: AppColors.cinzaClaro,
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
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
                  markers: pontosInteresse.map((ponto) {
                    return Marker(
                      point: LatLng(ponto['latitude'], ponto['longitude']),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          _showPontoInteresseDialog(ponto);
                        },
                        child: Icon(Icons.location_pin, size: 40, color: AppColors.laranja),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: localController,
                  decoration: InputDecoration(
                    labelText: 'Nome do Local',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _addPontoInteresse,
                  child: const Text('Adicionar Ponto de Interesse'),
                ),
                const SizedBox(height: 8),
                _buildPontosInteresseList(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildPontosInteresseList() {
    return pontosInteresse.isEmpty
        ? const Text('Nenhum ponto de interesse adicionado.')
        : ListView.builder(
            shrinkWrap: true,
            itemCount: pontosInteresse.length,
            itemBuilder: (context, index) {
              final ponto = pontosInteresse[index];
              return ListTile(
                title: Text(ponto['nome']),
                subtitle: Text('Lat: ${ponto['latitude']}, Lng: ${ponto['longitude']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deletePontoInteresse(index),
                ),
                onTap: () => _showUpdatePontoInteresseDialog(index, ponto),
              );
            },
          );
  }

  void _showPontoInteresseDialog(Map<String, dynamic> ponto) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ponto de Interesse'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nome: ${ponto['nome']}'),
              Text('Latitude: ${ponto['latitude']}'),
              Text('Longitude: ${ponto['longitude']}'),
              ElevatedButton(
                onPressed: () {
                  _deletePontoInteresse(pontosInteresse.indexOf(ponto));
                  Navigator.pop(context);
                },
                child: const Text('Deletar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showUpdatePontoInteresseDialog(pontosInteresse.indexOf(ponto), ponto);
                },
                child: const Text('Atualizar'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUpdatePontoInteresseDialog(int index, Map<String, dynamic> ponto) {
    final TextEditingController localController = TextEditingController(text: ponto['nome']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Atualizar Ponto de Interesse'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: localController,
                decoration: const InputDecoration(labelText: 'Nome do Local'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                final newLocation = await _getCoordinatesFromLocation(localController.text);
                if (newLocation != null) {
                  _updatePontoInteresse(index, newLocation);
                }
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }
}

