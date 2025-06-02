import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moodyarin/auth/service_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  void _showCustomSnackbar(String message, {bool isError = true}) {
    Flushbar(
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade600,
      icon: Icon(
        isError ? Icons.info_outline : Icons.check_circle_outline,
        color: Colors.white,
      ),
      flushbarPosition: FlushbarPosition.TOP,
      duration: const Duration(seconds: 3),
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    ).show(context);
  }


  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showCustomSnackbar('Email dan password wajib diisi.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.signIn(email, password);

      if (response.session != null && response.user != null) {
        _showCustomSnackbar('Login berhasil!', isError: false);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);

        await Future.delayed(
          const Duration(seconds: 2),
        );

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (_) => false,
          );
        }
      } else {
        _showCustomSnackbar('Email atau password salah.');
      }
    } catch (e) {
      _showCustomSnackbar('Gagal login: ${e.toString()}');
    }

    setState(() => _isLoading = false);
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7F92F0),
      body: Stack(
        children: [
          // Background image
          Positioned(
            child: Image.asset(
              'assets/IMG-07.png',
              width: 700,
              height: 600,
              fit: BoxFit.cover,
            ),
          ),

          // Text di atas
          Positioned(
            top: 110,
            left: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wellcome back,',
                  style: GoogleFonts.jua(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  'Masuk Sini !',
                  style: GoogleFonts.jua(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Form login
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password dengan toggle visibility
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/forgot');
                      },
                      child: Text(
                        'lupa password?',
                        style: GoogleFonts.rubik(
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  // Tombol Masuk
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'Masuk',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun ? ',
                        style: GoogleFonts.rubik(fontSize: 12),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/regist');
                        },
                        child: Text(
                          'Yuk Daftar!',
                          style: GoogleFonts.rubik(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
}