import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:intl/intl.dart'; // untuk format tanggal

class ExcelExport extends StatefulWidget {
  const ExcelExport({super.key});

  @override
  State<ExcelExport> createState() => _ExcelExportState();
}

class _ExcelExportState extends State<ExcelExport> {
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _pickDate({required bool isStart}) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF1F1F1F),
              onPrimary: Colors.white,
              onSurface: AppColors.hitam,
              secondary: AppColors.yellow,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.hitam,
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

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "dd/mm/yyyy";
    return DateFormat("dd/MM/yyyy").format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.02,
        vertical: MediaQuery.of(context).size.height * 0.0051,
      ),
      child: Row(
        children: [
          // Start Date
          Expanded(
            child: _buildDateCard(
              title: 'Start Date',
              subtitle: _formatDate(_startDate),
              icon: FontAwesomeIcons.calendar,
              onPressed: () => _pickDate(isStart: true),
            ),
          ),
          const SizedBox(width: 8),

          // End Date
          Expanded(
            child: _buildDateCard(
              title: 'End Date',
              subtitle: _formatDate(_endDate),
              icon: FontAwesomeIcons.calendar,
              onPressed: () => _pickDate(isStart: false),
            ),
          ),
          const SizedBox(width: 8),

          // Download Button
          SizedBox(
            width: 48,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (_startDate != null && _endDate != null) {
                  // TODO: export Excel pake startDate & endDate
                  print("Export dari ${_formatDate(_startDate)} "
                      "sampai ${_formatDate(_endDate)}");
                } else {
                  NotificationHelper.showTopNotification(
                      context, "Pilih start & end date dulu",
                      isSuccess: false);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: FaIcon(
                FontAwesomeIcons.download,
                size: 20,
                color: AppColors.putih,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard({
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
        minimumSize: Size(
          double.infinity,
          context.isMobile ? 48 : 58,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.putih,
                  fontSize: 12,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.putih,
                  fontSize: 10,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),

          // Icon
          FaIcon(icon, color: AppColors.putih, size: 20),
        ],
      ),
    );
  }
}
