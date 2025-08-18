import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme.dart';

class PengaturanTheme extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const PengaturanTheme({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
  });

  @override
  State<PengaturanTheme> createState() => _PengaturanThemeState();
}

class _PengaturanThemeState extends State<PengaturanTheme> {
  late bool isSwitched;

  @override
  void initState() {
    super.initState();
    isSwitched = widget.isDarkMode;
  }

  @override
  void didUpdateWidget(covariant PengaturanTheme oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkMode != widget.isDarkMode) {
      setState(() {
        isSwitched = widget.isDarkMode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          'Atur Tema',
          style: TextStyle(
            color: AppColors.putih,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.poppins().fontFamily,
          ),
        ),
        backgroundColor: AppColors.bg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: AppColors.putih,
          onPressed: () =>
              Navigator.of(context).pop(isSwitched), // kirim balik nilai switch
        ),
        iconTheme: IconThemeData(color: AppColors.putih),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(
              'Dark Mode',
              style: TextStyle(color: AppColors.putih),
            ),
            value: isSwitched,
            onChanged: (value) {
              setState(() {
                isSwitched = value;
              });
              widget.toggleTheme();
            },
            activeColor: Colors.blue,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}
