import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/core/theme.dart';
import 'package:hr/presentation/pages/potongan/potongan_form/potongan_form.dart';
import 'package:hr/presentation/pages/potongan/widget/potongan_tabel.dart';

class PotonganPage extends StatefulWidget {
  const PotonganPage({super.key});

  @override
  State<PotonganPage> createState() => _PotonganPageState();
}

class _PotonganPageState extends State<PotonganPage> {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Header(title: "Potongan"),
            SearchingBar(
              controller: searchController,
              onChanged: (value) {
                // You can implement search functionality here
                // context.read<TugasProvider>().searchTugas(value);
                print("Search Halaman A: $value");
              },
              onFilter1Tap: () => print("Filter1 Halaman A"),
            ),
            PotonganTabel(),
            PotonganTabel(),
            PotonganTabel(),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PotonganForm()),
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
