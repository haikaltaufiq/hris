import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/features/auth/mobile/login_page_sheet.dart';
import 'package:hr/routes/app_routes.dart';

class GetStartedButton extends StatefulWidget {
  final double topMargin;
  const GetStartedButton({super.key, required this.topMargin});

  @override
  State<GetStartedButton> createState() => _GetStartedButtonState();
}

class _GetStartedButtonState extends State<GetStartedButton>
    with TickerProviderStateMixin {
  bool _isHovering = false;
  bool _isPressed = false;

  void _showLoginSheet(BuildContext context) {
    if (context.isNativeMobile) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionAnimationController: AnimationController(
          duration: const Duration(milliseconds: 600),
          vsync: this,
        ),
        builder: (context) => const LoginPageSheet(),
      );
    } else {
      Navigator.pushNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => _showLoginSheet(context),
        onHover: (hovering) {
          if (!context.isNativeMobile) {
            setState(() => _isHovering = hovering);
          }
        },
        onHighlightChanged: (pressed) {
          if (context.isNativeMobile) {
            setState(() => _isPressed = pressed);
          }
        },
        child: AnimatedScale(
          scale: _isHovering || _isPressed ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: width * 0.85,
            height: width * 0.14,
            decoration: BoxDecoration(
              color: _isHovering || _isPressed
                  ? const Color.fromARGB(255, 7, 12, 27)
                  : const Color.fromRGBO(19, 33, 75, 1),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(2, 2),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Text(
                'Get Started',
                style: TextStyle(
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontSize: width * 0.04,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
