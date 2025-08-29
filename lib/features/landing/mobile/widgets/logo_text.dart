import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogoText extends StatelessWidget {
  final double topMargin;
  const LogoText({super.key, required this.topMargin});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: topMargin,
      left: 0,
      right: 0,
      child: Center(
        child: Text(
          'HRIS',
          style: TextStyle(
            fontFamily: GoogleFonts.poppins().fontFamily,
            fontSize: MediaQuery.of(context).size.width * 0.15,
            color: const Color.fromRGBO(224, 224, 224, 1),
            height: 1.2,
            letterSpacing: -2.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
