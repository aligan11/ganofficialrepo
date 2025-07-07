import 'package:belajar_app/pagesAdmin/DashboardAdminPage.dart';
import 'package:belajar_app/pagesAdmin/MatkulListPage.dart';
import 'package:belajar_app/pagesAdmin/PelajarPage.dart';
import 'package:belajar_app/pagesAdmin/PengajarPage.dart';
import 'package:belajar_app/pagesAdmin/TambahPelajarPage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Ganti ini sesuai dengan nama halaman kamu

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final BuildContext context;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.context,
  });

  void _navigate(int index) {
    if (index == currentIndex) return; // Hindari push ulang halaman yg sama

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DashboardAdminPage()),
      );
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => PelajarPage()));
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PengajarPage()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MatkulListPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: _navigate,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.tachometerAlt),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.userGraduate),
          label: 'Pelajar',
        ),
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.chalkboardTeacher),
          label: 'Pengajar',
        ),
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.book),
          label: 'Matkul',
        ),
      ],
    );
  }
}
