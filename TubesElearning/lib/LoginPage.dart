import 'package:belajar_app/pagesAdmin/DashboardAdminPage.dart';
import 'package:flutter/gestures.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: LoginPage()));
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String selectedRole = 'Mahasiswa';
  final List<String> roles = ['Mahasiswa', 'Pengajar', 'Admin'];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role = prefs.getString('role');

    if (token != null && role != null) {
      if (role == 'admin') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DashboardAdminPage()),
        );
      } else if (role == 'pengajar') {
        Navigator.pushReplacementNamed(context, '/dashboard-pengajar');
      } else if (role == 'mahasiswa') {
        Navigator.pushReplacementNamed(context, '/dashboard-mahasiswa');
      }
    }
  }

  Future<void> loginUser() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('http://192.168.18.13:8080/api/login');
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json'},
        body: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          'role': selectedRole.toLowerCase(), // opsional tergantung backend
        },
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        final data = responseData['data'];
        final detail = data['detail'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('nama', detail['nama']);
        await prefs.setString('email', detail['email']);
        await prefs.setString('role', detail['role']);

        // ✅ Notifikasi sukses
        showTopRightNotification(
          context,
          responseData['message'],
          Colors.green,
        );

        // ✅ Navigasi sesuai role (contoh admin)
        if (detail['role'] == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => DashboardAdminPage()),
          );
        }
        // Bisa tambah else if buat pengajar / mahasiswa
      } else {
        showTopRightNotification(
          context,
          responseData['message'] ?? 'Login gagal',
          Colors.red,
        );
      }
    }
  }

  void showTopRightNotification(
    BuildContext context,
    String message,
    Color bgColor,
  ) {
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            top: 50,
            right: 20,
            child: Material(
              color: Colors.transparent,
              child: _NotificationWidget(
                message: message,
                backgroundColor: bgColor,
                onClose: () {
                  overlayEntry?.remove();
                },
              ),
            ),
          ),
    );

    Overlay.of(context)?.insert(overlayEntry);
    Future.delayed(Duration(seconds: 3), () => overlayEntry?.remove());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset('assets/images/title.png', height: 150, width: 250),
                // Text(
                //   'Welcome Back!',
                //   style: TextStyle(
                //     fontSize: 24,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.black87,
                //   ),
                // ),
                SizedBox(height: 10),
                Text(
                  'Login to your account',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator:
                            (value) =>
                                value!.isEmpty
                                    ? 'Email tidak boleh kosong'
                                    : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator:
                            (value) =>
                                value!.isEmpty
                                    ? 'Password tidak boleh kosong'
                                    : null,
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        items:
                            roles
                                .map(
                                  (role) => DropdownMenuItem<String>(
                                    value: role,
                                    child: Text(role),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Pilih Role',
                          prefixIcon: Icon(Icons.account_circle),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: loginUser,

                          child: const Text('Login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF000245),

                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final VoidCallback onClose;

  const _NotificationWidget({
    Key? key,
    required this.message,
    required this.backgroundColor,
    required this.onClose,
  }) : super(key: key);

  @override
  State<_NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<_NotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.backgroundColor == Colors.green
                  ? Icons.check_circle_outline
                  : Icons.error_outline,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                widget.message,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 12),
            GestureDetector(
              onTap: widget.onClose,
              child: Icon(Icons.close, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
