import 'package:belajar_app/pagesAdmin/DashboardAdminPage.dart';
import 'package:belajar_app/pagesAdmin/EduSantaiiSplashScreen.dart';
import 'package:belajar_app/pagesAdmin/TambahPelajarPage.dart';
import 'package:belajar_app/pagesUser/StudentDashboardPage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Aplikasi FLutter",
      home: EduSantaiiSplashScreen(),
    );
  }
}
