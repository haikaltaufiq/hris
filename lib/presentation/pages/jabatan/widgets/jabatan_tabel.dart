import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme.dart';
import 'package:hr/data/models/jabatan_model.dart';

class JabatanTabel extends StatelessWidget {
  final List<JabatanModel> jabatanList;
  final Function(JabatanModel) onEdit;
  final Function(int) onDelete;

  const JabatanTabel({
    super.key,
    required this.jabatanList,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.02,
        vertical: MediaQuery.of(context).size.height * 0.01,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(56, 5, 5, 5),
              blurRadius: 5,
              offset: Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'Nama Jabatan', // No ID absen
                        style: TextStyle(
                            color: AppColors.putih,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            fontFamily: GoogleFonts.poppins().fontFamily),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Text(
                    'Aksi', // No ID absen
                    style: TextStyle(
                        color: AppColors.putih,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: GoogleFonts.poppins().fontFamily),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.center,
              child: FractionallySizedBox(
                widthFactor: 1.09, // lebih dari 1 = lebar penuh + lebih
                child: Divider(
                  color: AppColors.secondary,
                  thickness: 1,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // supaya ikut scroll luar
              itemCount: jabatanList.length,
              separatorBuilder: (_, __) =>
                  Divider(color: AppColors.secondary, thickness: 1),
              itemBuilder: (context, index) {
                final jabatan = jabatanList[index];
                return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            jabatan.namaJabatan,
                            style: TextStyle(
                              color: AppColors.putih,
                              fontWeight: FontWeight.w400,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    onDelete(jabatan.id);
                                  },
                                  child: FaIcon(
                                    FontAwesomeIcons.trash,
                                    color: AppColors.putih,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 15), // jarak antar ikon
                                GestureDetector(
                                  onTap: () {
                                    onEdit(jabatan);
                                  },
                                  child: FaIcon(
                                    FontAwesomeIcons.pen,
                                    color: AppColors.putih,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
