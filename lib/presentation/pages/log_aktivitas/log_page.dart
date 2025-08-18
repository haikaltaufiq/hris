import 'package:flutter/material.dart';
import 'package:hr/components/search_bar/search_bar.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/presentation/pages/log_aktivitas/widgets/log_tabel.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final searchController = TextEditingController(); // value awal

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Header(title: 'Log Aktivitas'),
        SearchingBar(
          controller: searchController,
          onChanged: (value) {
            print("Search Halaman A: $value");
          },
          onFilter1Tap: () => print("Filter1 Halaman A"),
        ),
        const LogTabel(),
        const LogTabel(),
        const LogTabel(),
      ],
    );
  }
}
