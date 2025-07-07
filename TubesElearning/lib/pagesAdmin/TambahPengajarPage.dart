import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TambahPengajarPage extends StatefulWidget {
  const TambahPengajarPage({super.key});

  @override
  State<TambahPengajarPage> createState() => _TambahPengajarPageState();
}

class _TambahPengajarPageState extends State<TambahPengajarPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nipController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  String _gender = 'Laki-laki';

  List<String> _selectedMatkul = [];

  @override
  void initState() {
    super.initState();
    fetchNipDosen();
  }

  Future<void> fetchNipDosen() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final uri = Uri.parse(
      'http://192.168.18.13:8080/api/admin/generate-nim-nip/dosen',
    );

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
        setState(() {
          _nipController.text = data['nim_nip'] ?? '';
        });
      } else {
        print('Gagal fetch NIP: ${response.body}');
      }
    } catch (e) {
      print('Error mengambil NIP otomatis: $e');
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = Uri.parse('http://192.168.18.13:8080/api/admin/tambah-dosen');

      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'nama': _namaController.text.trim(),
            'nip': _nipController.text.trim(),
            'email': _emailController.text.trim(),
            'password': _passwordController.text,
            'password_confirmation': _passwordConfirmationController.text,
            'jenis_kelamin': _gender,
          }),
        );

        if (response.statusCode == 201) {
          final data = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Berhasil menambahkan pengajar'),
            ),
          );
          Navigator.pop(context);
        } else {
          final error = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal: ${error['message'] ?? 'Terjadi kesalahan'}',
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nipController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Tambah Pengajar'),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Formulir Data Pengajar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Pengajar',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Nama wajib diisi'
                            : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nipController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'NIP (Otomatis)',
                  border: OutlineInputBorder(),
                ),

                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'NIP wajib diisi'
                            : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email wajib diisi';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator:
                    (value) =>
                        (value == null || value.length < 6)
                            ? 'Password minimal 6 karakter'
                            : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordConfirmationController,
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator:
                    (value) =>
                        (value == null || value.length < 6)
                            ? 'Password minimal 6 karakter'
                            : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(
                  labelText: 'Jenis Kelamin',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Laki-laki',
                    child: Text('Laki-laki'),
                  ),
                  DropdownMenuItem(
                    value: 'Perempuan',
                    child: Text('Perempuan'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
              ),

              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  'Simpan Pengajar',
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
