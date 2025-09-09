import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hr/features/auth/mobile/widgets/login_button.dart';
import 'package:hr/features/auth/mobile/widgets/login_checkbox_forgot.dart';
import 'package:hr/features/auth/mobile/widgets/login_contact.dart';
import 'package:hr/features/auth/mobile/widgets/login_input_field.dart';
import 'package:hr/features/landing/mobile/widgets/logo_text.dart';

class LoginPageSheet extends StatefulWidget {
  const LoginPageSheet({super.key});

  @override
  State<LoginPageSheet> createState() => _LoginPageSheetState();
}

class _LoginPageSheetState extends State<LoginPageSheet> {
  late TextEditingController emailController;
  late TextEditingController passwordController;

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color.fromARGB(9, 0, 0, 0),
              ),
            ),
          ),
        ),
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: 92),
                        LogoText(topMargin: screenHeight * 0.1),
                        const SizedBox(height: 150),
                        LoginInputField(
                          label: 'Email',
                          hintText: 'Enter your email',
                          isPassword: false,
                          controller: emailController,
                        ),
                        const SizedBox(height: 12),
                        LoginInputField(
                          label: 'Password',
                          hintText: 'Enter your password',
                          isPassword: true,
                          controller: passwordController,
                        ),
                        const SizedBox(height: 10),
                        const LoginCheckboxAndForgot(),

                        if (errorMessage != null) ...[
                          Text(
                            errorMessage!,
                            style: const TextStyle(
                              color: Color(0xFFFF0033), // merah neon
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 1.0,
                                  color:
                                      Color(0xFFFF0033), // efek glow merah neon
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),

                        // tampilkan error langsung di login page
                        LoginButton(
                          emailController: emailController,
                          passwordController: passwordController,
                          onError: (msg) {
                            String notificationMsg = msg;
                            setState(() {
                              errorMessage = notificationMsg;
                            });
                          },
                        ),
                        const Spacer(),
                        const LoginContact(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
