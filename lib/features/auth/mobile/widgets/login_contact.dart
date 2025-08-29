import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginContact extends StatelessWidget {
  const LoginContact({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Dont have an account?',
              style: TextStyle(
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontSize: 12,
                color: const Color.fromARGB(183, 224, 224, 224),
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              '  Contact Admin.',
              style: TextStyle(
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontSize: 12,
                color: const Color.fromARGB(255, 224, 224, 224),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
