import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

class EditJurusanPage extends StatefulWidget {
  final int jurusanId;
  final String initialNamaJurusan;

  const EditJurusanPage({
    super.key,
    required this.jurusanId,
    required this.initialNamaJurusan,
  });

  @override
  State<EditJurusanPage> createState() => _EditJurusanPageState();
}

class _EditJurusanPageState extends State<EditJurusanPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaJurusanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _namaJurusanController.text = widget.initialNamaJurusan;
  }

  Future<void> _submitUpdate() async {
    if (_formKey.currentState?.validate() ?? false) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final uri = Uri.parse(
        'http://192.168.18.13:8080/api/admin/admin/jurusan/${widget.jurusanId}',
      );

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'nama_jurusan': _namaJurusanController.text.trim()}),
      );

      if (response.statusCode == 200) {
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
                        data['message'] ?? 'Jurusan berhasil diperbarui',
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
          Navigator.pop(context); // tutup dialog
          Navigator.pop(context); // kembali ke halaman sebelumnya
        }
      } else {
        print('Gagal update jurusan: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui jurusan')),
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
        title: const Text('Edit Jurusan'),
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
                'Form Edit Jurusan',
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
                onPressed: _submitUpdate,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  'Update Jurusan',
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
