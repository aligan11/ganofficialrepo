import 'dart:convert';
import 'package:belajar_app/pagesAdmin/editJurusanPage.dart';
import 'package:belajar_app/pagesAdmin/tambahJurusanPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'CustomBottomNavBar.dart';

class JurusanListPage extends StatefulWidget {
  const JurusanListPage({super.key});

  @override
  State<JurusanListPage> createState() => _JurusanListPageState();
}

class _JurusanListPageState extends State<JurusanListPage> {
  List<Map<String, dynamic>> jurusanList = [];
  int currentPage = 1;
  int rowsPerPage = 5;
  final List<int> rowsPerPageOptions = [3, 5, 10];

  @override
  void initState() {
    super.initState();
    fetchJurusan();
  }

  Future<void> _hapusJurusan(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse(
      'http://192.168.18.13:8080/api/admin/admin/jurusan/$id',
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
          const SnackBar(content: Text('Berhasil menghapus jurusan')),
        );
        fetchJurusan();
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

  Future<void> fetchJurusan() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse('http://192.168.18.13:8080/api/admin/showJurusan');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> jurusanData = data['data'];

        setState(() {
          jurusanList = jurusanData.cast<Map<String, dynamic>>();
        });
      } else {
        print('Gagal fetch jurusan: ${response.body}');
      }
    } catch (e) {
      print('Error fetch jurusan: $e');
    }
  }

  void _konfirmasiHapus(int id) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Hapus'),
            content: const Text('Yakin ingin menghapus jurusan ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _hapusJurusan(id);
                },
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalData = jurusanList.length;
    final int totalPages = (totalData / rowsPerPage).ceil();
    final int start = (currentPage - 1) * rowsPerPage;
    final int end = (start + rowsPerPage).clamp(0, totalData);
    final currentData = jurusanList.sublist(start, end);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Jurusan'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            currentData.isEmpty
                ? const Center(child: Text('Tidak ada data jurusan.'))
                : ListView.builder(
                  itemCount: currentData.length,
                  itemBuilder: (context, index) {
                    final jurusan = currentData[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal[100],
                          child: const Icon(Icons.school, color: Colors.teal),
                        ),
                        title: Text(jurusan['nama_jurusan'] ?? '-'),
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
                                        (context) => EditJurusanPage(
                                          jurusanId: jurusan['id'],
                                          initialNamaJurusan:
                                              jurusan['nama_jurusan'],
                                        ),
                                  ),
                                ).then((_) => fetchJurusan());
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _konfirmasiHapus(jurusan['id']),
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
            MaterialPageRoute(builder: (context) => TambahJurusanPage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.teal,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (jurusanList.isNotEmpty)
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
