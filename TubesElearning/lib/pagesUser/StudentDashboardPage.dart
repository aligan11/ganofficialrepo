import 'package:flutter/material.dart';

class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 4, 100),
        elevation: 0,
        title: Row(
          children: const [
            Icon(Icons.school, color: Colors.white, size: 20),
            SizedBox(width: 6),
            Text(
              'EduSantaii',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        actions: [
          Row(
            children: [
              const Text(
                'John Doe',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                offset: const Offset(
                  0,
                  40,
                ), // Atur posisi dropdown agar agak ke bawah
                onSelected: (value) {
                  if (value == 'profile') {
                    Navigator.pushNamed(context, '/profile');
                  } else if (value == 'logout') {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text("Konfirmasi Logout"),
                            content: const Text(
                              "Apakah Anda yakin ingin logout?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Batal"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  // Tambahkan logika logout di sini
                                },
                                child: const Text("Logout"),
                              ),
                            ],
                          ),
                    );
                  }
                },
                itemBuilder:
                    (context) => const [
                      PopupMenuItem(
                        value: 'profile',
                        child: Text('View Profile'),
                      ),
                      PopupMenuItem(value: 'logout', child: Text('Logout')),
                    ],
                child: const CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(
                    'https://storage.googleapis.com/a1aa/image/3516d329-ec16-454c-11eb-d8e6ba418161.jpg',
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          _highlightBanner(),
          const SizedBox(height: 16),

          const Text(
            'Tugas Terbaru',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _taskCard(
            subject: 'Matematika',
            status: 'Belum',
            title: 'Aljabar Persamaan Kuadrat',
            deadline: '25 Juni 2024, 23:59',
            statusColor: Colors.orange,
          ),
          _taskCard(
            subject: 'Bahasa Inggris',
            status: 'Terkumpul',
            title: 'Essay Pengalaman Liburan',
            deadline: '27 Juni 2024, 23:59',
            statusColor: Colors.green,
          ),
          const SizedBox(height: 24),
          const Text(
            'Mata Kuliah Aktif',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _courseCard(
                imgUrl:
                    'https://storage.googleapis.com/a1aa/image/86b97d39-ded9-4fed-2f42-77a10d665c3f.jpg',
                title: 'Matematika',
                teacher: 'Budi Santoso',
                tasks: 5,
                sessions: 12,
              ),
              _courseCard(
                imgUrl:
                    'https://storage.googleapis.com/a1aa/image/4f70a1ae-7c6c-4265-f84c-fb7e26492daa.jpg',
                title: 'Bahasa Inggris',
                teacher: 'Siti Aminah',
                tasks: 3,
                sessions: 10,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _infoSection(), // <-- Ditambahkan di sini
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Tetap (tidak shifting)
        backgroundColor: Colors.white,
        currentIndex: 0,
        selectedItemColor: Color(
          0xFFF9A93B,
        ), // Warna utama (matching highlight)
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        showUnselectedLabels: true,
        elevation: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt_rounded),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          // Aksi saat tab ditekan (opsional)
          // Navigator.pushNamed(context, routeList[index]);
        },
      ),
    );
  }

  Widget _taskCard({
    required String subject,
    required String title,
    required String deadline,
    required String status,
    required Color statusColor,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subject,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.orange, size: 16),
                const SizedBox(width: 6),
                Text(
                  "Deadline: $deadline",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onPressed: () {},
              child: const Text(
                'Lihat Detail',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _courseCard({
    required String imgUrl,
    required String title,
    required String teacher,
    required int tasks,
    required int sessions,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imgUrl,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          Text(
            "Dosen: $teacher",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const Spacer(),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '📝 $tasks',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '📚 $sessions',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _highlightBanner() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF9B94B), Color(0xFFF9A93B)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Ini jaga bagian atas sejajar
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'E-Learning',
                    style: TextStyle(
                      color: Color(0xFFF9B94B),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Kumpulkan Tugasmu Sekarang!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Cek deadline dan upload file tugasmu tepat waktu di sini.',
                  style: TextStyle(color: Color(0xFFFFF8DC), fontSize: 12),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    // Navigator.pushNamed(context, '/tugasPage');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xFFF9B94B),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    'Lihat Tugas',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/kartun2.png',
                width: 100,
                height: 165,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoSection() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline, color: Colors.blue, size: 16),
              SizedBox(width: 6),
              Text(
                'Keterangan Informasi',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000245),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Padding(
                padding: EdgeInsets.only(left: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📝 ', style: TextStyle(fontSize: 12)),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'Jumlah Tugas – ',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  'Tugas yang aktif dan harus diselesaikan pada mata kuliah tersebut.',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6),
              Padding(
                padding: EdgeInsets.only(left: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📚 ', style: TextStyle(fontSize: 12)),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'Jumlah Pertemuan – ',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  'Total sesi kelas atau pertemuan yang dijadwalkan.',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
