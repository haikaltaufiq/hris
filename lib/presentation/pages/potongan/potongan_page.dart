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
                // Implementasi fitur search nanti
                print("Search Potongan: $value");
              },
              onFilter1Tap: () => print("Filter Potongan"),
            ),
            const SizedBox(height: 16),
            const PotonganTabel(),
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
