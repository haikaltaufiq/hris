import 'package:flutter/material.dart';
import 'package:hr/components/tabel/main_tabel.dart';
import 'package:hr/presentation/pages/potongan/potongan_form/form_edit.dart';

class PotonganTabel extends StatelessWidget {
  const PotonganTabel({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomDataTableWidget(
      headers: [
        "Nama",
        "Potongan",
      ],
      rows: [
        ["Bpjs", "10.000"]
      ],
      statusColumnIndexes: [5],
      onCellTap: (row, col) {
        print('Klik cell row: $row, col: $col');
      },
      onView: (row) {},
      onDelete: (row) {},
      onEdit: (row) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const PotonganFormEdit()),
        );
      },
    );
  }
}
