import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/core/theme.dart';
import 'package:hr/presentation/pages/absen/absen_form/absen_keluar_page.dart';
import 'package:hr/presentation/pages/absen/absen_form/absen_masuk_page.dart';
import 'package:hr/presentation/pages/absen/widget/absen_excel_export.dart';
import 'package:hr/presentation/pages/absen/widget/absen_tabel.dart';

class AbsenPage extends StatefulWidget {
  const AbsenPage({super.key});

  @override
  State<AbsenPage> createState() => _AbsenPageState();
}

class _AbsenPageState extends State<AbsenPage> {
  final searchController = TextEditingController(); // value awal
  XFile? _lastVideo;


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Header(title: "Attendance Management"),
            SearchingBar(
              controller: searchController,
              onChanged: (value) {
                print("Search Halaman A: $value");
              },
              onFilter1Tap: () => print("Filter1 Halaman A"),
            ),
            AbsenExcelExport(),
            AbsenTabel(lastVideo: _lastVideo),
            AbsenTabel(lastVideo: _lastVideo),
          
           
          ],
        ),

// Floating Action Button
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: AppColors.bg,
                    title: Text(
                      "Pilih Aksi",
                      style: TextStyle(
                        color: AppColors.putih,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(); // tutup dialog dulu
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AbsenMasukPage(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.login,
                            color: Colors.white,
                          ),
                          label: Text("Clock In",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily:
                                      GoogleFonts.poppins().fontFamily)),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.red,
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(); // tutup dialog dulu
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const AbsenKeluarPage(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.logout,
                              color: Colors.white,
                            ),
                            label: Text("Clock Out",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily:
                                        GoogleFonts.poppins().fontFamily))),
                      ],
                    ),
                  );
                },
              );
            },
            backgroundColor: AppColors.secondary,
            shape: const CircleBorder(),
            child: FaIcon(FontAwesomeIcons.plus, color: AppColors.putih),
          ),
        ),
      ],
    );
  }
}
