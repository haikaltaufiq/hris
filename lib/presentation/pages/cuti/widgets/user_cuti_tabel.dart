import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/dialog/detail_item.dart';
import 'package:hr/components/tabel/main_tabel.dart';
import 'package:hr/core/helpers/formatted_date.dart';
import 'package:hr/core/theme.dart';
import 'package:hr/data/models/cuti_model.dart';
import 'package:hr/presentation/pages/cuti/cuti_form/cuti_edit_form.dart';

class UserCutiTabel extends StatelessWidget {
  final void Function(CutiModel cuti) onDelete;
  final List<CutiModel> cutiList;

  const UserCutiTabel({
    super.key,
    required this.cutiList,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDataTableWidget(
      headers: [
        'Nama',
        'Tipe Cuti',
        'Mulai Cuti',
        'Selesai Cuti',
        'Alasan',
        'Status',
      ],
      rows: cutiList.map((c) {
        return [
          c.user['nama']?.toString() ?? '',
          c.tipe_cuti.toString(),
          DateHelper.format(c.tanggal_mulai).toString(),
          DateHelper.format(c.tanggal_selesai).toString(),
          c.shortAlasan.toString(),
          c.status.toString(),
        ];
      }).toList(),
      statusColumnIndexes: [5],
      onCellTap: (row, col) {
        print('Klik cell row: $row, col: $col');
      },
      onView: (row) {
        final c = cutiList[row];
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              'Detail Cuti',
              style: GoogleFonts.poppins(
                color: AppColors.putih,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DetailItem(label: 'Nama', value: c.user['nama']),
                DetailItem(
                    label: 'Status', value: c.status, color: c.statusColor),
                DetailItem(label: 'Tipe Cuti', value: c.tipe_cuti),
                DetailItem(
                    label: 'Tanggal Mulai',
                    value: DateHelper.format(c.tanggal_mulai)),
                DetailItem(
                    label: 'Tanggal Selesai',
                    value: DateHelper.format(c.tanggal_selesai)),
                DetailItem(label: 'Alasan', value: c.alasan),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Tutup',
                    style: GoogleFonts.poppins(
                      color: AppColors.putih,
                      fontSize: 16,
                    )),
              ),
            ],
          ),
        );
      },
      onEdit: (row) {
        final c = cutiList[row];
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CutiEditForm(cuti: c)),
        );
      },
      onDelete: (row) {
        final c = cutiList[row];
        onDelete(c);
      },
    );
  }
}
