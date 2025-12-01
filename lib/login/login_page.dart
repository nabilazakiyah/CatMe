import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final inputEmail = _emailCtrl.text.trim();
    final inputPass = _passCtrl.text;
    if (inputEmail.isEmpty || inputPass.isEmpty) {
      _showSnackBar('Email dan password harus diisi!', Colors.red);
      setState(() => _isLoading = false);
      return;
    }
    if (inputPass.length < 6) {
      _showSnackBar('Password minimal 6 karakter!', Colors.red);
      setState(() => _isLoading = false);
      return;
    }

    final savedEmail = prefs.getString('reg_email');
    final savedHash = prefs.getString('reg_pass');

    if (savedEmail == inputEmail && savedHash == _hashPassword(inputPass)) {
      await prefs.setBool('logged_in', true);
      await prefs.setString('user_email', inputEmail);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      _showSnackBar('Email atau password salah!', Colors.red);
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pets,
                size: 100, color: Color.fromRGBO(255, 152, 0, 1)),
            const Text(
              'Selamat Datang di CatMe!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _emailCtrl,
              decoration: InputDecoration(
                labelText: 'Email',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.email),
                filled: true,
                fillColor: const Color.fromARGB(255, 255, 255,
                    255),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passCtrl,
              decoration: InputDecoration(
                labelText: 'Password',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.lock),

                filled: true,
                fillColor: const Color.fromARGB(255, 255, 255,
                    255),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Login',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text('Belum punya akun? Register di sini!',
                  style: TextStyle(color: Colors.orange)),
            ),
          ],
        ),
      ),
    );
  }
}
