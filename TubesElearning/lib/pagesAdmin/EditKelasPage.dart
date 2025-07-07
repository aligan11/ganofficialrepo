import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

class EditKelasPage extends StatefulWidget {
  final int? kelasId; // Jika ada, berarti edit
  final String? initialNamaKelas;

  const EditKelasPage({super.key, this.kelasId, this.initialNamaKelas});

  @override
  State<EditKelasPage> createState() => _EditKelasPageState();
}

class _EditKelasPageState extends State<EditKelasPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaKelasController = TextEditingController();

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final isEdit = widget.kelasId != null;
      final url =
          isEdit
              ? 'http://192.168.18.13:8080/api/admin/kelas/${widget.kelasId}'
              : 'http://192.168.18.13:8080/api/tambah-kelas';

      final response =
          await (isEdit
              ? http.put(
                Uri.parse(url),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                  'Authorization': 'Bearer $token',
                },
                body: jsonEncode({
                  'nama_kelas': _namaKelasController.text.trim(),
                }),
              )
              : http.post(
                Uri.parse(url),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                  'Authorization': 'Bearer $token',
                },
                body: jsonEncode({
                  'nama_kelas': _namaKelasController.text.trim(),
                }),
              ));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset(
                        'assets/lottie/success_check.json',
                        width: 120,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        data['message'] ??
                            (isEdit
                                ? 'Kelas berhasil diperbarui'
                                : 'Kelas berhasil ditambahkan'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        );

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context); // Tutup dialog
          Navigator.pop(context); // Kembali ke halaman sebelumnya
        }
      } else {
        print('Gagal submit kelas: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit ? 'Gagal memperbarui kelas' : 'Gagal menambahkan kelas',
            ),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialNamaKelas != null) {
      _namaKelasController.text = widget.initialNamaKelas!;
    }
  }

  @override
  void dispose() {
    _namaKelasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.kelasId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Kelas' : 'Tambah Kelas'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Form Edit Kelas' : 'Form Tambah Kelas',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _namaKelasController,
                decoration: const InputDecoration(
                  labelText: 'Nama Kelas',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save, color: Colors.white),
                label: Text(
                  isEdit ? 'Update Kelas' : 'Simpan Kelas',
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
