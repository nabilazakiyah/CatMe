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
      backgroundColor: Colors.orange[50],

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 10),
        child: Column(

          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                children: [
                  Icon(Icons.pets,
                      size: 80,
                      color: Colors.orange),
                  SizedBox(height: 10),
                  Text(
                    'Daftar Akun CatMe!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            TextField(
              controller: _emailCtrl,
              decoration: InputDecoration(
                labelText: 'Email',
                filled: true,
                fillColor: const Color.fromARGB(
                    255, 255, 255, 255),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.email),
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

            const SizedBox(height: 16),
            TextField(
              controller: _passCtrl,
              decoration: InputDecoration(
                labelText: 'Password',
                filled: true,
                fillColor: const Color.fromARGB(
                    255, 255, 255, 255),

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

            const SizedBox(height: 16),
            TextField(
              controller: _confirmCtrl,
              decoration: InputDecoration(
                labelText: 'Konfirmasi Password',
                filled: true,
                fillColor: const Color.fromARGB(
                    255, 255, 255, 255),

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
                height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Register', style: TextStyle(fontSize: 18)),
              ),
            ),

            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Sudah punya akun? Login',
                  style: TextStyle(color: Colors.orange)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
