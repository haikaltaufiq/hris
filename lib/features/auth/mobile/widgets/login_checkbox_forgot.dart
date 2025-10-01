import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginCheckboxAndForgot extends StatelessWidget {
  const LoginCheckboxAndForgot({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: screenWidth * 0.85,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Forgot Password?',
            style: TextStyle(
              fontFamily: GoogleFonts.poppins().fontFamily,
              fontSize: 13,
              color: const Color.fromARGB(183, 224, 224, 224),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
