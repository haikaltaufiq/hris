import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hr/core/helpers/feature_guard.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/theme/theme_provider.dart';
import 'package:hr/data/models/user_model.dart';
import 'package:hr/data/services/auth_service.dart';
import 'package:hr/data/services/pengaturan_service.dart';
import 'package:hr/features/auth/web/forget_page.dart';
import 'package:hr/l10n/app_localizations.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/device_size.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // 🔥 FocusNode untuk handling keyboard events
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  List<String> _savedEmails = [];
  List<String> _filteredEmails = [];

  @override
  void initState() {
    super.initState();
    _loadSavedEmails();
  }

  Future<void> _loadSavedEmails() async {
    final prefs = await SharedPreferences.getInstance();
    _savedEmails = prefs.getStringList('saved_emails') ?? [];
  }

  void _filterEmails(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredEmails = [];
      } else {
        _filteredEmails = _savedEmails
            .where((e) => e.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  // 🔥 Method untuk handle login (extracted untuk reusability)
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final auth = AuthService();
      final result = await auth.login(email, password);

      if (result['success'] == true && result['token'] != null) {
        final token = result['token'];
        final user = result['user'] as UserModel?;

        if (user != null) {
          final userBox = await Hive.openBox('user');
          await userBox.put('token', token);
          await userBox.put('id', user.id);

          final fiturList = user.peran.fitur.map((f) => f.toJson()).toList();
          await FeatureAccess.setFeatures(fiturList);
          await FeatureAccess.init();

          await auth.saveEmail(user.email);
        }

        if (context.mounted) {
          await _loadAndSyncSettings(context, token);
        }

        NotificationHelper.showTopNotification(
          context,
          result['message'],
          isSuccess: true,
        );
        Navigator.pushNamed(context, AppRoutes.dashboard);

        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        NotificationHelper.showTopNotification(
          context,
          result['message'] ?? 'Invalid email or password',
          isSuccess: false,
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (context.isMobile) {
              return _buildMobileLayout(context, l10n);
            } else {
              return _buildDesktopLayout(context, l10n);
            }
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 48),
              _buildLoginForm(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        // Left side - Branding
        Expanded(
          child: Container(
            color: AppColors.blue,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.putih.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      Icons.business_center_outlined,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Human Resource',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -1.5,
                    ),
                  ),
                  Text(
                    'Information System',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 0.8,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Text(
                      'An integrated HRIS solution that automates workforce management, all in one platform.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w200,
                        color: Colors.white.withOpacity(0.6),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Right side - Login Form
        Expanded(
          child: Container(
            color: Color(0xFFF7F7F7),
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(48.0),
                  child: Column(
                    children: [
                      _buildHeader(context, showLogo: false),
                      const SizedBox(height: 48),
                      _buildLoginForm(context, l10n),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, {bool showLogo = true}) {
    return Column(
      children: [
        if (showLogo) ...[
          const SizedBox(height: 102),
        ],
        Text(
          'Welcome',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to your account to continue',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context, AppLocalizations l10n) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEmailField(context),
          const SizedBox(height: 20),
          _buildPasswordField(context),
          const SizedBox(height: 16),
          _buildRememberMeAndForgotPassword(context),
          const SizedBox(height: 32),
          _buildLoginButton(context, l10n),
          const SizedBox(height: 32),
          _buildSignUpLink(context),
        ],
      ),
    );
  }

  Widget _buildEmailField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            // 🔥 AutofillGroup untuk Google Password Manager
            AutofillGroup(
              child: TextFormField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                keyboardType: TextInputType.emailAddress,
                // 🔥 Autofill hints untuk email
                autofillHints: const [
                  AutofillHints.email,
                  AutofillHints.username,
                ],
                // 🔥 Handle Enter key - pindah ke password field
                onFieldSubmitted: (value) {
                  FocusScope.of(context).requestFocus(_passwordFocusNode);
                },
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.blue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                onChanged: (val) {
                  _filterEmails(val);
                },
              ),
            ),
            if (_filteredEmails.isNotEmpty)
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    children: _filteredEmails
                        .map((e) => ListTile(
                              title: Text(e),
                              onTap: () {
                                _emailController.text = e;
                                setState(() {
                                  _filteredEmails = [];
                                });
                              },
                            ))
                        .toList(),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        // 🔥 Wrap dengan RawKeyboardListener untuk custom keyboard handling
        RawKeyboardListener(
          focusNode: FocusNode(),
          onKey: (RawKeyEvent event) {
            // Handle Enter key press
            if (event is RawKeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.enter) {
              _handleLogin();
            }
          },
          child: TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            obscureText: !_isPasswordVisible,
            // 🔥 Autofill hints untuk password
            autofillHints: const [AutofillHints.password],
            // 🔥 Handle Enter key - trigger login
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (value) {
              _handleLogin();
            },
            decoration: InputDecoration(
              hintText: 'Enter your password',
              prefixIcon: Icon(Icons.lock_outline, color: AppColors.blue),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.blue,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.blue, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRememberMeAndForgotPassword(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ForgetPage(),
              ),
            );
          },
          child: Text(
            'Forgot Password?',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? () {} : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: AppColors.blue,
          padding: const EdgeInsets.symmetric(vertical: 22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _loadAndSyncSettings(BuildContext context, String token) async {
    try {
      final pengaturanService = PengaturanService();
      final pengaturan = await pengaturanService.getPengaturan(token);

      final tema = pengaturan['tema'] ?? 'terang';
      final bahasa = pengaturan['bahasa'] ?? 'indonesia';

      print(' Login - Pengaturan loaded: tema=$tema, bahasa=$bahasa');

      if (context.mounted) {
        final themeProvider =
            Provider.of<ThemeProvider>(context, listen: false);
        final langProvider =
            Provider.of<LanguageProvider>(context, listen: false);

        themeProvider.setDarkMode(tema == 'gelap');
        langProvider.toggleLanguage(bahasa == 'indonesia');
      }
    } catch (e) {
      print(' Login - Gagal load pengaturan: $e');
    }
  }

  Widget _buildSignUpLink(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: GestureDetector(
                onTap: () async {
                  final Uri telUri = Uri(scheme: 'tel', path: "0778 2140088");
                  if (await canLaunchUrl(telUri)) {
                    await launchUrl(telUri);
                  } else {
                    debugPrint("Failed to open dialer");
                    NotificationHelper.showTopNotification(
                        context, "Can't open the phone",
                        isSuccess: false);
                  }
                },
                child: Text(
                  'Contact Us',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Column(
          children: [
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: GestureDetector(
                onTap: () async {
                  final Uri mailUri = Uri(
                    scheme: 'mailto',
                    path: 'hris.ksi@kreatifsystem.com',
                    query: Uri.encodeQueryComponent(
                        'subject=Support&body=Halo HRIS Team'),
                  );

                  if (await canLaunchUrl(mailUri)) {
                    await launchUrl(mailUri);
                  } else {
                    debugPrint("Failed to open email client");
                    NotificationHelper.showTopNotification(
                      context,
                      "Can't open the email client",
                      isSuccess: false,
                    );
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.email, size: 16, color: AppColors.blue),
                    SizedBox(width: 10),
                    Text(
                      'hris.ksi@kreatifsystem.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: GestureDetector(
                onTap: () async {
                  final Uri telUri = Uri(scheme: 'tel', path: "0778 2140088");
                  if (await canLaunchUrl(telUri)) {
                    await launchUrl(telUri);
                  } else {
                    debugPrint("Failed to open dialer");
                    NotificationHelper.showTopNotification(
                        context, "Can't open the phone",
                        isSuccess: false);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone, size: 16, color: AppColors.blue),
                    SizedBox(width: 10),
                    Text(
                      '0778 214 0088',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
