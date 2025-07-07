import 'package:belajar_app/pagesAdmin/CustomBottomNavBar.dart';
import 'package:belajar_app/pagesAdmin/PelajarPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TambahPelajarPage extends StatefulWidget {
  const TambahPelajarPage({super.key});

  @override
  State<TambahPelajarPage> createState() => _TambahPelajarPageState();
}

class _TambahPelajarPageState extends State<TambahPelajarPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nimController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password_confirmationController = TextEditingController();
  String? _selectedJurusan;
  int? _selectedKelasId;
  String _gender = 'Laki-laki';

  List<Map<String, dynamic>> _kelasList = [];

  List<Map<String, dynamic>> jurusanList = [];

  int? _mapJurusanToId(String? namaJurusan) {
    final jurusan = jurusanList.firstWhere(
      (item) => item['nama_jurusan'] == namaJurusan,
      orElse: () => {},
    );
    return jurusan['id'];
  }

  @override
  void initState() {
    super.initState();
    _fetchKelasAndNip();
    fetchJurusan();
  }

  Future<void> fetchJurusan() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final uri = Uri.parse('http://192.168.18.13:8080/api/admin/showJurusan');
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
      final List<dynamic> jurusanData = data['data'];
      setState(() {
        jurusanList = jurusanData.cast<Map<String, dynamic>>();
      });
    }
  }

  Future<void> _fetchKelasAndNip() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final uri = Uri.parse('http://192.168.18.13:8080/api/kelas');
    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final kelasData = List<Map<String, dynamic>>.from(data['data']);
      final nextNip = data['next_nim_nip'];

      setState(() {
        _kelasList = kelasData;
        _nimController.text = nextNip;
      });
    }
  }

  void _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final uri = Uri.parse(
        'http://192.168.18.13:8080/api/admin/tambah-mahasiswa',
      );

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nama': _namaController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'password_confirmation':
              _password_confirmationController
                  .text, // Dikirim sebagai konfirmasi
          'nim': _nimController.text.trim(),
          'jurusan_id': _mapJurusanToId(_selectedJurusan),
          'jenis_kelamin': _gender,

          'kelas_id': _selectedKelasId,
        }),
      );

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
                        data['message'] ?? 'Berhasil menambahkan pelajar!',
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

        Navigator.of(context).pop(); // tutup dialog
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PelajarPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
              'Tambah Pelajar',
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
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                'Nama Lengkap',
                _namaController,
                'Masukkan nama lengkap',
              ),

              // ✅ Tampilan khusus untuk NIM / ID Mahasiswa
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NIM / ID Mahasiswa',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Text(
                        _nimController.text,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),

              _buildTextField(
                'Email',
                _emailController,
                'Masukkan email',
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                'Password',
                _passwordController,
                'Masukkan password',
                obscureText: true,
              ),
              _buildTextField(
                'Konfirmasi Password',
                _password_confirmationController,
                'Masukkan konfirmasi password',
                obscureText: true,
              ),
              const Text(
                'Jenis Kelamin',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                hint: const Text('Pilih Jenis Kelamin'),
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
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Jenis kelamin wajib dipilih'
                            : null,
              ),
              const SizedBox(height: 16),

              _buildDropdownField(
                'Jurusan',
                _selectedJurusan,
                jurusanList.map((e) => e['nama_jurusan'].toString()).toList(),
                (val) => setState(() => _selectedJurusan = val),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kelas',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<int>(
                      value: _selectedKelasId,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      hint: const Text('Pilih Kelas'),
                      items:
                          _kelasList.map((kelas) {
                            return DropdownMenuItem<int>(
                              value: kelas['id'],
                              child: Text(kelas['nama_kelas']),
                            );
                          }).toList(),
                      onChanged:
                          (val) => setState(() => _selectedKelasId = val),
                      validator:
                          (val) => val == null ? 'Kelas harus dipilih.' : null,
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size.fromHeight(48),
                ),
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  'Simpan',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        context: context,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true, // ← tambahkan ini
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            enabled: enabled, // ← gunakan ini
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator:
                (value) =>
                    (enabled && (value == null || value.isEmpty))
                        ? '$label tidak boleh kosong.'
                        : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String? selectedValue,
    List<String> options,
    void Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: selectedValue,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            hint: Text('Pilih $label'),
            items:
                options
                    .map(
                      (val) => DropdownMenuItem(value: val, child: Text(val)),
                    )
                    .toList(),
            onChanged: onChanged,
            validator:
                (value) => value == null ? '$label harus dipilih.' : null,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nimController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
