import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/core/theme.dart';

class TentangPage extends StatefulWidget {
  const TentangPage({super.key});

  @override
  State<TentangPage> createState() => _TentangPageState();
}

class _TentangPageState extends State<TentangPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Header(title: "Tentang Perusahaan"),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.04,
            vertical: MediaQuery.of(context).size.height * 0.01,
          ),
          child: Container(
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AppColors.putih,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "PT Kreatif System Indonesia",
                          style: TextStyle(
                            color: AppColors.bg,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                          ),
                        ),
                        FaIcon(
                          FontAwesomeIcons.pen,
                          color: AppColors.bg,
                          size: 15,
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 200,
                      child: Text(
                        "Ruko, Jl. Palm Spring No.B3 No 15, Taman Baloi, Batam Kota, Batam City, Riau Islands",
                        style: TextStyle(
                          color: AppColors.bg,
                          fontSize: 12,
                          fontWeight: FontWeight.w200,
                          fontFamily: GoogleFonts.poppins().fontFamily,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "About this Company",
                          style: TextStyle(
                            color: AppColors.bg,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                          ),
                        ),
                        Text(
                          "PT. KREATIF SYSTEM INDONESIA (KREASII), is a company engaged in Information Technology (IT) that serves small, medium and large companies, both private and government as well as various other industries. As a service company engaged in IT, we provide trusted service and consulting solutions to companies that use our services, where we always prioritize quality and trust and the best service for a harmonious and sustainable business continuity.",
                          style: TextStyle(
                            color: AppColors.bg,
                            fontSize: 11,
                            fontWeight: FontWeight.w200,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Our Service",
                          style: TextStyle(
                            color: AppColors.bg,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                          ),
                        ),
                        Text(
                          "CCTV, HDCVI, Audio Paging, IP Camera, PBAX System",
                          style: TextStyle(
                            color: AppColors.bg,
                            fontSize: 12,
                            fontWeight: FontWeight.w200,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Employee",
                          style: TextStyle(
                            color: AppColors.bg,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                          ),
                        ),
                        Text(
                          "30",
                          style: TextStyle(
                            color: AppColors.bg,
                            fontSize: 12,
                            fontWeight: FontWeight.w200,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              )),
        )
      ],
    );
  }
}
