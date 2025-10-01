// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/utils/device_size.dart';
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
      gajiPokok = userData['gaji_per_hari'] as double?;
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
              if (context.isMobile)
                Align(
                    alignment: AlignmentGeometry.centerLeft,
                    child: Header(title: "Profile")),
              const SizedBox(height: 20),
              if (isLoading)
                const Center(child: LoadingWidget())
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
    if (context.isMobile) {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.8),
                    AppColors.primary
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                    color: AppColors.putih.withOpacity(0.4), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05), // tipis banget
                    blurRadius: 4, // kecil, biar soft
                    spreadRadius: 0,
                    offset: Offset(0, 1), // cuma bawah dikit
                  ),
                ],
              ),
              child: ClipOval(
                child: nama != null && nama!.isNotEmpty
                    ? Center(
                        child: Text(
                          nama!.substring(0, 1).toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 30,
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
            Text(
              peran ?? '-',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.putih.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.8),
                    AppColors.primary
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                    color: AppColors.putih.withOpacity(0.4), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05), // tipis banget
                    blurRadius: 4, // kecil, biar soft
                    spreadRadius: 0,
                    offset: Offset(0, 1), // cuma bawah dikit
                  ),
                ],
              ),
              child: ClipOval(
                child: nama != null && nama!.isNotEmpty
                    ? Center(
                        child: Text(
                          nama!.substring(0, 1).toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 30,
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
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
          ],
        ),
      );
    }
  }

  Widget _buildInfoSection() {
    final infoItems = [
      {
        'icon': FontAwesomeIcons.envelope,
        'label': 'Email',
        'value': email,
        'isEditable': true,
        'editType': 'email',
      },
      {
        'icon': FontAwesomeIcons.key,
        'label': 'Password',
        'value': 'Change Password',
        'isEditable': true,
        'editType': 'password',
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
        'label': 'Gaji Per Hari',
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
    if (context.isMobile) {
      return Column(
        children: infoItems.map((item) => _buildInfoItem(item)).toList(),
      );
    } else {
      // Desktop: dua kolom
      final mid = (infoItems.length / 2).ceil();
      final leftItems = infoItems.sublist(0, mid);
      final rightItems = infoItems.sublist(mid);

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: leftItems.map((item) => _buildInfoItem(item)).toList(),
            ),
          ),
          const SizedBox(width: 40), // jarak antar kolom
          Expanded(
            child: Column(
              children: rightItems.map((item) => _buildInfoItem(item)).toList(),
            ),
          ),
        ],
      );
    }
  }

// helper function biar clean
  Widget _buildInfoItem(Map<String, dynamic> item) {
    final bool isEditable = item['isEditable'] as bool? ?? false;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
                onPressed: () {
                  final type = item['editType'] as String? ?? '';
                  if (type == 'email') {
                    _showEditEmailBottomSheet();
                  } else if (type == 'password') {
                    _showEditPasswordBottomSheet();
                  }
                },
              )
            : null,
      ),
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
                  onPressed: () async {
                    final newEmail = emailController.text.trim();
                    final oldPassword = passwordController.text.trim();

                    if (newEmail.isEmpty || oldPassword.isEmpty) {
                      NotificationHelper.showTopNotification(
                          context, 'Email dan password wajib diisi',
                          isSuccess: false);
                      return;
                    }

                    final result =
                        await _authService.updateEmail(newEmail, oldPassword);

                    if (result['success'] == true) {
                      setState(() {
                        email = result['data']['email'];
                      });
                      Navigator.pop(context);

                      NotificationHelper.showTopNotification(
                        context,
                        result['message'],
                        isSuccess: true,
                      );
                    } else {
                      NotificationHelper.showTopNotification(
                        context,
                        result['message'],
                        isSuccess: false,
                      );
                    }
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

  void _showEditPasswordBottomSheet() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    // definisi state toggle di luar builder
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.primary,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Edit Password',
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.putih)),
                    const SizedBox(height: 16),

                    // Password lama
                    TextField(
                      controller: oldPasswordController,
                      obscureText: obscureOld,
                      decoration: InputDecoration(
                        labelText: 'Password Lama',
                        labelStyle: GoogleFonts.poppins(
                            color: AppColors.putih.withOpacity(0.7)),
                        filled: true,
                        fillColor: AppColors.primary.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureOld
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.putih,
                          ),
                          onPressed: () {
                            setState(() => obscureOld = !obscureOld);
                          },
                        ),
                      ),
                      style: GoogleFonts.poppins(color: AppColors.putih),
                    ),
                    const SizedBox(height: 16),

                    // Password baru
                    TextField(
                      controller: newPasswordController,
                      obscureText: obscureNew,
                      decoration: InputDecoration(
                        labelText: 'Password Baru',
                        labelStyle: GoogleFonts.poppins(
                            color: AppColors.putih.withOpacity(0.7)),
                        filled: true,
                        fillColor: AppColors.primary.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureNew
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.putih,
                          ),
                          onPressed: () {
                            setState(() => obscureNew = !obscureNew);
                          },
                        ),
                      ),
                      style: GoogleFonts.poppins(color: AppColors.putih),
                    ),
                    const SizedBox(height: 16),

                    // Konfirmasi password baru
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi Password Baru',
                        labelStyle: GoogleFonts.poppins(
                            color: AppColors.putih.withOpacity(0.7)),
                        filled: true,
                        fillColor: AppColors.primary.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.putih,
                          ),
                          onPressed: () {
                            setState(() => obscureConfirm = !obscureConfirm);
                          },
                        ),
                      ),
                      style: GoogleFonts.poppins(color: AppColors.putih),
                    ),
                    const SizedBox(height: 24),

                    // Tombol simpan (kode asli tetap sama)...
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
