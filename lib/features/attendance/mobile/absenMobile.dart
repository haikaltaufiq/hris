import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/helpers/feature_guard.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/features/attendance/mobile/components/cardAttendance.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/features/attendance/view_model/absen_provider.dart';
import 'package:hr/data/models/absen_model.dart';

class AbsenMobile extends StatefulWidget {
  const AbsenMobile({super.key});

  @override
  State<AbsenMobile> createState() => _AbsenMobileState();
}

class _AbsenMobileState extends State<AbsenMobile> {
  final ScrollController _scrollController = ScrollController();
  int _displayedItemCount = 20;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AbsenProvider>().fetchAbsensi();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      setState(() {
        _displayedItemCount += 20;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 25, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),
            const CardAttendance(),

            /// ================= LIST ABSENSI USER =================
            FeatureGuard(
              requiredFeature: "lihat_absensi_sendiri",
              child: Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        context.isIndonesian
                            ? "Riwayat Absensi"
                            : "Attendance History",
                        style: TextStyle(
                          color: AppColors.putih,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
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

                          final displayData =
                              data.take(_displayedItemCount).toList();

                          return ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(top: 1, bottom: 16),
                            itemCount: displayData.length +
                                (displayData.length < data.length ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == displayData.length) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(
                                      color: AppColors.putih,
                                    ),
                                  ),
                                );
                              }

                              final absen = displayData[index];
                              return _AbsensiItem(
                                absen: absen,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.detailAbsen,
                                    arguments: absen,
                                  );
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
            ),

            /// ============= Lihat Absen Semua ===============
            FeatureGuard(
              requiredFeature: "lihat_semua_absensi",
              child: Expanded(
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

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.isIndonesian
                                    ? "Riwayat Absensi"
                                    : "Attendance History",
                                style: TextStyle(
                                  color: AppColors.putih,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    context.isIndonesian
                                        ? "Urutkan: "
                                        : "Sort by: ",
                                    style: TextStyle(
                                        color: AppColors.putih, fontSize: 14),
                                  ),
                                  DropdownButton<String>(
                                    value: provider.currentSortField,
                                    dropdownColor: AppColors.bg,
                                    style: TextStyle(color: AppColors.putih),
                                    underline: Container(),
                                    items: [
                                      DropdownMenuItem(
                                          value: 'hari',
                                          child: Text(context.isIndonesian
                                              ? "Hari ini"
                                              : "Today")),
                                      DropdownMenuItem(
                                          value: 'semua',
                                          child: Text(context.isIndonesian
                                              ? "Semua"
                                              : "All")),
                                      DropdownMenuItem(
                                          value: 'terbaru',
                                          child: Text(context.isIndonesian
                                              ? "Terbaru"
                                              : "Newest")),
                                      DropdownMenuItem(
                                          value: 'terlama',
                                          child: Text(context.isIndonesian
                                              ? "Terlama"
                                              : "Oldest")),
                                      DropdownMenuItem(
                                          value: 'nama',
                                          child: Text(context.isIndonesian
                                              ? "Nama"
                                              : "Name")),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        provider.sortAbsensi(value);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(top: 1, bottom: 16),
                            itemCount: data.take(_displayedItemCount).length +
                                (_displayedItemCount < data.length ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index ==
                                  data.take(_displayedItemCount).length) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(
                                      color: AppColors.putih,
                                    ),
                                  ),
                                );
                              }

                              final absen = data[index];
                              return _AbsensiItem(
                                absen: absen,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.detailAbsen,
                                    arguments: absen,
                                  );
                                },
                                isManagerView: true,
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
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
  final bool isManagerView;

  const _AbsensiItem({
    required this.absen,
    required this.onTap,
    this.isManagerView = false,
  });

  @override
  Widget build(BuildContext context) {
    final rawDate = absen.checkinDate;
    String dateText;
    if (rawDate != null && rawDate.isNotEmpty) {
      final date = DateTime.parse(rawDate);
      final now = DateTime.now();
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        dateText = context.isIndonesian ? "Hari ini" : "Today";
      } else {
        dateText = DateFormat('dd/MM/yy').format(date);
      }
    } else {
      dateText = '-';
    }
    final checkIn = absen.checkinTime ?? '--:--';
    final checkOut = absen.checkoutTime ?? '--:--';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.putih.withOpacity(0.25),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Circle Avatar
            if (isManagerView) ...[
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.8),
                        AppColors.primary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                        color: AppColors.putih.withOpacity(0.4), width: 2),
                  ),
                  child: ClipOval(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          getInitials(absen.user!.nama),
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.putih,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],

            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isManagerView
                        ? getDisplayName(absen.user!.nama)
                        : context.isIndonesian
                            ? "Tanggal :"
                            : "Date :",
                    style: TextStyle(
                      color: AppColors.putih,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 10),
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
            Icon(
              Icons.chevron_right,
              color: AppColors.putih,
              size: 22,
            ),
          ],
        ),
      ),
    );
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

String getInitials(String fullName) {
  if (fullName.isEmpty) return '';
  final parts = fullName.split(' ').where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '';
  return parts[0][0].toUpperCase(); // ambil huruf pertama doang
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

String getDisplayName(String fullName) {
  if (fullName.isEmpty) return '';

  final parts = fullName.split(' ').where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '';

  // Ambil nama pertama
  var first = parts[0];

  // Jika cuma 1 huruf dan ada nama kedua, gabung kedua nama
  if (first.length <= 1 && parts.length > 1) {
    first = '$first ${parts[1]}';
  }

  return first;
}
