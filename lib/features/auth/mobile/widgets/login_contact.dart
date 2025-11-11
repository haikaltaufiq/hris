import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginContact extends StatelessWidget {
  const LoginContact({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Center(
        child: GestureDetector(
          onTap: () async {
            final Uri telUri =
                Uri(scheme: 'tel', path: "0778 2140088"); // ganti nomor kantor
            if (await canLaunchUrl(telUri)) {
              await launchUrl(telUri);
            } else {
              final message = context.isIndonesian
                  ? "Tidak dapat membuka dialer"
                  : "Can't open the phone";
              // debugPrint("Failed to open dialer");
              NotificationHelper.showTopNotification(context, message,
                  isSuccess: false);
            }
          },
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
      ),
    );
  }
}
