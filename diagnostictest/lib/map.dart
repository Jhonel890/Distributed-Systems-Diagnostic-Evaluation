import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class map extends StatefulWidget {
  @override
  _mapState createState() => _mapState();
}

class _mapState extends State<map> {
  final MapController _mapController = MapController();
  LatLng _currentPosition = LatLng(-0.1807, -78.4678); // Posición inicial (LOJA)
  List<Marker> _markers = [];
  String _selectedCategory = '';
  bool _isLoading = false;
  bool _isLocating = false;

  final Map<String, String> _categories = {
    'place_of_worship': 'Iglesias',
    'pharmacy': 'Farmacias',
    'school': 'Escuelas',
    'restaurant': 'Restaurantes',
    'hospital': 'Hospitales',
    'bank': 'Bancos',
    'library': 'Bibliotecas',
    'cinema': 'Cines',
    'theatre': 'Teatros',
  };

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocating = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _mapController.move(_currentPosition, 15);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener la ubicación: $e')),
      );
    } finally {
      setState(() {
        _isLocating = false;
      });
    }
  }

  Future<void> _loadPOIs(String category) async {
    if (category.isEmpty) return;

    setState(() {
      _isLoading = true;
      _markers = [];
    });

    try {
      final response = await http.get(Uri.parse(
          'https://overpass-api.de/api/interpreter?data=[out:json];node["amenity"="$category"](around:5000,${_currentPosition.latitude},${_currentPosition.longitude});out;'
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Marker> newMarkers = [];

        for (var element in data['elements']) {
          newMarkers.add(Marker(
            point: LatLng(element['lat'], element['lon']),
            builder: (ctx) => _buildCustomMarker(category),
          ));
        }

        setState(() {
          _markers = newMarkers;
          _selectedCategory = category;
        });
      } else {
        throw Exception('Failed to load POIs');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los datos: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildCustomMarker(String category) {
    return Container(
      decoration: BoxDecoration(
        color: _getColorForCategory(category),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          _getIconForCategory(category),
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'place_of_worship':
        return Icons.church;
      case 'pharmacy':
        return Icons.local_pharmacy;
      case 'school':
        return Icons.school;
      case 'restaurant':
        return Icons.restaurant;
      default:
        return Icons.place;
    }
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'place_of_worship':
        return Colors.blue;
      case 'pharmacy':
        return Colors.red;
      case 'school':
        return Colors.green;
      case 'restaurant':
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa Interactivo (OSM)'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _currentPosition,
                zoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    ..._markers,
                    Marker(
                      point: _currentPosition,
                      builder: (ctx) => Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedCategory.isEmpty ? null : _selectedCategory,
                  hint: Text('Selecciona una categoría'),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _loadPOIs(newValue);
                    }
                  },
                  items: _categories.entries.map<DropdownMenuItem<String>>((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                ),
                SizedBox(height: 10),
                if (_isLoading || _isLocating)
                  CircularProgressIndicator()
                else if (_selectedCategory.isNotEmpty)
                  Text('Mostrando: ${_categories[_selectedCategory]}'),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _getCurrentLocation,
                  child: Text('Actualizar mi ubicación'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
