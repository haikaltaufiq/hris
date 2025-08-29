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
        children: [
          Checkbox(
            value: false,
            onChanged: (value) {},
            activeColor: Colors.white,
            checkColor: Colors.black,
            side: BorderSide(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Text(
            'Remember me',
            style: TextStyle(
              fontFamily: GoogleFonts.poppins().fontFamily,
              fontSize: 13,
              color: const Color.fromARGB(183, 224, 224, 224),
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
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
