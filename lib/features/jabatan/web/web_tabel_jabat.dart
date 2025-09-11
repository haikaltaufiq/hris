import 'package:flutter/material.dart';
import 'package:hr/components/tabel/web_tabel.dart';
import 'package:hr/data/models/jabatan_model.dart';

class WebTabelJabat extends StatelessWidget {
  final List<JabatanModel> jabatanList;
  final Function(JabatanModel) onEdit;
  final Function(int) onDelete;

  const WebTabelJabat({
    super.key,
    required this.jabatanList,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Header tabel
    final headers = ["Nama Jabatan"];

    // Convert departemenList ke rows (List<List<String>>)
    final rows = jabatanList
        .map((d) => [
              d.namaJabatan,
            ])
        .toList();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.01,
      ),
      child: CustomDataTableWeb(
        headers: headers,
        rows: rows,
        columnFlexValues: const [2], // biar kolom nama dept agak lebar
        onEdit: (rowIndex) {
          final departemen = jabatanList[rowIndex];
          onEdit(departemen);
        },
        onDelete: (rowIndex) {
          final departemen = jabatanList[rowIndex];
          onDelete(departemen.id);
        },
      ),
    );
  }
}
