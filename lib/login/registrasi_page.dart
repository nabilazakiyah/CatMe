import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _isLoading = false;

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<void> _register() async {
    // ... (Logika _register tetap sama)
    setState(() => _isLoading = true);

    if (_emailCtrl.text.trim().isEmpty) {
      _showSnackBar('Email harus diisi!', Colors.red);
      setState(() => _isLoading = false);
      return;
    }

    if (_passCtrl.text.length < 6) {
      _showSnackBar('Password minimal 6 karakter!', Colors.red);
      setState(() => _isLoading = false);
      return;
    }

    if (_passCtrl.text != _confirmCtrl.text) {
      _showSnackBar('Password tidak cocok!', Colors.red);
      setState(() => _isLoading = false);
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    // Menggunakan key yang lebih spesifik untuk cek email yang sudah terdaftar
    final existingEmail = prefs.getString('reg_email');
    if (existingEmail == _emailCtrl.text.trim()) {
      _showSnackBar('Email sudah terdaftar!', Colors.orange);
      setState(() => _isLoading = false);
      return;
    }

    final hashedPass = _hashPassword(_passCtrl.text);
    await prefs.setString('reg_email', _emailCtrl.text.trim());
    await prefs.setString('reg_pass', hashedPass);
    await prefs.setBool('logged_in', true);

    if (mounted) {
      // Pastikan '/home' sudah terdefinisi di MaterialApp routes Anda
      Navigator.pushReplacementNamed(context, '/home');
    }

    setState(() => _isLoading = false);
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // =============================================================
      // 1. GANTI WARNA BACKGROUND HALAMAN KESELURUHAN (SCAFFOLD)
      // =============================================================
      // Ganti Colors.white dengan warna yang Anda inginkan, misalnya Colors.grey[50]
      backgroundColor: Colors.orange[50],

      appBar: AppBar(
        // Menghapus title 'Register' agar hanya ada tombol Back seperti di gambar
        // Title dihilangkan, cukup tombol Back
        // title: const Text('Register'),
        backgroundColor: Colors.transparent, // Membuat AppBar transparan
        elevation: 0, // Menghilangkan bayangan
        foregroundColor: Colors.black, // Warna ikon panah
      ),
      // PERBAIKAN: Bungkus konten dengan SingleChildScrollView
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 10), // Ubah padding
        child: Column(
          // Ganti mainAxisAlignment dari center ke start agar mulai dari atas
          // CrossAxisAlignment.stretch berguna agar elemen memenuhi lebar horizontal
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Icon dan Teks Judul
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                children: [
                  Icon(Icons.pets,
                      size: 80,
                      color: Colors.orange), // Ukuran icon disesuaikan
                  SizedBox(height: 10),
                  Text(
                    'Daftar Akun CatMe!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // TextField Email
            const SizedBox(height: 30),
            TextField(
              controller: _emailCtrl,
              decoration: InputDecoration(
                labelText: 'Email',

                // =============================================================
                // 2A. SET 'filled: true' AGAR fillColor BISA DITERAPKAN
                // =============================================================
                filled: true,
                // =============================================================
                // 2B. GANTI WARNA BACKGROUND KOTAK INPUT EMAIL DI SINI
                // =============================================================
                fillColor: const Color.fromARGB(
                    255, 255, 255, 255), // Contoh warna background kotak input

                // Tampilan border seperti pada gambar
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.email),
                // Sesuaikan warna border jika perlu
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.orange, width: 2.0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),

            // TextField Password
            const SizedBox(height: 16),
            TextField(
              controller: _passCtrl,
              decoration: InputDecoration(
                labelText: 'Password',

                // =============================================================
                // 3A. SET 'filled: true' AGAR fillColor BISA DITERAPKAN
                // =============================================================
                filled: true,
                // =============================================================
                // 3B. GANTI WARNA BACKGROUND KOTAK INPUT PASSWORD DI SINI
                // =============================================================
                fillColor: const Color.fromARGB(
                    255, 255, 255, 255), // Contoh warna background kotak input

                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.lock),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.orange, width: 2.0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              obscureText: true,
            ),

            // TextField Konfirmasi Password
            const SizedBox(height: 16),
            TextField(
              controller: _confirmCtrl,
              decoration: InputDecoration(
                labelText: 'Konfirmasi Password',

                // =============================================================
                // 4A. SET 'filled: true' AGAR fillColor BISA DITERAPKAN
                // =============================================================
                filled: true,
                // =============================================================
                // 4B. GANTI WARNA BACKGROUND KOTAK INPUT KONF. PASSWORD DI SINI
                // =============================================================
                fillColor: const Color.fromARGB(
                    255, 255, 255, 255), // Contoh warna background kotak input

                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.lock_outline),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.orange, width: 2.0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              obscureText: true,
            ),

            const SizedBox(
                height: 30), // Tinggikan sedikit jarak sebelum tombol
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  // Menggunakan foregroundColor untuk warna text/progress
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Register', style: TextStyle(fontSize: 18)),
              ),
            ),

            // Tombol Login
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Sudah punya akun? Login',
                  style: TextStyle(color: Colors.orange)),
            ),
            // Tambahkan padding tambahan di bawah jika diperlukan untuk memastikan semua elemen terlihat
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
