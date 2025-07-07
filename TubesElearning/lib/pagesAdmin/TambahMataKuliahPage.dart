import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TambahMataKuliahPage extends StatefulWidget {
  const TambahMataKuliahPage({super.key});

  @override
  State<TambahMataKuliahPage> createState() => _TambahMataKuliahPageState();
}

class _TambahMataKuliahPageState extends State<TambahMataKuliahPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _kodeController = TextEditingController();

  String? selectedSKS;
  String? selectedSemester;
  String? selectedPengajar;

  Map<String, int> pengajarMap = {}; // Diisi dari API

  final List<String> sksOptions = ['1', '2', '3', '4', '6'];
  final List<String> semesterOptions = ['1', '2', '3', '4', '5', '6', '7', '8'];

  @override
  void dispose() {
    _namaController.dispose();
    _kodeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getGeneratedKodeMatkul();
    _fetchPengajarList();
  }

  Future<void> _getGeneratedKodeMatkul() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final uri = Uri.parse(
      'http://192.168.18.13:8080/api/admin/admin/generate-kode-matkul',
    );

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
        final json = jsonDecode(response.body);
        setState(() {
          _kodeController.text = json['kode_matkul'];
        });
      } else {
        print('Gagal mendapatkan kode matkul: ${response.body}');
      }
    } catch (e) {
      print('Error saat ambil kode matkul: $e');
    }
  }

  Future<void> _fetchPengajarList() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final uri = Uri.parse('http://192.168.18.13:8080/api/admin/dosen');

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
        final json = jsonDecode(response.body);
        final List<dynamic> dosenData = json['data'];

        final Map<String, int> loadedMap = {
          for (var item in dosenData) item['nama']: item['id'],
        };

        setState(() {
          pengajarMap = loadedMap;
        });
      } else {
        print('Gagal fetch dosen: ${response.body}');
      }
    } catch (e) {
      print('Error saat fetch dosen: $e');
    }
  }

  Future<void> _submitMatkul() async {
    if (_formKey.currentState!.validate()) {
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

      final uri = Uri.parse(
        'http://192.168.18.13:8080/api/admin/tambah-matakul',
      );

      try {
        final response = await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'nama_matkul': _namaController.text.trim(),
            'kode_matkul': _kodeController.text.trim(),
            'jml_sks': selectedSKS,
            'semester': int.parse(selectedSemester!),
            'pengajar_id': pengajarMap[selectedPengajar],
          }),
        );

        if (response.statusCode == 201) {
          final json = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(json['message'] ?? 'Berhasil menambahkan matkul'),
            ),
          );
          Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Tambah Mata Kuliah'),
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
                'Form Tambah Mata Kuliah',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Mata Kuliah',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _kodeController,
                decoration: const InputDecoration(
                  labelText: 'Kode Matkul (Otomatis)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
                validator:
                    (value) =>
                        (value == null || value.isEmpty) ? 'Wajib diisi' : null,
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
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text('$value SKS'),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => selectedSKS = value),
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
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text('Semester $value'),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => selectedSemester = value),
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
                          (pengajar) => DropdownMenuItem(
                            value: pengajar,
                            child: Text(pengajar),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => selectedPengajar = value),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _submitMatkul,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  'Simpan Mata Kuliah',
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
