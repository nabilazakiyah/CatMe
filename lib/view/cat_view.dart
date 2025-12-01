import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Tambahkan import notifikasi yang diperlukan
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../controller/cat_view_controller.dart';
import '../model/cat_model.dart';

class CatView extends StatefulWidget {
  const CatView({super.key});
  @override
  State<CatView> createState() => _CatViewState();
}

class _CatViewState extends State<CatView> {
  // 1. Inisialisasi Plugin (buat di luar fungsi)
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    // 2. Panggil fungsi permintaan izin saat halaman dimuat pertama kali
    requestNotificationPermissions();
  }

  // 3. Fungsi untuk Meminta Izin Notifikasi (Sama seperti yang Anda berikan)
  void requestNotificationPermissions() async {
    // Meminta izin notifikasi untuk Android 13+
    final status = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Untuk iOS, izin diminta melalui metode lain saat init, tapi ini adalah langkah penting untuk Android
    print('Notification Permission Status: $status');
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CatViewController()..fetchCats(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('CatMe'),
          backgroundColor: Colors.orange,
          actions: [
            Consumer<CatViewController>(
              builder: (_, ctrl, __) {
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.money, color: Colors.white),
                  onSelected: (cur) {
                    ctrl.currency = cur;
                    ctrl.filter('', cur);
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'IDR', child: Text('IDR')),
                    const PopupMenuItem(value: 'USD', child: Text('USD')),
                    const PopupMenuItem(value: 'KRW', child: Text('KRW')),
                    const PopupMenuItem(value: 'SAR', child: Text('SAR')),
                    const PopupMenuItem(value: 'GBP', child: Text('GBP')),
                  ],
                );
              },
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('logged_in', false);
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (r) => false);
              },
              child:
                  const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        body: Consumer<CatViewController>(
          builder: (_, ctrl, __) {
            if (ctrl.isLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.orange));
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    onChanged: (q) => ctrl.filter(q, ctrl.currency),
                    decoration: InputDecoration(
                      hintText: 'Cari kucing kesayangan...',
                      suffixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30)),
                      filled: true,
                      fillColor: Colors.orange[50],
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: ctrl.filtered.length,
                    itemBuilder: (_, i) {
                      final cat = ctrl.filtered[i];
                      return GestureDetector(
                        onTap: () => ctrl.goToDetail(context, cat),
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16)),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      'https://cataas.com/cat/says/${cat.breed}',
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                      color: Colors.orange[100],
                                      child: const Icon(Icons.pets,
                                          size: 50, color: Colors.orange)),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(cat.breed,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.orange)),
                                      const SizedBox(height: 4),
                                      Text(
                                          CatModel.formatCurrency(
                                              cat.adoptionFeeIDR,
                                              ctrl.currency),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.orange)),
                                      const SizedBox(height: 8),
                                      const Text("Tap untuk adopsi! ❤️",
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
