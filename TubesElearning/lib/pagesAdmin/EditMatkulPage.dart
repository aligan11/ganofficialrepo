import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditMataKuliahPage extends StatefulWidget {
  final Map<String, dynamic> matkul;

  const EditMataKuliahPage({super.key, required this.matkul});

  @override
  State<EditMataKuliahPage> createState() => _EditMataKuliahPageState();
}

class _EditMataKuliahPageState extends State<EditMataKuliahPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _kodeController = TextEditingController();

  String? selectedSKS;
  String? selectedSemester;
  String? selectedPengajar;

  Map<String, int> pengajarMap = {}; // nama → id

  final List<String> sksOptions = ['1', '2', '3', '4', '6'];
  final List<String> semesterOptions = ['1', '2', '3', '4', '5', '6', '7', '8'];

  @override
  void initState() {
    super.initState();
    _fetchPengajarList();

    _namaController.text = widget.matkul['nama_matkul'] ?? '';
    _kodeController.text = widget.matkul['kode_matkul'] ?? '';
    selectedSKS = widget.matkul['jml_sks'].toString();
    selectedSemester = widget.matkul['semester'].toString();
  }

  Future<void> _fetchPengajarList() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final res = await http.get(
        Uri.parse('http://192.168.18.13:8080/api/admin/dosen'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List<dynamic> dosen = data['data'];
        final Map<String, int> loadedMap = {
          for (var item in dosen) item['nama']: item['id'],
        };

        setState(() {
          pengajarMap = loadedMap;

          // preselect pengajar berdasarkan ID
          selectedPengajar =
              loadedMap.entries
                  .firstWhere(
                    (e) => e.value == widget.matkul['pengajar_id'],
                    orElse: () => const MapEntry('', 0),
                  )
                  .key;
        });
      }
    } catch (e) {
      print('Error fetch pengajar: $e');
    }
  }

  Future<void> _updateMatkul() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedSKS == null ||
        selectedSemester == null ||
        selectedPengajar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua pilihan.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final id = widget.matkul['id'];
    final uri = Uri.parse(
      'http://192.168.18.13:8080/api/admin/admin/matkul/$id',
    );

    try {
      final response = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'nama_matkul': _namaController.text.trim(),
          'kode_matkul': _kodeController.text.trim(),
          'jml_sks': int.parse(selectedSKS!),
          'semester': int.parse(selectedSemester!),
          'pengajar_id': pengajarMap[selectedPengajar],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Berhasil memperbarui data'),
          ),
        );
        Navigator.pop(context, true); // untuk refresh list
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Edit Mata Kuliah'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Form Edit Mata Kuliah',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Mata Kuliah',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _kodeController,
                decoration: const InputDecoration(
                  labelText: 'Kode Matkul',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Jumlah SKS',
                  border: OutlineInputBorder(),
                ),
                value: selectedSKS,
                items:
                    sksOptions
                        .map(
                          (v) =>
                              DropdownMenuItem(value: v, child: Text('$v SKS')),
                        )
                        .toList(),
                onChanged: (val) => setState(() => selectedSKS = val),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Semester',
                  border: OutlineInputBorder(),
                ),
                value: selectedSemester,
                items:
                    semesterOptions
                        .map(
                          (v) => DropdownMenuItem(
                            value: v,
                            child: Text('Semester $v'),
                          ),
                        )
                        .toList(),
                onChanged: (val) => setState(() => selectedSemester = val),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Pilih Pengajar',
                  border: OutlineInputBorder(),
                ),
                value: selectedPengajar,
                items:
                    pengajarMap.keys
                        .map(
                          (nama) =>
                              DropdownMenuItem(value: nama, child: Text(nama)),
                        )
                        .toList(),
                onChanged: (val) => setState(() => selectedPengajar = val),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _updateMatkul,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  'Simpan Perubahan',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
