import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginInputField extends StatefulWidget {
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
  State<LoginInputField> createState() => _LoginInputFieldState();
}

class _LoginInputFieldState extends State<LoginInputField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: screenWidth * 0.75,
          child: Text(
            widget.label,
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
          child: Center(
            child: TextField(
              controller: widget.controller,
              obscureText: _obscureText,
              style: TextStyle(
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontSize: 14,
                color: const Color.fromARGB(183, 224, 224, 224),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontSize: 14,
                  color: const Color.fromARGB(183, 224, 224, 224),
                ),
                suffixIcon: widget.isPassword
                    ? IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey[400],
                        ),
                        onPressed: _toggleVisibility,
                        splashRadius: 20,
                      )
                    : null,
                // Key fix: isDense removes internal padding
                isDense: true,
                // Padding yang presisi untuk center sempurna
                contentPadding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 19,
                  bottom: 19,
                ),
                // Ensure suffix icon is centered properly
                suffixIconConstraints: widget.isPassword
                    ? const BoxConstraints(
                        minWidth: 58,
                        minHeight: 58,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
