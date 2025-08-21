import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hr/components/dialog/detail_item.dart';
import 'package:hr/components/dialog/show_confirmation.dart';
import 'package:hr/components/tabel/main_tabel.dart';
import 'package:hr/core/theme.dart';
import 'package:hr/presentation/pages/absen/absen_form/map/map_page.dart';
import 'package:latlong2/latlong.dart';
import 'package:video_player/video_player.dart';

class AbsenTabel extends StatelessWidget {
  final XFile? lastVideo;
  const AbsenTabel({super.key, required this.lastVideo});
  final List<String> headers = const [
    "Nama",
    "Tanggal",
    "Tipe",
    "Jam Masuk",
    "Jam Keluar",
    "Lokasi",
    "Video",
    "Keterangan",
  ];

  final List<List<String>> rows = const [
    [
      "Elon Musk",
      "12 / 10 / 2025",
      "Clock In",
      "08 : 00",
      "17 : 00",
      "1.1249392078070048, 104.02907149120136",
      "See Photo",
      "jadi tadi telat dikit trus blablabla",
    ],
    // Tambah row lain kalo perlu
  ];
  @override
  Widget build(BuildContext context) {
    return CustomDataTableWidget(
      headers: headers,
      rows: rows,
      statusColumnIndexes: null,
      onCellTap: (rowIndex, colIndex) {
        if (colIndex == 5) {
          // Ambil string latlong
          final latlongStr = rows[rowIndex][colIndex];
          try {
            final parts = latlongStr.split(',');
            final lat = double.parse(parts[0].trim());
            final lng = double.parse(parts[1].trim());

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MapPage(
                  target: LatLng(lat, lng),
                ),
              ),
            );
          } catch (e) {
            print("Format latlong salah: $latlongStr");
          }
        } else if (colIndex == 6) {
          if (lastVideo != null) {
            showDialog(
              context: context,
              builder: (ctx) {
                final controller =
                    VideoPlayerController.file(File(lastVideo!.path));
                return FutureBuilder(
                  future: controller.initialize(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AspectRatio(
                          aspectRatio: controller.value.aspectRatio,
                          child: VideoPlayer(controller),
                        ),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                );
              },
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Belum ada rekaman video men")),
            );
          }
        }
      },
      onView: (rowIndex) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Detail Absen',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(headers.length, (index) {
                final value = rows[rowIndex][index];
                return DetailItem(
                  label: headers[index],
                  value: value,
                );
              }),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Tutup',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
      onDelete: (rowIndex) async {
        final confirmed = await showConfirmationDialog(
          context,
          title: "Hapus",
          content: "Yakin mau hapus item ini?",
          confirmText: "Hapus",
          cancelText: "Batal",
          confirmColor: AppColors.red,
        );

        if (confirmed) {
          // logic delete disini
          print("Row $rowIndex dihapus");
        }
      },
    );
  }
}
