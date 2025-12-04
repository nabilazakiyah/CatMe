import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/model/cat_model.dart';
import 'package:flutter_application_1/controller/cat_detail_controller.dart';
import 'package:flutter_application_1/service/database_service.dart';

class CatDetailPage extends StatefulWidget {
  final CatModel cat;
  const CatDetailPage({super.key, required this.cat});

  @override
  State<CatDetailPage> createState() => _CatDetailPageState();
}

class _CatDetailPageState extends State<CatDetailPage> {
  final controller = CatDetailController();
  String? imageUrl;
  String _selectedCurrencyCode = '';
  bool _isWishlisted = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
    _loadCurrencyPreference();
    _checkWishlistStatus();
  }

  Future<void> _loadCurrencyPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final currency = prefs.getString('selected_currency') ?? '';

    if (mounted) {
      setState(() {
        _selectedCurrencyCode = currency;
      });
    }
  }

  Future<void> _checkWishlistStatus() async {
    final isInWishlist = await DatabaseService().isInWishlist(widget.cat.breed);
    if (mounted) {
      setState(() {
        _isWishlisted = isInWishlist;
      });
    }
  }

  Future<void> _loadImage() async {
    final url = await controller.loadImage(widget.cat.breed);
    if (mounted) {
      setState(() => imageUrl = url);
    }
  }

  Future<void> _toggleWishlist() async {
    try {
      if (_isWishlisted) {
        await DatabaseService().removeFromWishlist(widget.cat.breed);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${widget.cat.breed} dihapus dari wishlist"),
              backgroundColor: Colors.orange[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(20),
            ),
          );
        }
      } else {
        await DatabaseService().addToWishlist(widget.cat);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${widget.cat.breed} ditambahkan ke wishlist! 🧡"),
              backgroundColor: Colors.deepOrange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(20),
            ),
          );
        }
      }

      setState(() {
        _isWishlisted = !_isWishlisted;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mengupdate wishlist: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _adopt() async {
    final androidDetails = AndroidNotificationDetails(
      'adopsi_channel',
      'Adopsi Kucing',
      channelDescription: 'Notifikasi adopsi berhasil',
      importance: Importance.high,
      priority: Priority.high,
      sound: const RawResourceAndroidNotificationSound('meow'),
      icon: '@mipmap/ic_launcher',
      ticker: 'Adopsi Berhasil!',
      autoCancel: true,
      styleInformation: BigTextStyleInformation(
        'Makasih udah adopsi ${widget.cat.breed}!\n'
        'Sekarang dia resmi jadi keluarga!\n'
        'Jangan lupa kasih makan, main, dan peluk ya~',
        htmlFormatBigText: true,
      ),
    );
    final details = NotificationDetails(android: androidDetails);

    await notifications.show(
      999,
      'Yeay! ${widget.cat.breed} Milikmu!',
      'Makasih udah sayangin kucing! Jangan lupa kasih makan ya',
      details,
    );

    await DatabaseService().saveAdopsi(widget.cat);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Yeay! ${widget.cat.breed} sekarang milikmu!"),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(20),
        action: SnackBarAction(
          label: 'Lihat Notif',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged_in', false);
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 12),
            decoration: const BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "CatMe",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                TextButton(
                  onPressed: _logout,
                  child: const Text("Logout",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl!,
                              height: 280,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 280,
                                  color: Colors.orange[50],
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.orange),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => Container(
                                height: 280,
                                color: Colors.orange[50],
                                child: const Icon(Icons.error,
                                    size: 60, color: Colors.red),
                              ),
                            )
                          : Container(
                              height: 280,
                              color: Colors.orange[50],
                              child: const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.orange)),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.cat.breed,
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange),
                  ),
                  const SizedBox(height: 16),
                  _infoRow(Icons.location_on, "Asal: ${widget.cat.country}"),
                  _infoRow(Icons.pets, "Tipe: ${widget.cat.coat}"),
                  _infoRow(Icons.description,
                      "Deskripsi: ${widget.cat.description}"),
                  _infoRow(Icons.money,
                      "Harga: ${CatModel.formatCurrency(widget.cat.adoptionFeeIDR, _selectedCurrencyCode)}"),
                  const SizedBox(height: 30),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _toggleWishlist,
                      icon: Icon(
                        _isWishlisted ? Icons.favorite : Icons.favorite_border,
                        color: Colors.white,
                      ),
                      label: Text(
                        _isWishlisted
                            ? "Hapus dari Wishlist"
                            : "Tambah ke Wishlist",
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isWishlisted ? Colors.orange[300] : Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _adopt,
                      icon: const Icon(Icons.pets, color: Colors.white),
                      label: const Text("Adopsi Sekarang!",
                          style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}