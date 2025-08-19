import 'package:flutter/material.dart';
import 'package:hr/presentation/pages/landing/landing_page.dart';
import 'package:hr/provider/function/cuti_provider.dart';
import 'package:hr/provider/function/lembur_provider.dart';
import 'package:hr/provider/function/potongan_gaji_provider.dart';
import 'package:hr/provider/function/tugas_provider.dart';
import 'package:hr/provider/function/user_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => LemburProvider()),
        ChangeNotifierProvider(create: (_) => CutiProvider()),
        ChangeNotifierProvider(create: (_) => PotonganGajiProvider()),
        ChangeNotifierProvider(create: (_) => TugasProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LandingPage(),
    );
  }
}
