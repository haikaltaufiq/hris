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
          AppColors.isDarkMode = newIsDarkMode;
        });
      }
    }

    menuItems = [
      _MenuItemData(
        title: "Profile",
        icon: FontAwesomeIcons.user,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MainLayout(externalPageIndex: 8),
            ),
          );
        },
      ),
      _MenuItemData(
        title: "Theme",
        icon: FontAwesomeIcons.palette,
        onTap: _openPengaturanTheme,
      ),
      _MenuItemData(
        title: "Privacy",
        icon: FontAwesomeIcons.lock,
        onTap: () {},
      ),
      _MenuItemData(
        title: "About",
        icon: FontAwesomeIcons.info,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MainLayout(externalPageIndex: 9),
            ),
          );
        },
      ),
      _MenuItemData(
        title: "Notifications",
        icon: FontAwesomeIcons.bell,
        onTap: () {},
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Header(title: "Settings"),
        const SizedBox(height: 24),

        // Main Settings Card
        Card(
          color: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: menuItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    _buildMenuItem(
                      title: item.title,
                      icon: item.icon,
                      onTap: item.onTap,
                    ),
                    if (index < menuItems.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Divider(
                          color: AppColors.putih.withOpacity(0.1),
                          thickness: 0.5,
                          height: 1,
                        ),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Logout Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _showLogoutDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FontAwesomeIcons.rightFromBracket,
                  color: AppColors.putih,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Log Out',
                  style: GoogleFonts.poppins(
                    color: AppColors.putih,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        child: Row(
          children: [
            // Icon container
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: FaIcon(
                icon,
                size: 18,
                color: AppColors.putih,
              ),
            ),
            const SizedBox(width: 16),

            // Title
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.putih,
                ),
              ),
            ),

            // Arrow
            FaIcon(
              FontAwesomeIcons.chevronRight,
              size: 14,
              color: AppColors.putih.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Log Out',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: AppColors.putih,
            ),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: GoogleFonts.poppins(
              color: AppColors.putih.withOpacity(0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: AppColors.putih.withOpacity(0.8),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement logout logic
              },
              child: Text(
                'Log Out',
                style: GoogleFonts.poppins(
                  color: Colors.red.shade300,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
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
