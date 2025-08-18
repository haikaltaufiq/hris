import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/custom_input.dart';
import 'package:hr/core/theme.dart';
import 'package:hr/presentation/pages/peran_akses/peran_form/widget/check_box.dart';

class PeranInput extends StatefulWidget {
  const PeranInput({super.key});

  @override
  State<PeranInput> createState() => _PeranInputState();
}

class _PeranInputState extends State<PeranInput> {
  final List<String> aksesLabels = [
    "Dashboard",
    "Absensi",
    "Cuti",
    "Lembur",
    "Tugas",
    "Gaji",
    "Karyawan",
    "Department",
    "Jabatan",
    "Peran & Akses",
    "Tentang",
    "Pengaturan",
    "Log Aktivitas"
  ];
  List<bool> isCheckedList = List.generate(13, (_) => false);
  @override
  Widget build(BuildContext context) {
    final inputStyle = InputDecoration(
      hintStyle: TextStyle(color: AppColors.putih),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.grey),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.putih),
      ),
    );

    final labelStyle = GoogleFonts.poppins(
      fontWeight: FontWeight.bold,
      color: AppColors.putih,
      fontSize: 16,
    );

    final textStyle = GoogleFonts.poppins(
      color: AppColors.putih,
      fontSize: 14,
    );
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            CustomInputField(
              label: "Nama Peran",
              hint: "",
              labelStyle: labelStyle,
              textStyle: textStyle,
              inputStyle: inputStyle,
            ),
            Text(
              "Hak Akses",
              style: labelStyle,
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3, // Naikkan sedikit biar tidak gepeng
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: aksesLabels.length,
              itemBuilder: (context, index) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return CheckBoxField(
                      hint: aksesLabels[index],
                      isChecked: isCheckedList[index],
                      onChanged: (val) {
                        setState(() {
                          isCheckedList[index] = val!;
                        });
                      },
                      controller: null,
                      textStyle: textStyle.copyWith(
                        fontSize: constraints.maxWidth < 150
                            ? 12
                            : 14, // font auto kecil kalau sempit
                      ),
                      inputStyle: inputStyle,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
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
                  'Submit',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
