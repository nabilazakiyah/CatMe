import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/database_service.dart';
import '../model/cat_model.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});
  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  static const String name = 'Nama: Nabila Marwa Z';
  static const String nim = 'NIM: 129230001';
  static const String kelas = 'Kelas: SI - A';

  String bio = 'Alhamdulillah belajar banyak dari PAM skrg';
  List<CatModel> riwayat = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBio();
    _loadRiwayat();
  }

  Future<void> _loadBio() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        bio = prefs.getString('bio') ??
            'Sangat berkesan Mobile di semester ini dengan harus maksimal eksplor pelajaran sendiri karena tidak bisa hanya mengandalkan pmateri di praktikum maupun kelas saja';
      });
    }
  }

  Future<void> _loadRiwayat() async {
    setState(() => _isLoading = true);
    try {
      final data = await DatabaseService().getRiwayat();
      if (mounted) {
        setState(() {
          riwayat = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal load riwayat: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route?.isCurrent == true) {
      _loadRiwayat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CatMe'),
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('logged_in', false);
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (r) => false);
              }
            },
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadRiwayat,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const CircleAvatar(
                  radius: 70,
                  backgroundImage: AssetImage('assets/profile.jpg')),
              const SizedBox(height: 24),
              Text(name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(nim, style: const TextStyle(fontSize: 16)),
              Text(kelas, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 32),
              Card(
                elevation: 4,
                color: Colors.orange[50],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text('Kesan & Pesan PAM',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange)),
                      const SizedBox(height: 12),
                      // *** PERUBAHAN ADA DI SINI: FontStyle.italic DIHAPUS ***
                      Text(bio,
                          style: const TextStyle(
                              fontSize:
                                  15), // Dihapus: fontStyle: FontStyle.italic
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Card(
                elevation: 5,
                color: Colors.orange[50],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ExpansionTile(
                  leading: const Icon(Icons.history_edu,
                      color: Colors.orange, size: 28),
                  title: const Text('Riwayat Adopsi',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  children: _isLoading
                      ? [
                          const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.orange)))
                        ]
                      : riwayat.isEmpty
                          ? [
                              const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text('Belum ada kucing yang diadopsi',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 15),
                                      textAlign: TextAlign.center))
                            ]
                          : riwayat
                              .map((cat) => ListTile(
                                    leading: const Icon(Icons.favorite,
                                        color: Colors.red),
                                    title: Text(cat.breed,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    subtitle:
                                        Text('Diadopsi: ${cat.formattedDate}'),
                                    trailing: const Icon(Icons.pets,
                                        color: Colors.orange),
                                  ))
                              .toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
