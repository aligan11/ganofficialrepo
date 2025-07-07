import 'dart:convert';
import 'package:belajar_app/pagesAdmin/CustomBottomNavBar.dart';
import 'package:belajar_app/pagesAdmin/EditMatkulPage.dart';
import 'package:belajar_app/pagesAdmin/TambahMataKuliahPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MatkulListPage extends StatefulWidget {
  @override
  _MatkulListPageState createState() => _MatkulListPageState();
}

class _MatkulListPageState extends State<MatkulListPage> {
  List<Map<String, dynamic>> matkulList = [];
  Map<int, String> pengajarMap = {}; // id -> nama

  int currentPage = 1;
  int rowsPerPage = 5;
  final List<int> rowsPerPageOptions = [3, 5, 10];

  @override
  void initState() {
    super.initState();
    _fetchPengajarMap(); // duluan, agar bisa dicocokkan
    _fetchMatkulList();
  }

  Future<void> hapusMatkul(BuildContext context, int index, int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Penghapusan'),
            content: const Text(
              'Apakah Anda yakin ingin menghapus mata kuliah ini?',
            ),
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

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      try {
        final response = await http.delete(
          Uri.parse(
            'http://192.168.18.13:8080/api/admin/admin/admin/matkul/$id',
          ),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final res = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res['message'] ?? 'Berhasil dihapus')),
          );
          setState(() {
            matkulList.removeAt(index);
          });
        } else {
          final err = jsonDecode(response.body);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal: ${err['message']}')));
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
      }
    }
  }

  Future<void> _fetchPengajarMap() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final res = await http.get(
        Uri.parse('http://192.168.18.13:8080/api/admin/dosen'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final List data = json['data'];
        setState(() {
          pengajarMap = {for (var d in data) d['id']: d['nama']};
        });
      }
    } catch (e) {
      print('Error fetch pengajar: $e');
    }
  }

  Future<void> _fetchMatkulList() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final res = await http.get(
        Uri.parse('http://192.168.18.13:8080/api/admin/matkul'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        setState(() {
          matkulList = List<Map<String, dynamic>>.from(json['data']);
        });
      } else {
        print('Gagal load matkul: ${res.body}');
      }
    } catch (e) {
      print('Error matkul: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalData = matkulList.length;
    final int totalPages = (totalData / rowsPerPage).ceil();
    final int start = (currentPage - 1) * rowsPerPage;
    final int end = (start + rowsPerPage).clamp(0, totalData);
    final currentMatkul = matkulList.sublist(start, end);

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
            Icon(Icons.menu_book_rounded, color: Colors.deepPurple, size: 22),
            SizedBox(width: 8),
            Text(
              'Daftar Mata Kuliah',
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

      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
          columnSpacing: 20,
          border: TableBorder.all(color: Colors.grey.shade300),
          columns: const [
            DataColumn(
              label: Text('No', textAlign: TextAlign.center),
              numeric: true,
            ),
            DataColumn(label: Text('Kode')),
            DataColumn(label: Text('Nama')),
            DataColumn(label: Text('Pengajar')),
            DataColumn(label: Text('Jumlah SKS')),
            DataColumn(label: Text('Aksi')),
          ],
          rows:
              currentMatkul.asMap().entries.map((entry) {
                int index = entry.key;
                var matkul = entry.value;
                int number = start + index + 1;
                String pengajarNama = pengajarMap[matkul['pengajar_id']] ?? '-';

                return DataRow(
                  cells: [
                    DataCell(Center(child: Text(number.toString()))),
                    DataCell(Text(matkul['kode_matkul'])),
                    DataCell(Text(matkul['nama_matkul'])),
                    DataCell(Text(pengajarNama)),
                    DataCell(Text(matkul['jml_sks'])),

                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          EditMataKuliahPage(matkul: matkul),
                                ),
                              );
                              if (result == true) {
                                _fetchMatkulList(); // Refresh setelah edit
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed:
                                () => hapusMatkul(
                                  context,
                                  start + index,
                                  matkul['id'],
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),

      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (matkulList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Tampilkan:'),
                  const SizedBox(width: 8),
                  DropdownButton<int>(
                    value: rowsPerPage,
                    onChanged: (value) {
                      setState(() {
                        rowsPerPage = value!;
                        currentPage = 1;
                      });
                    },
                    items:
                        rowsPerPageOptions.map((val) {
                          return DropdownMenuItem(
                            value: val,
                            child: Text('$val'),
                          );
                        }).toList(),
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
          CustomBottomNavBar(currentIndex: 3, context: context),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TambahMataKuliahPage(),
            ),
          ).then((_) => _fetchMatkulList()); // Refresh setelah tambah
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}
