import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

class LokasiPage extends StatefulWidget {
  const LokasiPage({super.key});
  @override State<LokasiPage> createState() => _LokasiPageState();
}

class _LokasiPageState extends State<LokasiPage> {
  String zona = 'WIB';
  String jam = '';
  LatLng center = const LatLng(-7.7956, 110.3625); 

  @override
  void initState() {
    super.initState();
    _updateJam();
    _startClock();
  }

  void _updateJam() {
  final now = DateTime.now();
  int offset = 0;
  if (zona == 'WITA') offset = 1; 
  if (zona == 'WIT') offset = 2;  
  final adjusted = now.add(Duration(hours: offset));
  final formatter = DateFormat('HH:mm:ss');
  setState(() {
    jam = formatter.format(adjusted);
  });
}

  void _startClock() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _updateJam();
        _startClock();
      }
    });
  }

  void _gantiZona(String newZona) {
  setState(() {
    zona = newZona;
    if (newZona == 'WIB') center = const LatLng(-7.7956, 110.3625); 
    if (newZona == 'WITA') center = const LatLng(-8.5833, 116.1167); 
    if (newZona == 'WIT') center = const LatLng(-0.7893, 134.6490);
    _updateJam(); 
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CatMe'),
        backgroundColor: Colors.orangeAccent,
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'dev.fleaflet.flutter_map',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: center,
                      width: 100,
                      height: 100,
                      child: Column(
                        children: [
                          Image.asset('assets/cat_icon.png', width: 50), 
                          const Text('CatMe Jogja!', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.purple[50],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Zona: $zona | Jam: $jam', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _tombolZona('WIB', Colors.orange),
                      _tombolZona('WITA', Colors.purple[300]!),
                      _tombolZona('WIT', Colors.purple[100]!),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tombolZona(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ElevatedButton(
        onPressed: () => _gantiZona(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: zona == text ? color : Colors.grey[300],
          foregroundColor: zona == text ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}