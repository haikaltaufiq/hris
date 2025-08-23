import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/timepicker/time_picker.dart';
import 'package:hr/data/models/kantor_model.dart';
import 'package:hr/data/services/kantor_service.dart';
import 'package:hr/data/services/location_service.dart';
import 'package:hr/presentation/pages/absen/absen_form/map/map_page.dart';
import 'package:latlong2/latlong.dart';
import 'package:hr/core/theme.dart';

class KantorFormPage extends StatefulWidget {
  const KantorFormPage({super.key});

  @override
  State<KantorFormPage> createState() => _KantorFormPageState();
}

class _KantorFormPageState extends State<KantorFormPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final jamMasukController = TextEditingController();
  final minimalKeterlambatanController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final radiusController = TextEditingController(text: "100");

  bool isLoading = false;
  late AnimationController _animationController;
  int _selectedMinute = 0;
  int _selectedHour = 0;

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
    super.dispose();
  }

  Future<void> _loadDataKantor() async {
    setState(() => isLoading = true);
    try {
      final kantor = await KantorService.getKantor();
      if (kantor != null) {
        jamMasukController.text = kantor.jamMasuk;
        minimalKeterlambatanController.text = kantor.minimalKeterlambatan;
        latitudeController.text = kantor.lat.toString();
        longitudeController.text = kantor.lng.toString();
        radiusController.text = kantor.radiusMeter.toString();
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _isiLokasiOtomatis() async {
    setState(() => isLoading = true);
    final position = await LocationService.getCurrentPosition();
    if (position != null) {
      latitudeController.text = position.latitude.toStringAsFixed(7);
      longitudeController.text = position.longitude.toStringAsFixed(7);
    }
    setState(() => isLoading = false);
  }

  void _lihatMap() {
    if (latitudeController.text.isEmpty || longitudeController.text.isEmpty)
      return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapPage(
          target: LatLng(
            double.parse(latitudeController.text),
            double.parse(longitudeController.text),
          ),
        ),
      ),
    );
  }

  void _onTapIconTime(TextEditingController controller) async {
    showModalBottomSheet(
      backgroundColor: AppColors.primary,
      context: context,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
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
                                  const BorderRadius.all(Radius.circular(30)),
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
                            'Mulai Tugas',
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
                      final formattedHour =
                          _selectedHour.toString().padLeft(2, '0');
                      final formattedMinute =
                          _selectedMinute.toString().padLeft(2, '0');
                      final formattedTime = "$formattedHour:$formattedMinute";

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

  Future<void> _simpan() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      final kantor = KantorModel(
        jamMasuk: jamMasukController.text,
        minimalKeterlambatan: minimalKeterlambatanController.text,
        lat: double.tryParse(latitudeController.text) ?? 0,
        lng: double.tryParse(longitudeController.text) ?? 0,
        radiusMeter: int.tryParse(radiusController.text) ?? 0,
      );
      try {
        final success = await KantorService.createKantor(kantor);
        if (success) Navigator.pop(context, true);
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  InputDecoration _modernInput(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        color: AppColors.putih.withOpacity(0.8),
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(icon, color: AppColors.putih.withOpacity(0.8)),
      filled: true,
      fillColor: AppColors.putih.withOpacity(0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.putih.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.putih.withOpacity(0.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.secondary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.bg,
        title: Text(
          "Pengaturan Kantor",
          style: GoogleFonts.poppins(
            color: AppColors.putih,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.putih),
      ),
      body: Stack(
        children: [
          // Main content
          ListView(
            padding: EdgeInsets.all(16),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 80),

                  const SizedBox(height: 8),

                  // Form fields
                  GestureDetector(
                    onTap: () => _onTapIconTime(jamMasukController),
                    child: AbsorbPointer(
                      child: TextFormField(
                        style: GoogleFonts.poppins(color: AppColors.putih),
                        controller: jamMasukController,
                        decoration:
                            _modernInput("Jam Masuk", Icons.access_time),
                        validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () => _onTapIconTime(minimalKeterlambatanController),
                    child: AbsorbPointer(
                      child: TextFormField(
                        style: GoogleFonts.poppins(color: AppColors.putih),
                        controller: minimalKeterlambatanController,
                        decoration: _modernInput(
                            "Minimal Keterlambatan", Icons.timer_off),
                        validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          style: GoogleFonts.poppins(color: AppColors.putih),
                          controller: latitudeController,
                          readOnly: true,
                          decoration: _modernInput("Latitude", Icons.place),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          style: GoogleFonts.poppins(color: AppColors.putih),
                          controller: longitudeController,
                          readOnly: true,
                          decoration:
                              _modernInput("Longitude", Icons.place_outlined),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    style: GoogleFonts.poppins(color: AppColors.putih),
                    controller: radiusController,
                    keyboardType: TextInputType.number,
                    decoration: _modernInput(
                        "Radius Absen (meter)", Icons.circle_outlined),
                  ),

                  const SizedBox(height: 32),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : _isiLokasiOtomatis,
                          icon: Icon(Icons.my_location,
                              color: AppColors.putih, size: 18),
                          label: Text(
                            "Lokasi Saya",
                            style: GoogleFonts.poppins(
                              color: AppColors.putih,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.putih.withOpacity(0.15),
                            foregroundColor: AppColors.putih,
                            elevation: 0,
                            side: BorderSide(
                                color: AppColors.putih.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _lihatMap,
                          icon:
                              Icon(Icons.map, color: AppColors.putih, size: 18),
                          label: Text(
                            "Lihat Map",
                            style: GoogleFonts.poppins(
                              color: AppColors.putih,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.putih.withOpacity(0.15),
                            foregroundColor: AppColors.putih,
                            elevation: 0,
                            side: BorderSide(
                                color: AppColors.putih.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Save button
                  ElevatedButton(
                    onPressed: isLoading ? null : _simpan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.putih,
                      elevation: 4,
                      shadowColor: AppColors.secondary.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: Text(
                      "Simpan Pengaturan",
                      style: GoogleFonts.poppins(
                        color: AppColors.putih,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ), // Simple loading overlay
            ],
          ),
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
                        "Menyimpan...",
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
