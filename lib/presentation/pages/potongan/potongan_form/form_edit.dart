// lib/presentation/pages/potongan/potongan_form/widget/potongan_edit.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/data/models/potongan_gaji.dart';
import 'package:hr/data/services/potongan_gaji_service.dart';

class PotonganEdit extends StatefulWidget {
  final PotonganGajiModel potongan;

  const PotonganEdit({super.key, required this.potongan});

  @override
  State<PotonganEdit> createState() => _PotonganEditState();
}

class _PotonganEditState extends State<PotonganEdit> {
  late TextEditingController _namaController;
  late TextEditingController _nominalController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.potongan.namaPotongan);
    _nominalController = TextEditingController(text: widget.potongan.nominal.toString());
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nominalController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _isLoading = true;
    });

    final updatedPotongan = PotonganGajiModel(
      id: widget.potongan.id,
      namaPotongan: _namaController.text,
      nominal: double.tryParse(_nominalController.text) ?? 0,
    );

    final result = await PotonganGajiService.updatePotonganGaji(updatedPotongan);

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      NotificationHelper.showSnackBar(
        context,
        result['message'] ?? 'Potongan berhasil diupdate',
        isSuccess: true,
      );
      Navigator.of(context).pop(true);
    } else {
      NotificationHelper.showSnackBar(
        context,
        result['message'] ?? 'Gagal update potongan',
        isSuccess: false,
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Potongan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Potongan',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nominalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nominal',
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
