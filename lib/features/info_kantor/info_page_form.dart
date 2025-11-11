// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/components/timepicker/time_picker.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/data/models/kantor_model.dart';
import 'package:hr/data/services/kantor_service.dart';
import 'package:hr/features/attendance/mobile/absen_form/map/map_page_modal.dart';
import 'package:hr/features/info_kantor/location_dialog.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:latlong2/latlong.dart';
import 'package:numberpicker/numberpicker.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final jamMasukController = TextEditingController();
  final jamKeluarController = TextEditingController();
  final minimalKeterlambatanController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final radiusController = TextEditingController(text: "100");
  final jatahCutiController = TextEditingController();
  bool isLoading = false;
  late AnimationController _animationController;
  int _selectedMinute = 0;
  int _selectedHour = 8; // Set default hour
  int _selectedFirstDigit = 1; // Set default first digit
  int _selectedSecondDigit = 5; // Set default second digit (15 minutes)
  late final ValueChanged<int> onFirstChanged;
  late final ValueChanged<int> onSecondChanged;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animationController.forward();
    _loadDataKantor();
  }

  @override
  void dispose() {
    _animationController.dispose();
    jamMasukController.dispose();
    jamKeluarController.dispose();
    minimalKeterlambatanController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    radiusController.dispose();
    jatahCutiController.dispose();
    super.dispose();
  }

  Future<void> _loadDataKantor() async {
    setState(() => isLoading = true);
    try {
      final kantor = await KantorService.getKantor();
      if (kantor != null) {
        jamMasukController.text = kantor.jamMasuk;
        jamKeluarController.text = kantor.jamKeluar;
        minimalKeterlambatanController.text =
            kantor.minimalKeterlambatan.toString();
        latitudeController.text = kantor.lat.toString();
        longitudeController.text = kantor.lng.toString();
        radiusController.text = kantor.radiusMeter.toString();

        // Parse jam masuk untuk set initial values
        if (kantor.jamMasuk.isNotEmpty && kantor.jamMasuk.contains(':')) {
          final timeParts = kantor.jamMasuk.split(':');
          if (timeParts.length == 2) {
            _selectedHour = int.tryParse(timeParts[0]) ?? 8;
            _selectedMinute = int.tryParse(timeParts[1]) ?? 0;
          }
        }

        // Parse minimal keterlambatan untuk set initial values
        if (kantor.minimalKeterlambatan != null) {
          final totalMinutes = kantor.minimalKeterlambatan!;
          _selectedFirstDigit = totalMinutes ~/ 10; // puluhan
          _selectedSecondDigit = totalMinutes % 10; // satuan
        }
      }
    } catch (e) {
      // print('Error loading kantor data: $e');
      // // Set default values if loading fails
      // jamMasukController.text = "08:00";
      // minimalKeterlambatanController.text = "15 menit";
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _lihatMap() {
    if (latitudeController.text.isEmpty || longitudeController.text.isEmpty) {
      final message = context.isIndonesian
          ? "Harap isi koordinat terlebih dahulu"
          : "Please fill in the coordinates first";
      NotificationHelper.showTopNotification(
        context,
        message,
        isSuccess: false,
      );
      return;
    }

    try {
      if (context.isMobile) {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 1.0,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    )
                  ],
                ),
                child: Stack(
                  children: [
                    // Konten bisa discroll
                    Column(
                      children: [
                        // Handle bar
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          height: 5,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Text(
                          context.isIndonesian
                              ? "Lokasi Absen"
                              : 'Attendance Loc',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.putih),
                        ),
                        const SizedBox(height: 10),

                        // Map full tinggi fix
                        Expanded(
                          child: MapPageModal(
                            target: LatLng(
                              double.parse(latitudeController.text),
                              double.parse(longitudeController.text),
                            ),
                          ),
                        ),

                        const SizedBox(
                            height: 200), // dummy biar bisa full drag
                      ],
                    ),

                    // Card info nempel di bawah
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LocationInfoCard(
                          target: LatLng(
                            double.parse(latitudeController.text),
                            double.parse(longitudeController.text),
                          ),
                          mapController: MapController(),
                          onConfirm: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      } else {
        Navigator.pushNamed(
          context,
          AppRoutes.mapPage,
          arguments: LatLng(
            double.parse(latitudeController.text),
            double.parse(longitudeController.text),
          ),
        );
      }
    } catch (e) {
      final message = context.isIndonesian
          ? "Format koordinat tidak valid"
          : "Invalid coordinate format";
      NotificationHelper.showTopNotification(
        context,
        message,
        isSuccess: false,
      );
    }
  }

  void _onTapIconTime(TextEditingController controller,
      {bool isKeterlambatan = false}) async {
    showModalBottomSheet(
      backgroundColor: AppColors.primary,
      context: context,
      clipBehavior: Clip.antiAlias,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
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
                                  const BorderRadius.all(Radius.circular(30)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isKeterlambatan
                                ? context.isIndonesian
                                    ? 'Pilih Menit'
                                    : 'Choose Minute'
                                : context.isIndonesian
                                    ? 'Pilih Waktu'
                                    : 'Choose Time',
                            style: TextStyle(
                              color: AppColors.putih,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            isKeterlambatan
                                ? context.isIndonesian
                                    ? 'Minimal Keterlambatan'
                                    : 'Late Tolerance'
                                : context.isIndonesian
                                    ? 'Mulai Tugas'
                                    : 'Start Task',
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

                  // Time picker atau minute picker
                  Expanded(
                    child: isKeterlambatan
                        ? // Custom minute picker untuk minimal keterlambatan
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Digit pertama (0-9)
                              SizedBox(
                                width: 80,
                                child: NumberPicker(
                                  minValue: 0,
                                  maxValue: 9,
                                  value: _selectedFirstDigit,
                                  zeroPad: true,
                                  infiniteLoop: true,
                                  itemWidth: 55,
                                  itemHeight: 50,
                                  onChanged: (value) {
                                    setModalState(() {
                                      _selectedFirstDigit = value;
                                    });
                                  },
                                  textStyle: TextStyle(
                                      color: AppColors.putih.withOpacity(0.5),
                                      fontSize: 20),
                                  selectedTextStyle: TextStyle(
                                    color: AppColors.putih,
                                    fontSize: 24,
                                    fontFamily:
                                        GoogleFonts.poppins().fontFamily,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(color: AppColors.putih),
                                      bottom:
                                          BorderSide(color: AppColors.putih),
                                    ),
                                  ),
                                ),
                              ),

                              // Digit kedua (0-9)
                              SizedBox(
                                width: 80,
                                child: NumberPicker(
                                  minValue: 0,
                                  maxValue: 9,
                                  value: _selectedSecondDigit,
                                  zeroPad: true,
                                  infiniteLoop: true,
                                  itemWidth: 55,
                                  itemHeight: 50,
                                  onChanged: (value) {
                                    setModalState(() {
                                      _selectedSecondDigit = value;
                                    });
                                  },
                                  textStyle: TextStyle(
                                      color: AppColors.putih.withOpacity(0.5),
                                      fontSize: 20),
                                  selectedTextStyle: TextStyle(
                                    color: AppColors.putih,
                                    fontSize: 24,
                                    fontFamily:
                                        GoogleFonts.poppins().fontFamily,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(color: AppColors.putih),
                                      bottom:
                                          BorderSide(color: AppColors.putih),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : // Time picker untuk jam masuk
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
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FloatingActionButton.extended(
                      backgroundColor: AppColors.secondary,
                      onPressed: () {
                        if (isKeterlambatan) {
                          final totalMinutes =
                              (_selectedFirstDigit * 10) + _selectedSecondDigit;
                          controller.text = "$totalMinutes menit";
                        } else {
                          final formattedHour =
                              _selectedHour.toString().padLeft(2, '0');
                          final formattedMinute =
                              _selectedMinute.toString().padLeft(2, '0');
                          final formattedTime =
                              "$formattedHour:$formattedMinute";
                          controller.text = formattedTime;
                        }

                        Navigator.pop(context);
                      },
                      label: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Text(
                          context.isIndonesian ? 'Simpan' : 'Save',
                          style: TextStyle(
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            color: AppColors.putih,
                            fontSize: 18,
                          ),
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

  Future<void> _simpan() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      // bikin model dari inputan form
      final kantor = KantorModel(
        jamMasuk: jamMasukController.text,
        jamKeluar: jamKeluarController.text,
        minimalKeterlambatan:
            int.tryParse(minimalKeterlambatanController.text) ?? 0,
        lat: double.tryParse(latitudeController.text) ?? 0,
        lng: double.tryParse(longitudeController.text) ?? 0,
        radiusMeter: int.tryParse(radiusController.text) ?? 0,
      );

      try {
        final result = await KantorService.createKantor(kantor);
        if (result["success"]) {
          NotificationHelper.showTopNotification(
            context,
            result["message"],
            isSuccess: true,
          );
          Navigator.pop(context, true);
        } else {
          NotificationHelper.showTopNotification(
            context,
            result["message"],
            isSuccess: false,
          );
        }
      } catch (e) {
        NotificationHelper.showTopNotification(
          context,
          e.toString(),
          isSuccess: false,
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  // Widget untuk membuat label di atas textfield
  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: AppColors.putih,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Widget untuk membuat form field dengan style konsisten
  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    TextInputType? keyboardType,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        SizedBox(
          height: 56,
          child: GestureDetector(
            onTap: onTap,
            child: AbsorbPointer(
              absorbing: onTap != null || readOnly,
              child: TextFormField(
                controller: controller,
                readOnly: readOnly,
                keyboardType: keyboardType,
                validator: validator,
                style: GoogleFonts.poppins(
                  color: AppColors.putih,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    icon,
                    color: AppColors.putih.withOpacity(0.7),
                    size: 20,
                  ),
                  filled: false,
                  fillColor: AppColors.primary,
                  hintStyle: GoogleFonts.poppins(
                    color: AppColors.putih.withOpacity(0.5),
                    fontSize: 14,
                  ),
                  // **Ganti border kotak jadi hanya underline**
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.putih.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.secondary,
                      width: 2,
                    ),
                  ),
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.red.shade400,
                      width: 1,
                    ),
                  ),
                  focusedErrorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.red.shade400,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget untuk form content yang sama untuk mobile dan desktop
  Widget _buildFormContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Form fields dengan spacing konsisten
          _buildFormField(
              label: context.isIndonesian ? "Jam Masuk" : 'Checkin Time',
              controller: jamMasukController,
              icon: Icons.access_time,
              readOnly: true,
              onTap: context.isMobile
                  ? () => _onTapIconTime(jamMasukController)
                  : () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 0, minute: 0),
                        initialEntryMode: TimePickerEntryMode.input,
                        builder: (context, child) {
                          return MediaQuery(
                            data: MediaQuery.of(context)
                                .copyWith(alwaysUse24HourFormat: true),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: AppColors.secondary,
                                  onPrimary: AppColors.putih,
                                  surface: AppColors.primary,
                                  onSurface: AppColors.putih,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.putih,
                                  ),
                                ),
                              ),
                              child: child!,
                            ),
                          );
                        },
                      );

                      if (picked != null) {
                        jamMasukController.text =
                            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                      }
                      (v) => v == null || v.isEmpty ? "Wajib diisi" : null;
                    }),
          _buildFormField(
              label: context.isIndonesian ? "Jam Keluar" : 'Checkout Time',
              controller: jamKeluarController,
              icon: Icons.access_time,
              readOnly: true,
              onTap: context.isMobile
                  ? () => _onTapIconTime(jamKeluarController)
                  : () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 0, minute: 0),
                        initialEntryMode: TimePickerEntryMode.input,
                        builder: (context, child) {
                          return MediaQuery(
                            data: MediaQuery.of(context)
                                .copyWith(alwaysUse24HourFormat: true),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: AppColors.secondary,
                                  onPrimary: AppColors.putih,
                                  surface: AppColors.primary,
                                  onSurface: AppColors.putih,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.putih,
                                  ),
                                ),
                              ),
                              child: child!,
                            ),
                          );
                        },
                      );

                      if (picked != null) {
                        jamKeluarController.text =
                            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                      }
                      (v) => v == null || v.isEmpty ? "Wajib diisi" : null;
                    }),

          const SizedBox(height: 14),

          _buildFormField(
            label: context.isIndonesian
                ? "Minimal Keterlambatan"
                : 'Late Tolerance',
            controller: minimalKeterlambatanController,
            icon: Icons.timer_off,
            readOnly: true,
            onTap: () => _onTapIconTime(minimalKeterlambatanController,
                isKeterlambatan: true),
            validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
          ),

          const SizedBox(height: 14),

          // _buildFormField(
          //   label: context.isIndonesian
          //       ? "Jatah Cuti Tahunan (hari)"
          //       : 'Annual Leave',
          //   controller: jatahCutiController,
          //   icon: Icons.date_range,
          //   keyboardType: TextInputType.number,
          //   validator: (v) {
          //     if (v == null || v.isEmpty) return "Wajib diisi";
          //     final value = int.tryParse(v);
          //     if (value == null || value <= 0) {
          //       return "Harus berupa angka positif";
          //     }
          //     return null;
          //   },
          // ),

          const SizedBox(height: 14),

          // Row untuk Latitude dan Longitude
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  label: "Latitude",
                  controller: latitudeController,
                  icon: Icons.place,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Wajib diisi";
                    final value = double.tryParse(v);
                    if (value == null) return "Format tidak valid";
                    if (value < -90 || value > 90) {
                      return "Nilai harus -90 hingga 90";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  label: "Longitude",
                  controller: longitudeController,
                  icon: Icons.place_outlined,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Wajib diisi";
                    final value = double.tryParse(v);
                    if (value == null) return "Format tidak valid";
                    if (value < -180 || value > 180) {
                      return "Nilai harus -180 hingga 180";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _buildFormField(
            label: context.isIndonesian
                ? "Radius Absen (meter)"
                : 'Attendance Radius (meter)',
            controller: radiusController,
            icon: Icons.circle_outlined,
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v == null || v.isEmpty) return "Wajib diisi";
              final value = int.tryParse(v);
              if (value == null || value <= 0) {
                return "Harus berupa angka positif";
              }
              return null;
            },
          ),

          const SizedBox(height: 14),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      LocationDialogService.showLocationDialog(
                        context: context,
                        latitudeController: latitudeController,
                        longitudeController: longitudeController,
                      );
                    },
                    icon: Icon(
                      Icons.my_location,
                      color: AppColors.putih,
                      size: 18,
                    ),
                    label: Text(
                      context.isIndonesian
                          ? "Bagikan Lokasi"
                          : 'Share Location',
                      style: GoogleFonts.poppins(
                        color: AppColors.putih,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.putih,
                      elevation: 0,
                      side: BorderSide(
                        color: AppColors.putih.withOpacity(0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : _lihatMap,
                    icon: Icon(
                      Icons.map,
                      color: AppColors.putih,
                      size: 18,
                    ),
                    label: Text(
                      context.isIndonesian ? "Lihat Map" : 'See Map',
                      style: GoogleFonts.poppins(
                        color: AppColors.putih,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.putih,
                      elevation: 0,
                      side: BorderSide(
                        color: AppColors.putih.withOpacity(0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Save button dengan warna secondary
          SizedBox(
            height: 56,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _simpan,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1F1F1F),
                elevation: 2,
                shadowColor: AppColors.secondary.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                context.isIndonesian ? "Simpan Pengaturan" : 'save',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Main content
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header - tampil untuk mobile dan desktop
                    if (context.isMobile) ...[
                      SizedBox(
                        height: 10,
                      ),
                      Header(
                          title: context.isIndonesian
                              ? 'Manajemen Info Kantor'
                              : 'Company Info'),
                    ],

                    // Form content - tampil untuk semua ukuran layar
                    _buildFormContent(),

                    const SizedBox(height: 40), // Bottom padding
                  ],
                ),
              ),
            ),
          ),

          // Loading overlay
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.putih,
                        strokeWidth: 2,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.isIndonesian ? "Menyimpan..." : 'Saving...',
                        style: GoogleFonts.poppins(
                          color: AppColors.putih,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
