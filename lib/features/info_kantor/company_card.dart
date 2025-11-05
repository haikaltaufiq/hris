import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/data/models/kantor_model.dart';
import 'package:hr/data/services/kantor_service.dart';
import 'package:hr/routes/app_routes.dart';

class CompanyCard extends StatefulWidget {
  const CompanyCard({super.key});

  @override
  State<CompanyCard> createState() => _CompanyCardState();
}

class _CompanyCardState extends State<CompanyCard> {
  KantorModel? kantor;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKantorData();
  }

  Future<void> _loadKantorData() async {
    try {
      final data = await KantorService.getKantor();
      if (mounted) {
        setState(() {
          kantor = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      // print('Error loading kantor data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle decorative accent only
          Positioned(
            top: -10,
            right: -10,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withOpacity(0.08),
              ),
            ),
          ),

          // Main content with better padding
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with company info and menu
                Row(
                  children: [
                    // Company icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.business,
                        color: AppColors.putih,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Company info - hardcoded name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PT Kreatif System Indonesia',
                            style: GoogleFonts.poppins(
                              color: AppColors.putih,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.isIndonesian
                                ? 'Pengaturan operasional kantor'
                                : 'Company Settings',
                            style: GoogleFonts.poppins(
                              color: AppColors.putih.withOpacity(0.65),
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Menu button - cleaner design
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.putih.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.info);
                        },
                        icon: Icon(
                          Icons.more_vert,
                          color: AppColors.putih.withOpacity(0.8),
                          size: 18,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Content based on loading state
                if (isLoading)
                  _buildLoadingContent()
                else if (kantor != null)
                  _buildKantorContent()
                else
                  _buildEmptyContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Column(
      children: [
        // Loading shimmer effect
        Row(
          children: [
            Expanded(
              child: Column(
                children: List.generate(
                    3,
                    (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppColors.putih.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        )),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: List.generate(
                    3,
                    (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppColors.putih.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        )),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: AppColors.putih.withOpacity(0.7),
              strokeWidth: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKantorContent() {
    return Column(
      children: [
        // Info grid dengan spacing yang lebih rapi
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column
            Expanded(
              child: Column(
                children: [
                  _buildInfoItem(
                    icon: Icons.access_time_outlined,
                    label: context.isIndonesian ? 'Jam Masuk' : 'Checkin Time',
                    value: kantor!.jamMasuk,
                  ),
                  const SizedBox(height: 20),
                  _buildInfoItem(
                    icon: Icons.access_time_filled_outlined,
                    label:
                        context.isIndonesian ? 'Jam Keluar' : 'Checkout Time',
                    value: kantor!.jamKeluar,
                  ),
                  const SizedBox(height: 20),
                  _buildInfoItem(
                    icon: Icons.timer_outlined,
                    label: context.isIndonesian ? 'Toleransi' : 'Tolerance',
                    value: context.isIndonesian
                        ? '${kantor!.minimalKeterlambatan} Menit'
                        : '${kantor!.minimalKeterlambatan} Minute',
                  ),
                ],
              ),
            ),

            const SizedBox(width: 24),

            // Right column
            Expanded(
              child: Column(
                children: [
                  // _buildInfoItem(
                  //   icon: Icons.calendar_today_outlined,
                  //   label:
                  //       context.isIndonesian ? 'Cuti Tahunan' : 'Annual Leave',
                  //   value: '${kantor!.jatahCutiTahunan} hari',
                  // ),
                  const SizedBox(height: 20),
                  _buildInfoItem(
                    icon: Icons.location_on_outlined,
                    label: context.isIndonesian ? 'Koordinat' : 'Coordinate',
                    value:
                        '${kantor!.lat.toStringAsFixed(4)}, ${kantor!.lng.toStringAsFixed(4)}',
                    isSmallText: true,
                  ),
                  const SizedBox(height: 20),
                  _buildInfoItem(
                    icon: Icons.radio_button_unchecked,
                    label: 'Radius',
                    value: '${kantor!.radiusMeter} meter',
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Footer info yang lebih clean
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.putih.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.putih.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.putih.withOpacity(0.6),
                size: 16,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.isIndonesian
                      ? 'Konfigurasi berlaku untuk seluruh karyawan'
                      : 'Configuration applies to all employees',
                  style: GoogleFonts.poppins(
                    color: AppColors.putih.withOpacity(0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyContent() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(
            Icons.business_center_outlined,
            color: AppColors.putih.withOpacity(0.5),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            context.isIndonesian
                ? 'Belum ada informasi kantor'
                : 'No Company info available',
            style: GoogleFonts.poppins(
              color: AppColors.putih.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.isIndonesian
                ? 'Atur informasi kantor untuk mulai menggunakan sistem absensi'
                : 'Set Company info to use attendance features',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppColors.putih.withOpacity(0.5),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.info);
            },
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              context.isIndonesian ? 'Atur Sekarang' : 'Set now',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.putih,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    bool isSmallText = false,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label dengan icon
        Row(
          children: [
            Icon(
              icon,
              color: AppColors.putih.withOpacity(0.6),
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  color: AppColors.putih.withOpacity(0.55),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Value dengan padding yang konsisten
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              color: valueColor ?? AppColors.putih,
              fontSize: isSmallText ? 12 : 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
