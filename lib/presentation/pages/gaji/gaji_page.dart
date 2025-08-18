import 'package:flutter/material.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/presentation/pages/gaji/widgets/gaji_count.dart';
import 'package:hr/presentation/pages/gaji/widgets/gaji_tabel.dart';
import 'package:hr/components/search_bar/search_bar.dart';

class GajiPage extends StatefulWidget {
  const GajiPage({super.key});

  @override
  State<GajiPage> createState() => _GajiPageState();
}

class _GajiPageState extends State<GajiPage> {
  final searchController = TextEditingController(); // value awal

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Header(title: 'Manajemen Gaji'),
        SearchingBar(
          controller: searchController,
          onChanged: (value) {
            print("Search Halaman A: $value");
          },
          onFilter1Tap: () => print("Filter1 Halaman A"),
        ),
        const GajiCount(),
        const GajiTabel(),
        const GajiTabel(),
      ],
    );
  }
}
