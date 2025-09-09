// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get helloText => 'Hello World';

  @override
  String get loginButton => 'Login';

  @override
  String get appTitle => 'Human Resource Information System';

  @override
  String get subtitleApp =>
      'The HRIS application is designed to simplify the management of attendance, leave, overtime, and employee tasks efficiently and centrally. Featuring a modern interface and intuitive navigation, HRIS streamlines HR administration processes all at your fingertips';

  @override
  String get landingWelcome => 'Human Resource Information System';

  @override
  String get landingDescription =>
      'An integrated HRIS solution that automates workforce management, all in one platform.';

  @override
  String get footerText => 'All rights reserved';
}
