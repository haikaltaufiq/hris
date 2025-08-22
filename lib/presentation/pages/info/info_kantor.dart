// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

class _KantorFormPageState extends State<KantorFormPage> {
  final _formKey = GlobalKey<FormState>();

  // controller sesuai kolom tabel kantor
  final jamMasukController = TextEditingController();
  final minimalKeterlambatanController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final radiusController = TextEditingController(text: "100");

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDataKantor();
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ℹ️ Data kantor belum tersedia")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Gagal load data kantor: $e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// ambil lokasi otomatis
  Future<void> _isiLokasiOtomatis() async {
    setState(() => isLoading = true);
    final position = await LocationService.getCurrentPosition();
    if (position != null) {
      latitudeController.text = position.latitude.toStringAsFixed(7);
      longitudeController.text = position.longitude.toStringAsFixed(7);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mendapatkan lokasi")),
      );
    }
    setState(() => isLoading = false);
  }

  /// lihat map
  void _lihatMap() {
    if (latitudeController.text.isEmpty || longitudeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Isi latitude & longitude dulu")),
      );
      return;
    }
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

  /// simpan data ke API Laravel
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
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Data kantor berhasil disimpan")),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ Gagal simpan kantor")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚠️ Error: $e")),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          "Pengaturan Kantor",
          style: GoogleFonts.poppins(
            color: AppColors.putih,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: jamMasukController,
                        decoration: _inputStyle("Jam Masuk Kantor (HH:mm)", Icons.access_time),
                        validator: (v) => v!.isEmpty ? "Harus diisi" : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: minimalKeterlambatanController,
                        decoration: _inputStyle("Minimal Keterlambatan (HH:mm)", Icons.timer_off),
                        validator: (v) => v!.isEmpty ? "Harus diisi" : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: latitudeController,
                        readOnly: true,
                        decoration: _inputStyle("Latitude", Icons.place),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: longitudeController,
                        readOnly: true,
                        decoration: _inputStyle("Longitude", Icons.place_outlined),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: radiusController,
                        keyboardType: TextInputType.number,
                        decoration: _inputStyle("Minimal Batas Absen (meter)", Icons.circle_outlined),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: isLoading ? null : _isiLokasiOtomatis,
                              icon: const Icon(Icons.my_location),
                              label: Text(isLoading ? "Loading..." : "Gunakan Lokasi Saya"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _lihatMap,
                              icon: const Icon(Icons.map),
                              label: const Text("Lihat Map"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: isLoading ? null : _simpan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.putih,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                           padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "Simpan",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// loading overlay
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
        ],
      ),
    );
  }
}
