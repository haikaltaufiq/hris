import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/core/theme.dart';
import 'package:hr/presentation/pages/pengaturan/widgets/pengaturan_theme.dart';
import 'package:hr/presentation/layouts/main_layout.dart';

class PengaturanPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const PengaturanPage({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
  });

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  late final List<_MenuItemData> menuItems;
  bool isDarkMode = AppColors.isDarkMode;

  late VoidCallback toggleTheme;

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
    toggleTheme = widget.toggleTheme;

    void _openPengaturanTheme() async {
      final bool? newIsDarkMode = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => PengaturanTheme(
            isDarkMode: isDarkMode,
            toggleTheme: toggleTheme,
          ),
        ),
      );

      if (newIsDarkMode != null && newIsDarkMode != isDarkMode) {
        setState(() {
          isDarkMode = newIsDarkMode;
          // Jika ada AppColors.isDarkMode global, update juga di sini
          AppColors.isDarkMode = newIsDarkMode;
        });
      }
    }

    menuItems = [
      _MenuItemData(
          title: "Profil",
          icon: FontAwesomeIcons.user,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MainLayout(externalPageIndex: 8),
              ),
            );
          }),
      _MenuItemData(
        title: "Theme",
        icon: FontAwesomeIcons.streetView,
        onTap: _openPengaturanTheme,
      ),
      _MenuItemData(
          title: "Privasi", icon: FontAwesomeIcons.lock, onTap: () {}),
      _MenuItemData(
          title: "Tentang", icon: FontAwesomeIcons.infoCircle, onTap: () {}),
      _MenuItemData(
          title: "Notifikasi", icon: FontAwesomeIcons.bell, onTap: () {}),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Header(title: "Pengaturan"),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.04,
            vertical: MediaQuery.of(context).size.height * 0.02,
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: menuItems.length,
            separatorBuilder: (context, index) => Divider(
              color: AppColors.putih,
              thickness: 0.5,
            ),
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return _buildMenuItem(
                title: item.title,
                icon: item.icon,
                onTap: item.onTap,
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.04,
          ),
          child: SizedBox(
            child: ElevatedButton(
              onPressed: () {
                // TODO: handle submit
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1F1F1F),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Log Out',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.putih,
              ),
            ),
            FaIcon(icon, size: 16, color: AppColors.putih),
          ],
        ),
      ),
    );
  }
}

class _MenuItemData {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  _MenuItemData({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}
