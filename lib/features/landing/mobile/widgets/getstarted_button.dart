import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme/app_colors.dart';
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
  void _showLoginSheet(BuildContext context) {
    if (context.isNativeMobile) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withOpacity(0.5), // Darker background
        transitionAnimationController: AnimationController(
          duration: const Duration(milliseconds: 600), // Slower, smoother animation
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

    return Positioned(
      top: widget.topMargin,
      left: 0,
      right: 0,
      child: Center(
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: GestureDetector(
            onTap: () => _showLoginSheet(context),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              width: width * 0.85,
              height: width * 0.14,
              decoration: BoxDecoration(
                color: _isHovering
                    ? AppColors.blue.withOpacity(0.85)
                    : AppColors.blue,
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
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
