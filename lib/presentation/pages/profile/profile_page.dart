// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/data/services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();

  // Semua data user
  String? nama;
  String? email;
  String? jenisKelamin;
  String? statusPernikahan;
  String? peran;
  String? departemen;
  String? jabatan;
  double? gajiPokok;
  String? npwp;
  String? bpjsKesehatan;
  String? bpjsKetenagakerjaan;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await _authService.getUserData();

    setState(() {
      nama = userData['nama'] as String?;
      email = userData['email'] as String?;
      jenisKelamin = userData['jenis_kelamin'] as String?;
      statusPernikahan = userData['status_pernikahan'] as String?;
      peran = userData['peran'] as String?;
      departemen = userData['departemen'] as String?;
      jabatan = userData['jabatan'] as String?;
      gajiPokok = userData['gaji_pokok'] as double?;
      npwp = userData['npwp'] as String?;
      bpjsKesehatan = userData['bpjs_kesehatan'] as String?;
      bpjsKetenagakerjaan = userData['bpjs_ketenagakerjaan'] as String?;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Header(title: 'Profile'),
              const SizedBox(height: 20),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  children: [
                    _buildProfileCard(),
                    const SizedBox(height: 24),
                    _buildInfoSection(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1F1C2C), Color(0xFF928DAB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Colors.blueAccent, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: nama != null && nama!.isNotEmpty
                  ? Center(
                      child: Text(
                        nama!.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            nama ?? '-',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            peran ?? '-',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    final infoItems = [
      {'icon': Icons.email, 'label': 'Email', 'value': email},
      {'icon': Icons.business, 'label': 'Departemen', 'value': departemen},
      {'icon': Icons.person_outline, 'label': 'Jenis Kelamin', 'value': jenisKelamin},
      {'icon': Icons.favorite_outline, 'label': 'Status Pernikahan', 'value': statusPernikahan},
      {'icon': Icons.badge, 'label': 'Jabatan', 'value': jabatan},
      {'icon': Icons.monetization_on, 'label': 'Gaji Pokok', 'value': gajiPokok != null ? gajiPokok!.toStringAsFixed(2) : '-'},
      {'icon': Icons.confirmation_num, 'label': 'NPWP', 'value': npwp},
      {'icon': Icons.health_and_safety, 'label': 'BPJS Kesehatan', 'value': bpjsKesehatan},
      {'icon': Icons.account_balance, 'label': 'BPJS Ketenagakerjaan', 'value': bpjsKetenagakerjaan},
    ];

    return Column(
      children: infoItems
          .map(
            (item) => Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                leading: Icon(item['icon'] as IconData, color: Colors.blueAccent),
                title: Text(
                  item['label'] as String,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                subtitle: Text(
                  item['value'] as String? ?? '-',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
