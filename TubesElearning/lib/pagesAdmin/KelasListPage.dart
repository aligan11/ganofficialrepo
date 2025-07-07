import 'dart:convert';
import 'package:belajar_app/pagesAdmin/EditKelasPage.dart';
import 'package:belajar_app/pagesAdmin/tambahKelasPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'CustomBottomNavBar.dart';

class KelasListPage extends StatefulWidget {
  const KelasListPage({super.key});

  @override
  State<KelasListPage> createState() => _KelasListPageState();
}

class _KelasListPageState extends State<KelasListPage> {
  List<Map<String, dynamic>> kelasList = [];
  int currentPage = 1;
  int rowsPerPage = 5;
  final List<int> rowsPerPageOptions = [3, 5, 10];
  String? nextNipNim;

  @override
  void initState() {
    super.initState();
    fetchKelas();
  }

  Future<void> fetchKelas() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final uri = Uri.parse('http://192.168.18.13:8080/api/kelas');
    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> kelasData = data['data'];

        setState(() {
          kelasList = kelasData.cast<Map<String, dynamic>>();
          nextNipNim = data['next_nim_nip'];
        });
      } else {
        print('Gagal fetch kelas: ${response.body}');
      }
    } catch (e) {
      print('Error fetch kelas: $e');
    }
  }

  Future<void> _hapusKelas(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse(
      'http://192.168.18.13:8080/api/admin/admin/kelas/$id',
    );

    try {
      final response = await http.delete(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil menghapus kelas')),
        );
        fetchKelas();
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['message'] ?? 'Gagal menghapus')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }

  void _konfirmasiHapus(int id) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Hapus'),
            content: const Text('Yakin ingin menghapus kelas ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _hapusKelas(id);
                },
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalData = kelasList.length;
    final int totalPages = (totalData / rowsPerPage).ceil();
    final int start = (currentPage - 1) * rowsPerPage;
    final int end = (start + rowsPerPage).clamp(0, totalData);
    final currentData = kelasList.sublist(start, end);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kelas'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            currentData.isEmpty
                ? const Center(child: Text('Tidak ada data kelas.'))
                : ListView.builder(
                  itemCount: currentData.length,
                  itemBuilder: (context, index) {
                    final kelas = currentData[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple[100],
                          child: const Icon(Icons.class_, color: Colors.purple),
                        ),
                        title: Text(kelas['nama_kelas'] ?? '-'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.orange,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => EditKelasPage(
                                          kelasId: kelas['id'],
                                          initialNamaKelas: kelas['nama_kelas'],
                                        ),
                                  ),
                                ).then((_) => fetchKelas());
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _konfirmasiHapus(kelas['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahKelasPage()),
          ).then((_) => fetchKelas());
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.purple,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (kelasList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Tampilkan:'),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: rowsPerPage,
                    onChanged: (v) {
                      setState(() {
                        rowsPerPage = v!;
                        currentPage = 1;
                      });
                    },
                    items:
                        rowsPerPageOptions
                            .map(
                              (e) =>
                                  DropdownMenuItem(value: e, child: Text('$e')),
                            )
                            .toList(),
                  ),
                  const SizedBox(width: 16),
                  Text('${start + 1}–$end dari $totalData'),
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed:
                        currentPage > 1
                            ? () => setState(() => currentPage--)
                            : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed:
                        currentPage < totalPages
                            ? () => setState(() => currentPage++)
                            : null,
                  ),
                ],
              ),
            ),
          CustomBottomNavBar(currentIndex: 0, context: context),
        ],
      ),
    );
  }
}
