import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginInputField extends StatelessWidget {
  final String label;
  final String hintText;
  final bool isPassword;
  final TextEditingController controller;

  const LoginInputField({
    super.key,
    required this.label,
    required this.hintText,
    required this.isPassword,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: screenWidth * 0.75,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: GoogleFonts.poppins().fontFamily,
              fontSize: 15,
              color: const Color.fromRGBO(224, 224, 224, 1),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: screenWidth * 0.85,
          height: 62,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(2, 2),
                blurRadius: 5,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: TextField(
              controller: controller,
              obscureText: isPassword,
              style: TextStyle(
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontSize: 14,
                color: const Color.fromARGB(183, 224, 224, 224),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontSize: 14,
                  color: const Color.fromARGB(183, 224, 224, 224),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
