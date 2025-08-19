import 'package:flutter/material.dart';
import 'package:hr/components/tabel/main_tabel.dart';
import 'package:hr/data/models/potongan_gaji.dart';
import 'package:hr/data/services/potongan_gaji_service.dart';
import 'package:hr/presentation/pages/potongan/potongan_form/form_edit.dart';

class PotonganTabel extends StatefulWidget {
  const PotonganTabel({super.key});

  @override
  State<PotonganTabel> createState() => _PotonganTabelState();
}

class _PotonganTabelState extends State<PotonganTabel> {
  List<PotonganGajiModel> _potonganList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPotongan();
  }

  // Fetch data dari API
  Future<void> _loadPotongan() async {
    setState(() => _isLoading = true);
    try {
      final data = await PotonganGajiService.fetchPotonganGaji();
      setState(() {
        _potonganList = data;
      });
    } catch (e) {
      print('Error fetch potongan: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Hapus potongan
  Future<void> _deletePotongan(int index) async {
    final id = _potonganList[index].id!;
    final success = await PotonganGajiService.deletePotonganGaji(id);
    if (success) {
      setState(() {
        _potonganList.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Potongan berhasil dihapus')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus potongan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return CustomDataTableWidget(
      headers: ["Nama Potongan", "Nominal"],
      rows: _potonganList
          .map((e) => [e.namaPotongan, e.nominal.toStringAsFixed(0)])
          .toList(),
      statusColumnIndexes: [],
      onCellTap: (row, col) {
        print('Klik cell row: $row, col: $col');
      },
      onView: (row) {},
      onDelete: (row) => _deletePotongan(row),
      onEdit: (row) {
        final potongan = _potonganList[row];
        Navigator.of(context)
            .push(MaterialPageRoute(
              builder: (_) => PotonganEdit(potongan: potongan),
            ))
            .then((value) {
          // Reload data setelah edit
          _loadPotongan();
        });
      },
    );
  }
}
