import 'dart:convert';
import 'package:belajar_app/pagesAdmin/CustomBottomNavBar.dart';
import 'package:belajar_app/pagesAdmin/EditPelajarPage.dart';
import 'package:belajar_app/pagesAdmin/TambahPelajarPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PelajarPage extends StatefulWidget {
  const PelajarPage({super.key});

  @override
  State<PelajarPage> createState() => _PelajarPageState();
}

class _PelajarPageState extends State<PelajarPage> {
  int currentPage = 1;
  int rowsPerPage = 5;
  final List<int> rowsPerPageOptions = [3, 5, 10];

  String? selectedProdi;
  String? selectedKelas;

  List<Map<String, dynamic>> mahasiswaList = [];

  @override
  void initState() {
    super.initState();
    fetchMahasiswa();
  }

  void _konfirmasiHapus(BuildContext context, int id) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Hapus'),
            content: const Text(
              'Apakah kamu yakin ingin menghapus mahasiswa ini?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _hapusMahasiswa(id);
                },
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  Future<void> _hapusMahasiswa(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('http://192.168.18.13:8080/api/admin/mahasiswa/$id');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Berhasil dihapus')),
        );

        // Refresh UI / data
        setState(() {
          // Panggil ulang fetch list mahasiswa atau hapus dari list lokal
        });
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

  Future<void> fetchMahasiswa() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final uri = Uri.parse('http://192.168.18.13:8080/api/admin/mahasiswa');
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
      final List<dynamic> mahasiswaData = data['data'];
      setState(() {
        mahasiswaList = mahasiswaData.cast<Map<String, dynamic>>();
      });
    } else {
      print('Gagal fetch mahasiswa: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final prodiList =
        mahasiswaList
            .map((m) => m['jurusan']['nama_jurusan'] as String)
            .toSet()
            .toList();
    final kelasList =
        mahasiswaList
            .map((m) => m['kelas']['nama_kelas'] as String)
            .toSet()
            .toList();

    final filteredList =
        mahasiswaList.where((mhs) {
          final cocokProdi =
              selectedProdi == null ||
              mhs['jurusan']['nama_jurusan'] == selectedProdi;
          final cocokKelas =
              selectedKelas == null ||
              mhs['kelas']['nama_kelas'] == selectedKelas;
          return cocokProdi && cocokKelas;
        }).toList();

    final int totalData = filteredList.length;
    final int totalPages = (totalData / rowsPerPage).ceil();
    final int start = (currentPage - 1) * rowsPerPage;
    final int end = (start + rowsPerPage).clamp(0, totalData);
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
            Icon(Icons.person_add_alt_1_rounded, color: Colors.blue, size: 22),
            SizedBox(width: 8),
            Text(
              'Daftar Pelajar',
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 18,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Filter Prodi',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    value: selectedProdi,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Semua Prodi'),
                      ),
                      ...prodiList.map(
                        (prodi) => DropdownMenuItem(
                          value: prodi,
                          child: Text(
                            prodi == 'Teknologi Rekayasa Perangkat Lunak'
                                ? 'TRPL'
                                : prodi,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedProdi = value;
                        currentPage = 1;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 18,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Filter Kelas',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    value: selectedKelas,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Semua Kelas'),
                      ),
                      ...kelasList.map(
                        (kelas) => DropdownMenuItem(
                          value: kelas,
                          child: Text(
                            kelas,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedKelas = value;
                        currentPage = 1;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  currentPageData.isEmpty
                      ? const Center(child: Text('Tidak ada data pelajar.'))
                      : ListView.builder(
                        itemCount: currentPageData.length,
                        itemBuilder: (context, index) {
                          final pelajar = currentPageData[index];
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
                                    backgroundColor: Colors.blue.shade100,
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          pelajar['nama'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text('NIM: ${pelajar['nim_nip']}'),
                                        Text(
                                          'Prodi: ${pelajar['jurusan']['nama_jurusan']}',
                                        ),
                                        Text(
                                          'Kelas: ${pelajar['kelas']['nama_kelas']}',
                                        ),
                                      ],
                                    ),
                                  ),
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
                                              (context) => EditPelajarPage(
                                                mahasiswaId: pelajar['id'],
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
                                    onPressed:
                                        () => _konfirmasiHapus(
                                          context,
                                          pelajar['id'],
                                        ),
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
            MaterialPageRoute(builder: (context) => const TambahPelajarPage()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
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
          CustomBottomNavBar(currentIndex: 1, context: context),
        ],
      ),
    );
  }
}
