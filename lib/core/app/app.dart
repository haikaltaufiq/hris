import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/theme/theme_provider.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/data/services/pengaturan_service.dart';
import 'package:hr/l10n/app_localizations.dart';
import 'package:hr/main.dart';
import 'package:hr/routes/app_routes.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<String> _initialRoute;

  @override
  void initState() {
    super.initState();
    _initialRoute = _getInitialRoute();
  }

  Future<String> _getInitialRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      await _loadUserSettings(token);
    }

    if (context.isNativeMobile) {
      return token != null && token.isNotEmpty
          ? AppRoutes.dashboardMobile
          : AppRoutes.landingPageMobile;
    } else {
      return token != null && token.isNotEmpty
          ? AppRoutes.dashboard
          : AppRoutes.landingPage;
    }
  }

  Future<void> _loadUserSettings(String token) async {
    try {
      final pengaturanService = PengaturanService();
      final pengaturan = await pengaturanService.getPengaturan(token);

      final tema = pengaturan['tema'] ?? 'terang';
      final bahasa = pengaturan['bahasa'] ?? 'indonesia';

      if (mounted) {
        final themeProvider =
            Provider.of<ThemeProvider>(context, listen: false);
        final langProvider =
            Provider.of<LanguageProvider>(context, listen: false);

        themeProvider.setDarkMode(tema == 'gelap');
        langProvider.toggleLanguage(bahasa == 'indonesia');
      }
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        final themeProvider =
            Provider.of<ThemeProvider>(context, listen: false);
        final langProvider =
            Provider.of<LanguageProvider>(context, listen: false);

        themeProvider.setDarkMode(prefs.getBool('isDarkMode') ?? false);
        langProvider.toggleLanguage(prefs.getString('bahasa') == 'indonesia');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _initialRoute,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const ColoredBox(color: Colors.black);
        }

        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              themeMode: themeProvider.currentMode,
              theme: ThemeData(
                textTheme: GoogleFonts.poppinsTextTheme(),
              ),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              initialRoute: snapshot.data!,
              onGenerateRoute: AppRoutes.generateRoute,
              onUnknownRoute: (_) => MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(child: Text("404 Page Not Found")),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
