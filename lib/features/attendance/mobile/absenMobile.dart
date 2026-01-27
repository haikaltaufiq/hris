import 'package:flutter/material.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/features/dashboard/widget/dashboard_card_user.dart';
import 'package:hr/features/attendance/view_model/absen_provider.dart';
import 'package:hr/data/models/absen_model.dart';

class AbsenMobile extends StatefulWidget {
  const AbsenMobile({super.key});

  @override
  State<AbsenMobile> createState() => _AbsenMobileState();
}

class _AbsenMobileState extends State<AbsenMobile> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AbsenProvider>().fetchAbsensi();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 25, 16, 0),
        child: Column(
          children: [
            const DashboardCardUser(),

            /// ================= LIST ABSENSI =================
            Expanded(
              child: Consumer<AbsenProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.putih,
                      ),
                    );
                  }

                  if (provider.errorMessage != null) {
                    return Center(
                      child: Text(
                        provider.errorMessage!,
                        style: TextStyle(color: AppColors.red),
                      ),
                    );
                  }

                  final List<AbsenModel> data = provider.absensi;

                  if (data.isEmpty) {
                    return Center(
                      child: Text(
                        'Belum ada data absensi',
                        style: TextStyle(color: AppColors.putih),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final absen = data[index];
                      return _AbsensiItem(
                        absen: absen,
                        onTap: () {
                          // TODO: navigate ke detail absensi
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AbsensiItem extends StatelessWidget {
  final AbsenModel absen;
  final VoidCallback onTap;

  const _AbsensiItem({
    required this.absen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateText = _formatDate(absen.checkinDate);
    final checkIn = absen.checkinTime ?? '--:--';
    final checkOut = absen.checkoutTime ?? '--:--';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            /// DATE
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.isIndonesian ? "Tanggal :" : "Date :",
                    style: TextStyle(
                      color: AppColors.putih,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    dateText,
                    style: TextStyle(
                      color: AppColors.putih,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            /// CHECK IN
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.isIndonesian ? "Jam Masuk :" : "Check in :",
                    style: TextStyle(
                      color: AppColors.putih,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    formatTimeHHmm(checkIn),
                    style: TextStyle(
                      color: isLateCheckIn(checkIn)
                          ? AppColors.red
                          : AppColors.putih,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            /// CHECK OUT
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.isIndonesian ? "Jam Keluar" : "Check out :",
                    style: TextStyle(
                      color: AppColors.putih,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    formatTimeHHmm(checkOut),
                    style: TextStyle(
                      color: AppColors.putih,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            /// ARROW
            Icon(
              Icons.chevron_right,
              color: AppColors.putih,
              size: 22,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final date = DateTime.parse(raw);
      return DateFormat('dd/MM/yy').format(date);
    } catch (_) {
      return raw;
    }
  }
}

bool isLateCheckIn(String? time) {
  if (time == null || time.isEmpty) return false;

  try {
    final checkInTime = DateTime.parse("1970-01-01 $time");
    final limitTime = DateTime.parse("1970-01-01 08:10");
    return checkInTime.isAfter(limitTime);
  } catch (_) {
    return false;
  }
}

String formatTimeHHmm(String? time) {
  if (time == null || time.isEmpty) return "--:--";

  try {
    final dt = DateTime.parse("1970-01-01 $time");
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  } catch (_) {
    return time;
  }
}
