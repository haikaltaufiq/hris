import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogoText extends StatelessWidget {
  const LogoText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
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
    );
  }
}
