import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

class TambahJurusanPage extends StatefulWidget {
  const TambahJurusanPage({super.key});

  @override
  State<TambahJurusanPage> createState() => _TambahJurusanPageState();
}

class _TambahJurusanPageState extends State<TambahJurusanPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaJurusanController = TextEditingController();

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // ✅ API yang benar
      final uri = Uri.parse(
        'http://192.168.18.13:8080/api/admin/tambah-jurusan',
      );

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'nama_jurusan': _namaJurusanController.text.trim()}),
      );

      // ✅ Cek status 201 (Created)
      if (response.statusCode == 201) {
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
                        data['message'] ?? 'Jurusan berhasil ditambahkan',
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
          Navigator.pop(context); // Close dialog
          Navigator.pop(context); // Back to previous page
        }
      } else {
        print('Gagal tambah jurusan: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambahkan jurusan')),
        );
      }
    }
  }

  @override
  void dispose() {
    _namaJurusanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Jurusan'),
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
              const Text(
                'Form Tambah Jurusan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _namaJurusanController,
                decoration: const InputDecoration(
                  labelText: 'Nama Jurusan',
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
                label: const Text(
                  'Simpan Jurusan',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
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
