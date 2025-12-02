import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/service/database_service.dart';
import 'package:flutter_application_1/model/cat_model.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});
  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  List<CatModel> riwayat = [];
  List<CatModel> wishlist = [];
  bool _isLoadingRiwayat = true;
  bool _isLoadingWishlist = true;

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
    _loadWishlist();
  }

  Future<void> _loadRiwayat() async {
    setState(() => _isLoadingRiwayat = true);
    try {
      final data = await DatabaseService().getRiwayat();
      if (mounted) {
        setState(() {
          riwayat = data;
          _isLoadingRiwayat = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRiwayat = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal load riwayat: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadWishlist() async {
    setState(() => _isLoadingWishlist = true);
    try {
      final data = await DatabaseService().getWishlist();
      if (mounted) {
        setState(() {
          wishlist = data;
          _isLoadingWishlist = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingWishlist = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal load wishlist: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    await Future.wait([_loadRiwayat(), _loadWishlist()]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route?.isCurrent == true) {
      _refreshData();
    }
  }

 Widget _buildProfileCard({
  required String imagePath,
  required String name,
  required String nim,
  required String kelas,
}) {
  return SizedBox(
    width: double.infinity,
    child: Card(
      elevation: 4,
      color: Colors.orange[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 70,
              backgroundImage: AssetImage(imagePath),
            ),
            const SizedBox(height: 16),
            Text(
              'Nama: $name',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('NIM: $nim', style: const TextStyle(fontSize: 16)),
            Text('Kelas: $kelas', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CatMe'),
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.black,
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
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProfileCard(
                imagePath: 'assets/profile.jpg',
                name: 'Nabila Marwa Zakiyah',
                nim: '124230001',
                kelas: 'SI - C',
              ),
              
              const SizedBox(height: 16),
              
              _buildProfileCard(
                imagePath: 'assets/profile2.jpg',
                name: 'Nashwa Luthfiya',
                nim: '124230016',
                kelas: 'SI - C',
              ),

              const SizedBox(height: 32),

              Card(
                elevation: 5,
                color: Colors.orange[100],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ExpansionTile(
                  leading: const Icon(Icons.favorite,
                      color: Colors.deepOrange, size: 28),
                  title: const Text('Wishlist Kucing',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  children: _isLoadingWishlist
                      ? [
                          const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.deepOrange)))
                        ]
                      : wishlist.isEmpty
                          ? [
                              const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text('Belum ada kucing di wishlist',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 15),
                                      textAlign: TextAlign.center))
                            ]
                          : wishlist
                              .map((cat) => ListTile(
                                    leading: const Icon(Icons.favorite,
                                        color: Colors.deepOrange),
                                    title: Text(cat.breed,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    subtitle: Text(
                                        'Ditambahkan: ${cat.formattedDate}'),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () async {
                                        await DatabaseService()
                                            .removeFromWishlist(cat.breed);
                                        _loadWishlist();
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  '${cat.breed} dihapus dari wishlist'),
                                              backgroundColor:
                                                  Colors.orange[700],
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ))
                              .toList(),
                ),
              ),

              const SizedBox(height: 16),

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
                  children: _isLoadingRiwayat
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
                                    leading: const Icon(Icons.pets,
                                        color: Colors.orange),
                                    title: Text(cat.breed,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    subtitle:
                                        Text('Diadopsi: ${cat.formattedDate}'),
                                    trailing: const Icon(Icons.check_circle,
                                        color: Colors.green),
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