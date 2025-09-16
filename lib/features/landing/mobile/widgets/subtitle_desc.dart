import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubtitleDescription extends StatelessWidget {
  final double startFrom;
  const SubtitleDescription({super.key, required this.startFrom});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Center(
      child: Column(
        children: [
          SizedBox(
            height: width * 0.28,
          ),
          Text(
            'Human Resource Information System',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: GoogleFonts.poppins().fontFamily,
              fontSize: width * 0.09,
              color: const Color.fromRGBO(224, 224, 224, 1),
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                ),
              ],
              fontWeight: FontWeight.w900,
              height: 1.1,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.14),
            child: Text(
              'The HRIS application is designed to simplify the management of attendance, leave, overtime, and employee tasks efficiently and centrally. Featuring a modern interface and intuitive navigation, HRIS streamlines HR administration processes all at your fingertips.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontSize: width * 0.025,
                color: const Color.fromARGB(180, 224, 224, 224),
                fontWeight: FontWeight.w100,
                height: 1.2,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(2, 2),
                    blurRadius: 5,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
