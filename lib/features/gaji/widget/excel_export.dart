import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hr/components/custom/custom_dropdown.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/data/services/gaji_service.dart';

class ExcelExport extends StatefulWidget {
  const ExcelExport({super.key});

  @override
  State<ExcelExport> createState() => _ExcelExportState();
}

class _ExcelExportState extends State<ExcelExport> {
  Map<String, dynamic>? _selectedPeriod;
  List<Map<String, dynamic>> _availablePeriods = [];

  @override
  void initState() {
    super.initState();
    _loadPeriods();
  }

  Future<void> _loadPeriods() async {
    try {
      final periods = await GajiService.getAvailablePeriods();
      setState(() {
        _availablePeriods = periods;
      });
    } catch (e) {
      NotificationHelper.showTopNotification(
        context,
        "Gagal memuat periode: $e",
        isSuccess: false,
      );
    }
  }

  Future<void> _exportExcel() async {
    if (_selectedPeriod == null) {
      NotificationHelper.showTopNotification(
        context,
        "Pilih periode terlebih dahulu",
        isSuccess: false,
      );
      return;
    }

    try {
      await GajiService.exportGaji(
        bulan: _selectedPeriod!["bulan"],
        tahun: _selectedPeriod!["tahun"],
      );

      NotificationHelper.showTopNotification(
        context,
        kIsWeb
            ? "Export berhasil! File otomatis di-download."
            : "Export berhasil! File tersimpan di penyimpanan.",
        isSuccess: true,
      );
    } catch (e) {
      NotificationHelper.showTopNotification(
        context,
        "Export gagal: $e",
        isSuccess: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> _months = context.isIndonesian
        ? [
            "Januari",
            "Februari",
            "Maret",
            "April",
            "Mei",
            "Juni",
            "Juli",
            "Agustus",
            "September",
            "Oktober",
            "November",
            "Desember"
          ]
        : [
            "January",
            "February",
            "March",
            "April",
            "May",
            "June",
            "July",
            "August",
            "September",
            "October",
            "November",
            "December"
          ];

    return Card(
      color: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                context.isIndonesian
                    ? "Export Gaji (Excel)"
                    : "Export Payroll (Excell)",
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.putih,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CustomDropDownField(
                    label: context.isIndonesian ? "Periode" : "Period",
                    hint: context.isIndonesian
                        ? "Pilih Periode"
                        : "Select Period",
                    items: _availablePeriods
                        .map((p) => "${_months[p["bulan"] - 1]} ${p["tahun"]}")
                        .toList(),
                    value: _selectedPeriod != null
                        ? "${_months[_selectedPeriod!["bulan"] - 1]} ${_selectedPeriod!["tahun"]}"
                        : null,
                    onChanged: (val) {
                      setState(() {
                        _selectedPeriod = _availablePeriods.firstWhere(
                          (p) =>
                              "${_months[p["bulan"] - 1]} ${p["tahun"]}" == val,
                        );
                      });
                    },
                    labelStyle: TextStyle(color: AppColors.putih),
                    textStyle: TextStyle(color: AppColors.putih),
                    inputStyle: InputDecoration(
                      filled: true,
                      fillColor: AppColors.primary.withOpacity(0.5),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.putih),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.secondary,
                          width: 2,
                        ),
                      ),
                    ),
                    dropdownColor: AppColors.primary,
                    dropdownTextColor: AppColors.putih,
                    dropdownIconColor: AppColors.putih,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 50,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _exportExcel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.download,
                      color: AppColors.putih,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
