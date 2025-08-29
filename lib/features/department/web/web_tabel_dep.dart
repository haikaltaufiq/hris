import 'package:flutter/material.dart';
import 'package:hr/components/tabel/web_tabel.dart';
import 'package:hr/data/models/departemen_model.dart';

class WebTabelDep extends StatelessWidget {
  final List<DepartemenModel> departemenList;
  final Function(DepartemenModel) onEdit;
  final Function(int) onDelete;

  const WebTabelDep({
    super.key,
    required this.departemenList,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Header tabel
    final headers = ["Nama Department"];

    // Convert departemenList ke rows (List<List<String>>)
    final rows = departemenList
        .map((d) => [
              d.namaDepartemen,
            ])
        .toList();

    return CustomDataTableWeb(
      headers: headers,
      rows: rows,
      columnFlexValues: const [2], // biar kolom nama dept agak lebar
      onEdit: (rowIndex) {
        final departemen = departemenList[rowIndex];
        onEdit(departemen);
      },
      onDelete: (rowIndex) {
        final departemen = departemenList[rowIndex];
        onDelete(departemen.id);
      },
    );
  }
}
