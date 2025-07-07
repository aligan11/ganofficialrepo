import 'package:belajar_app/LoginPage.dart';
import 'package:belajar_app/pagesAdmin/DashboardAdminPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

class EduSantaiiSplashScreen extends StatefulWidget {
  const EduSantaiiSplashScreen({super.key});

  @override
  State<EduSantaiiSplashScreen> createState() => _EduSantaiiSplashScreenState();
}

class _EduSantaiiSplashScreenState extends State<EduSantaiiSplashScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Teks EduSantaii di kiri atas
          Positioned(
            top: 40,
            left: 24,
            child: Row(
              children: const [
                Icon(Icons.school, color: Color(0xFFFF9800), size: 28),
                SizedBox(width: 6),
                Text(
                  'EduSantaii',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF000245),
                  ),
                ),
              ],
            ),
          ),

          // Konten utama di tengah
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Main Image
                  Container(
                    width: 200,
                    height: 260,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://storage.googleapis.com/a1aa/image/4af5053c-137d-4ca7-1c5a-61d544ade69a.jpg',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tagline
                  const Text(
                    'Belajar Santai, Hasil Mantap 🚀',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF000245),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Subheading
                  const Text(
                    'Platform E-Learning Kampus',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF000245),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Akses materi kuliah, kumpulkan tugas,\ndan pantau progres akademikmu dengan mudah.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Mulai Sekarang'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF000245),
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
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
}
