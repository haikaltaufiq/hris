import 'package:flutter/material.dart';
import 'package:hr/components/tabel/main_tabel.dart';
import 'package:hr/core/theme.dart';

class AbsenTabel extends StatelessWidget {
  const AbsenTabel({super.key});

  final List<String> headers = const [
    "Nama",
    "Tanggal",
    "Tipe",
    "Jam Masuk",
    "Jam Keluar",
    "Lokasi",
    "Foto",
    "Keterangan",
  ];

  final List<List<String>> rows = const [
    [
      "Elon Musk",
      "12 / 10 / 2025",
      "Clock In",
      "08 : 00",
      "17 : 00",
      "198.12039.1123",
      "See Photo",
      "jadi tadi telat dikit trus blablabla",
    ],
    // bisa tambahin row lain disini
  ];

  @override
  Widget build(BuildContext context) {
    return CustomDataTableWidget(
      headers: headers,
      rows: rows,
      statusColumnIndexes: null, // bisa diisi kalo ada status
      onView: (rowIndex) {
        // logic show detail
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.primary,
            title: const Text(
              'Detail Absen',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(headers.length, (index) {
                final value = rows[rowIndex][index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          headers[index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          value,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text('Tutup', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
      onDelete: (rowIndex) {
        // logic delete
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.primary,
            title: const Text('Hapus', style: TextStyle(color: Colors.white)),
            content: const Text('Yakin mau hapus item ini?',
                style: TextStyle(color: Colors.white)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text('Batal', style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // bisa tambahin delete logic disini
                },
                child:
                    const Text('Hapus', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }
}
