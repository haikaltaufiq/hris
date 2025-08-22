import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/header.dart';
import 'package:hr/core/theme.dart';

class InfoKantor extends StatefulWidget {
  const InfoKantor({super.key});

  @override
  State<InfoKantor> createState() => _InfoKantorState();
}

class _InfoKantorState extends State<InfoKantor> {
  Map<String, String> companyInfo = {
    'Company Name': 'PT. Kreatif System Indonesia',
    'Attendance Hours': '08:00 - 17:00',
    'Late Limitation': '08:10 (10 minutes)',
    'Location': 'Jl. Palm Spring, Ruko B3, Batam Center',
  };

  Map<String, IconData> infoIcons = {
    'Company Name': Icons.business,
    'Attendance Hours': Icons.access_time,
    'Late Limitation': Icons.warning_amber,
    'Location': Icons.location_on,
  };

  void _editInfo(String key, String currentValue) {
    TextEditingController controller =
        TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            'Edit $key',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.putih,
            ),
          ),
          content: TextField(
            controller: controller,
            style: GoogleFonts.poppins(color: AppColors.putih),
            maxLines: key == 'Location' ? 2 : 1,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.secondary.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.putih),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.putih, width: 2),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel',
                  style: GoogleFonts.poppins(color: AppColors.putih)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  companyInfo[key] = controller.text;
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Save',
                  style: GoogleFonts.poppins(color: AppColors.putih)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => _editInfo(title, value),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.putih, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.putih.withOpacity(0.9),
                          )),
                      const SizedBox(height: 4),
                      Text(value,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.putih,
                          )),
                    ],
                  ),
                ),
                Icon(Icons.edit,
                    color: AppColors.putih.withOpacity(0.8), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Header(title: "Info Kantor"),
        const SizedBox(height: 24),

        // Welcome card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.putih, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Manage your company information',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.putih,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'Company Details',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.putih,
          ),
        ),

        const SizedBox(height: 16),

        ...companyInfo.entries
            .map((entry) =>
                _buildInfoCard(entry.key, entry.value, infoIcons[entry.key]!))
            .toList(),

        const SizedBox(height: 24),

        // Quick tips card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline,
                      color: AppColors.putih, size: 24),
                  const SizedBox(width: 8),
                  Text('Quick Tips',
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.putih)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '• Tap any card above to edit the information\n• Keep your company details up to date\n• Late limitation helps manage punctuality',
                style: GoogleFonts.poppins(
                    fontSize: 14, color: AppColors.putih, height: 1.5),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}
