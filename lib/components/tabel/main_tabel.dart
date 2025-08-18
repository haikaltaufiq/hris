// Custom Data Table Widget - styled like TugasTabel
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme.dart';

// Custom Data Table Widget - styled like TugasTabel
class CustomDataTableWidget extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> rows;
  final List<int>? statusColumnIndexes;
  final Function(int row, int col)? onCellTap;
  final Function(int row)? onView;
  final Function(int row)? onEdit;
  final Function(int row)? onDelete;

  const CustomDataTableWidget({
    Key? key,
    required this.headers,
    required this.rows,
    this.statusColumnIndexes,
    this.onCellTap,
    this.onView,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
      case 'approved':
      case 'disetujui':
        return Colors.green;
      case 'proses':
      case 'pending':
      case 'menunggu':
        return Colors.orange;
      case 'ditolak':
      case 'rejected':
      case 'unknown':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildValueCell(
      BuildContext context, String value, int rowIndex, int colIndex) {
    // Status column styling - check if current column is in statusColumnIndexes
    if (statusColumnIndexes != null &&
        statusColumnIndexes!.contains(colIndex)) {
      final color = _getStatusColor(value);
      return Align(
        alignment: Alignment.centerLeft,
        child: IntrinsicWidth(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Regular cell
    return GestureDetector(
      onTap: () => onCellTap?.call(rowIndex, colIndex),
      child: Text(
        value,
        style: TextStyle(
          color: AppColors.putih,
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rows.length,
      itemBuilder: (context, rowIndex) {
        final row = rows[rowIndex];

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.02,
            vertical: MediaQuery.of(context).size.height * 0.01,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(56, 5, 5, 5),
                  blurRadius: 5,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section with first row data and action buttons
                if (row.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: false,
                            onChanged:
                                (value) {}, // You can implement checkbox logic
                            side: BorderSide(color: AppColors.putih),
                            checkColor: Colors.black,
                            activeColor: AppColors.putih,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            row[0], // First column as header
                            style: TextStyle(
                              color: AppColors.putih,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (onView != null)
                            IconButton(
                              icon: FaIcon(
                                FontAwesomeIcons.eye,
                                color: AppColors.putih,
                                size: 20,
                              ),
                              onPressed: () => onView!(rowIndex),
                            ),
                          if (onView != null)
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.02),
                          if (onDelete != null)
                            IconButton(
                              icon: FaIcon(
                                FontAwesomeIcons.trash,
                                color: AppColors.putih,
                                size: 20,
                              ),
                              onPressed: () => onDelete!(rowIndex),
                            ),
                          if (onDelete != null)
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.02),
                          if (onEdit != null)
                            IconButton(
                              icon: FaIcon(
                                FontAwesomeIcons.pen,
                                color: AppColors.putih,
                                size: 20,
                              ),
                              onPressed: () => onEdit!(rowIndex),
                            ),
                        ],
                      ),
                    ],
                  ),

                // Divider
                Align(
                  alignment: Alignment.center,
                  child: FractionallySizedBox(
                    widthFactor: 1.09,
                    child: const Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Detail table
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: headers.length,
                  separatorBuilder: (_, __) => const Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              headers[index],
                              style: TextStyle(
                                color: AppColors.putih,
                                fontWeight: FontWeight.bold,
                                fontFamily: GoogleFonts.poppins().fontFamily,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: _buildValueCell(
                              context,
                              row[index],
                              rowIndex,
                              index,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
