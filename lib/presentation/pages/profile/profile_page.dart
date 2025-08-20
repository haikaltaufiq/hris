// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/core/theme.dart';
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
      backgroundColor: AppColors.bg,
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
                    const SizedBox(height: 8),
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
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary.withOpacity(0.8), AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border:
                  Border.all(color: AppColors.putih.withOpacity(0.4), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: nama != null && nama!.isNotEmpty
                  ? Center(
                      child: Text(
                        nama!.substring(0, 1).toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: AppColors.putih,
                        ),
                      ),
                    )
                  : Icon(
                      FontAwesomeIcons.user,
                      size: 50,
                      color: AppColors.putih,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            nama ?? '-',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.putih,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            peran ?? '-',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.putih.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    final infoItems = [
      {
        'icon': FontAwesomeIcons.envelope,
        'label': 'Email',
        'value': email,
        'isEditable': true
      },
      {
        'icon': FontAwesomeIcons.building,
        'label': 'Departemen',
        'value': departemen
      },
      {
        'icon': FontAwesomeIcons.user,
        'label': 'Jenis Kelamin',
        'value': jenisKelamin
      },
      {
        'icon': FontAwesomeIcons.heart,
        'label': 'Status Pernikahan',
        'value': statusPernikahan
      },
      {'icon': FontAwesomeIcons.idBadge, 'label': 'Jabatan', 'value': jabatan},
      {
        'icon': FontAwesomeIcons.moneyBill,
        'label': 'Gaji Pokok',
        'value': gajiPokok != null ? gajiPokok!.toStringAsFixed(2) : '-'
      },
      {'icon': FontAwesomeIcons.fileInvoice, 'label': 'NPWP', 'value': npwp},
      {
        'icon': FontAwesomeIcons.hospital,
        'label': 'BPJS Kesehatan',
        'value': bpjsKesehatan
      },
      {
        'icon': FontAwesomeIcons.briefcaseMedical,
        'label': 'BPJS Ketenagakerjaan',
        'value': bpjsKetenagakerjaan
      },
    ];

    return Column(
      children: infoItems.map((item) {
        final bool isEditable =
            item['isEditable'] as bool? ?? false; // << cast ke bool
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary,
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
            leading: FaIcon(item['icon'] as IconData, color: AppColors.putih),
            title: Text(
              item['label'] as String,
              style: GoogleFonts.poppins(
                  color: AppColors.putih.withOpacity(0.7), fontSize: 14),
            ),
            subtitle: Text(
              item['value'] as String? ?? '-',
              style: GoogleFonts.poppins(
                color: AppColors.putih,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: isEditable
                ? IconButton(
                    icon: FaIcon(FontAwesomeIcons.pen, color: AppColors.putih),
                    onPressed: () => _showEditEmailBottomSheet(),
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  void _showEditEmailBottomSheet() {
    final emailController = TextEditingController(text: email);
    final passwordController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Email',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.putih),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email Baru',
                  labelStyle: GoogleFonts.poppins(
                      color: AppColors.putih.withOpacity(0.7)),
                  filled: true,
                  fillColor: AppColors.primary.withOpacity(0.2),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
                style: GoogleFonts.poppins(color: AppColors.putih),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password',
                  labelStyle: GoogleFonts.poppins(
                      color: AppColors.putih.withOpacity(0.7)),
                  filled: true,
                  fillColor: AppColors.primary.withOpacity(0.2),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
                style: GoogleFonts.poppins(color: AppColors.putih),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Implement update email logic dengan konfirmasi password
                    Navigator.pop(context);
                  },
                  child: Text('Simpan',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, color: AppColors.putih)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
      backgroundColor: AppColors.primary,
    );
  }
}
