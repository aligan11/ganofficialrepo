import 'dart:convert';
import 'package:belajar_app/pagesAdmin/CustomBottomNavBar.dart';
import 'package:belajar_app/pagesAdmin/EditPengajarPage.dart';
import 'package:belajar_app/pagesAdmin/TambahPengajarPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PengajarPage extends StatefulWidget {
  const PengajarPage({super.key});

  @override
  State<PengajarPage> createState() => _PengajarPageState();
}

class _PengajarPageState extends State<PengajarPage> {
  int currentPage = 1;
  int rowsPerPage = 5;
  final List<int> rowsPerPageOptions = [3, 5, 10];

  String? selectedKelas;
  String? selectedProdi;

  List<Map<String, dynamic>> pengajarList = [];
  List<String> kelasList = [];
  List<String> prodiList = [];

  @override
  void initState() {
    super.initState();
    fetchPengajar();
  }

  Future<void> hapusPengajar(BuildContext context, int id) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text('Yakin ingin menghapus pengajar ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );

    if (shouldDelete == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        print("tampil id nya: ${id}");
        final response = await http.delete(
          Uri.parse('http://192.168.18.13:8080/api/admin/pengajar/$id'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pengajar berhasil dihapus')),
          );

          // TODO: panggil setState atau fungsi refresh data di luar fungsi ini
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus: ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
      }
    }
  }

  Future<void> fetchPengajar() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final uri = Uri.parse('http://192.168.18.13:8080/api/admin/dosen');
    try {
      final resp = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final List<dynamic> list = data['data'];
        setState(() {
          pengajarList = list.cast<Map<String, dynamic>>();
          kelasList =
              pengajarList
                  .map((d) => d['kelas_id']?.toString() ?? '—')
                  .toSet()
                  .toList();
          prodiList =
              pengajarList
                  .map((d) => d['jurusan_id']?.toString() ?? '—')
                  .toSet()
                  .toList();
        });
      } else {
        print('Gagal fetch dosen: ${resp.body}');
      }
    } catch (e) {
      print('Error fetch dosen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList =
        pengajarList.where((item) {
          final matchKelas =
              selectedKelas == null ||
              (item['kelas_id']?.toString() == selectedKelas);
          final matchProdi =
              selectedProdi == null ||
              (item['jurusan_id']?.toString() == selectedProdi);
          return matchKelas && matchProdi;
        }).toList();

    final totalData = filteredList.length;
    final totalPages = (totalData / rowsPerPage).ceil();
    final start = (currentPage - 1) * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, totalData);
    final currentPageData = filteredList.sublist(start, end);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.groups, color: Color(0xFFFF850B), size: 22),
            SizedBox(width: 8),
            Text(
              'Daftar Pengajar',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
        shape: const Border(bottom: BorderSide(color: Colors.grey, width: 0.3)),
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedProdi,
                    decoration: const InputDecoration(
                      labelText: 'Filter Prodi',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        [null, ...prodiList].map((val) {
                          return DropdownMenuItem(
                            value: val,
                            child: Text(val ?? 'Semua Prodi'),
                          );
                        }).toList(),
                    onChanged:
                        (v) => setState(() {
                          selectedProdi = v;
                          currentPage = 1;
                        }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedKelas,
                    decoration: const InputDecoration(
                      labelText: 'Filter Kelas',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        [null, ...kelasList].map((val) {
                          return DropdownMenuItem(
                            value: val,
                            child: Text(val ?? 'Semua Kelas'),
                          );
                        }).toList(),
                    onChanged:
                        (v) => setState(() {
                          selectedKelas = v;
                          currentPage = 1;
                        }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  currentPageData.isEmpty
                      ? const Center(child: Text('Tidak ada data pengajar.'))
                      : ListView.builder(
                        itemCount: currentPageData.length,
                        itemBuilder: (c, i) {
                          final d = currentPageData[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.orange.shade100,
                                    child: const Icon(
                                      Icons.school,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          d['nama'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text('NIP: ${d['nim_nip'] ?? '-'}'),
                                        Text('Email: ${d['email'] ?? '-'}'),
                                      ],
                                    ),
                                  ),
                                  Row(
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
                                                  (context) => EditPengajarPage(
                                                    pengajarId: d['id'],
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () async {
                                          final shouldDelete = await showDialog<
                                            bool
                                          >(
                                            context: context,
                                            builder:
                                                (context) => AlertDialog(
                                                  title: const Text(
                                                    'Konfirmasi Penghapusan',
                                                  ),
                                                  content: const Text(
                                                    'Pengajar ini masih memiliki mata kuliah yang diajarkan.\n\n'
                                                    'Apakah Anda yakin ingin menghapus pengajar ini beserta semua mata kuliah yang diampu?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            context,
                                                            false,
                                                          ),
                                                      child: const Text(
                                                        'Batal',
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            context,
                                                            true,
                                                          ),
                                                      child: const Text(
                                                        'Hapus',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          );

                                          if (shouldDelete == true) {
                                            print(
                                              'ID yang dikirim: ${d['id']}',
                                            );
                                            hapusPengajar(context, d['id']);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahPengajarPage()),
          );
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (filteredList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Tampilkan:'),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: rowsPerPage,
                    onChanged:
                        (v) => setState(() {
                          rowsPerPage = v!;
                          currentPage = 1;
                        }),
                    items:
                        rowsPerPageOptions
                            .map(
                              (val) => DropdownMenuItem(
                                value: val,
                                child: Text('$val'),
                              ),
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
          CustomBottomNavBar(currentIndex: 2, context: context),
        ],
      ),
    );
  }
}
