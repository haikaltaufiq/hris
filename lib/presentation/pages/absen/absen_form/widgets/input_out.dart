import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/custom_dropdown.dart';
import 'package:hr/components/timepicker/time_picker.dart';
import 'package:hr/core/theme.dart';
import 'package:hr/components/custom/custom_input.dart';

class InputOut extends StatefulWidget {
  const InputOut({super.key});

  @override
  State<InputOut> createState() => _InputOutState();
}

class _InputOutState extends State<InputOut> {
  final TextEditingController _tanggalController = TextEditingController();

  final TextEditingController _jamSelesaiController = TextEditingController();
  int _selectedMinute = 0;
  int _selectedHour = 0;

  void _onTapIcon(TextEditingController controller) async {
    showModalBottomSheet(
      backgroundColor: AppColors.primary,
      useRootNavigator: true,
      context: context,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  ListTile(
                    title: Center(
                      child: Column(
                        children: [
                          Container(
                            height: 3,
                            width: 40,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Pilih Waktu',
                            style: TextStyle(
                              color: AppColors.putih,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Jam',
                            style: TextStyle(
                              color: AppColors.putih,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  NumberPickerWidget(
                    hour: _selectedHour,
                    minute: _selectedMinute,
                    onHourChanged: (value) {
                      setModalState(() {
                        _selectedHour = value;
                      });
                    },
                    onMinuteChanged: (value) {
                      setModalState(() {
                        _selectedMinute = value;
                      });
                    },
                  ),
                  FloatingActionButton.extended(
                    backgroundColor: AppColors.secondary,
                    onPressed: () {
                      // Format waktu menjadi HH:mm
                      final formattedHour =
                          _selectedHour.toString().padLeft(2, '0');
                      final formattedMinute =
                          _selectedMinute.toString().padLeft(2, '0');
                      final formattedTime = "$formattedHour:$formattedMinute";

                      // Simpan ke text field controller
                      controller.text = formattedTime;

                      Navigator.pop(context);
                    },
                    label: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        'Save',
                        style: TextStyle(
                          fontFamily: GoogleFonts.poppins().fontFamily,
                          color: AppColors.putih,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _tanggalController.dispose();
    _jamSelesaiController.dispose();
    super.dispose();
  }

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

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05,
        vertical: MediaQuery.of(context).size.height * 0.01,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomInputField(
            label: "Nama",
            hint: "",
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),
          CustomInputField(
            label: "Tanggal",
            hint: "dd / mm / yyyy",
            controller: _tanggalController,
            suffixIcon: Icon(Icons.calendar_today, color: AppColors.putih),
            onTapIcon: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Color(0xFF1F1F1F), // Header & selected date
                        onPrimary: Colors.white, // Teks tanggal terpilih
                        onSurface: AppColors.hitam, // Teks hari/bulan
                        secondary:
                            AppColors.yellow, // Hari yang di-hover / highlight
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.hitam, // Tombol CANCEL/OK
                        ),
                      ),
                      textTheme: GoogleFonts.poppinsTextTheme(
                        Theme.of(context).textTheme.apply(
                              bodyColor: AppColors.hitam,
                              displayColor: AppColors.hitam,
                            ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedDate != null && mounted) {
                _tanggalController.text =
                    "${pickedDate.day.toString().padLeft(2, '0')} / ${pickedDate.month.toString().padLeft(2, '0')} / ${pickedDate.year}";
              }
            },
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),
          CustomDropDownField(
            label: 'Tipe Absen',
            hint: '',
            items: ['Hadir', 'Telat', 'Izin'],
            labelStyle: labelStyle,
            textStyle: textStyle,
            dropdownColor: AppColors.secondary,
            dropdownTextColor: AppColors.putih,
            dropdownIconColor: AppColors.putih,
            inputStyle: inputStyle,
          ),
          CustomInputField(
            label: "Jam Keluar",
            hint: "--:--",
            controller: _jamSelesaiController,
            suffixIcon: Icon(Icons.access_time, color: AppColors.putih),
            onTapIcon: () => _onTapIcon(_jamSelesaiController),
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),
          CustomInputField(
            label: "Keterangan",
            hint: "",
            labelStyle: labelStyle,
            textStyle: textStyle,
            inputStyle: inputStyle,
          ),
          const SizedBox(height: 5),
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
        ],
      ),
    );
  }
}
