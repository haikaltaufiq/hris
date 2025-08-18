import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/core/theme.dart';
import 'package:hr/presentation/pages/peran_akses/peran_form/peran_form.dart';
import 'package:hr/presentation/pages/peran_akses/widgets/peran_tabel.dart';

class PeranAksesPage extends StatefulWidget {
  const PeranAksesPage({super.key});

  @override
  State<PeranAksesPage> createState() => _PeranAksesPageState();
}

class _PeranAksesPageState extends State<PeranAksesPage> {
  final List<bool> akses = List.generate(9, (_) => false);
  final searchController = TextEditingController(); // value awal

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Header(title: 'Manajemen Peran & Akses'),
            SearchingBar(
              controller: searchController,
              onChanged: (value) {
                print("Search Halaman A: $value");
              },
              onFilter1Tap: () => print("Filter1 Halaman A"),
            ),
            PeranTabel(),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PeranForm(),
                ),
              );
            },
            backgroundColor: AppColors.secondary,
            shape: const CircleBorder(),
            child: FaIcon(FontAwesomeIcons.plus, color: AppColors.putih),
          ),
        ),
      ],
    );
  }
}
