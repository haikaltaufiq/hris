import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/utils/device_size.dart';

class CustomDataTableWeb extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> rows;
  final List<int>? statusColumnIndexes;
  final List<int>? dropdownStatusColumnIndexes;
  final List<String>? statusOptions;
  final List<int>? textLengthLimits; // New parameter for custom text limits
  final List<int>? columnFlexValues; // New parameter for custom flex values
  final Function(int row, int col)? onCellTap;
  final Function(int row)? onView;
  final Function(int row)? onEdit;
  final Function(int row)? onDelete;
  final Function(int row, String value)? onStatusChanged;
  final Function(int row)? onTapLampiran;

  const CustomDataTableWeb({
    super.key,
    required this.headers,
    required this.rows,
    this.statusColumnIndexes,
    this.dropdownStatusColumnIndexes,
    this.statusOptions,
    this.textLengthLimits,
    this.columnFlexValues,
    this.onCellTap,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.onStatusChanged,
    this.onTapLampiran,
  });

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

  void _showStatusDropdown(
      BuildContext context, String currentStatus, int rowIndex, int colIndex) {
    // Get the RenderBox of the tapped widget to position dropdown
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    // Calculate the required width based on content
    double calculateTextWidth(String text) {
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.poppins().fontFamily,
            fontSize: 14,
          ),
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();
      return textPainter.size.width;
    }

    // Find the longest status text to determine dropdown width
    final statusList = statusOptions ?? ['approved', 'pending', 'rejected'];
    double maxTextWidth = 0;

    for (String status in statusList) {
      double textWidth = calculateTextWidth(status);
      if (textWidth > maxTextWidth) {
        maxTextWidth = textWidth;
      }
    }

    // Add padding: circle (12) + spacing (8) + container padding (8) + small margin (8)
    final dropdownWidth = maxTextWidth + 36;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + dropdownWidth,
        offset.dy + size.height + 200, // Max height
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColors.secondary,
      elevation: 8,
      items: statusList.map((status) {
        final statusColor = _getStatusColor(status);
        return PopupMenuItem<String>(
          value: status,
          padding: EdgeInsets.zero, // Remove default PopupMenuItem padding
          child: Container(
            width: dropdownWidth,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 1),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 10),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ).then((selectedStatus) {
      if (selectedStatus != null && selectedStatus != currentStatus) {
        onStatusChanged?.call(rowIndex, selectedStatus);
      }
    });
  }

  String _shortenText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  Widget _buildValueCell(
      BuildContext context, String value, int rowIndex, int colIndex) {
    // Check if this is a dropdown status column
    if (dropdownStatusColumnIndexes != null &&
        dropdownStatusColumnIndexes!.contains(colIndex)) {
      final color = _getStatusColor(value);
      return Align(
        alignment: Alignment.centerLeft,
        child: IntrinsicWidth(
          child: Builder(
            // Use Builder to get correct context for positioning
            builder: (context) => Tooltip(
              message: value,
              waitDuration: const Duration(milliseconds: 300),
              child: InkWell(
                onTap: () {
                  // Call onCellTap if provided
                  onCellTap?.call(rowIndex, colIndex);
                  // Show dropdown with proper context
                  _showStatusDropdown(context, value, rowIndex, colIndex);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color, width: 1),
                    color: color.withOpacity(0.1),
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
                      Flexible(
                        child: Text(
                          value,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: color,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Check if this is a regular status column
    if (statusColumnIndexes != null &&
        statusColumnIndexes!.contains(colIndex)) {
      final color = _getStatusColor(value);
      return Align(
        alignment: Alignment.centerLeft,
        child: IntrinsicWidth(
          child: Tooltip(
            message: value,
            waitDuration: const Duration(milliseconds: 300),
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
                  Flexible(
                    child: Text(
                      value,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Check for lampiran by looking for specific text patterns (reusable)
    if (value.toLowerCase() == "lihat lampiran" ||
        value.toLowerCase() == "see photo" ||
        value.toLowerCase() == "see video" ||
        value.toLowerCase() == "view attachment") {
      if (onTapLampiran != null) {
        return Tooltip(
          message: value,
          waitDuration: const Duration(milliseconds: 300),
          child: GestureDetector(
            onTap: () => onTapLampiran!(rowIndex),
            child: Text(
              value,
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                fontFamily: GoogleFonts.poppins().fontFamily,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }
    }

    // Handle text length limits dynamically
    String displayText = value;

    // Use custom text limits if provided, otherwise use default of 25 characters
    int textLimit = 25; // Default limit
    if (textLengthLimits != null && colIndex < textLengthLimits!.length) {
      textLimit = textLengthLimits![colIndex];
    }

    if (value.length > textLimit) {
      displayText = _shortenText(value, textLimit);
    }

    // Regular cell with text overflow handling
    return Tooltip(
      message: value, // Always show full text on hover
      waitDuration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: () => onCellTap?.call(rowIndex, colIndex),
        child: Text(
          displayText,
          style: TextStyle(
            color: AppColors.putih,
            fontFamily: GoogleFonts.poppins().fontFamily,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // tipis banget
            blurRadius: 4, // kecil, biar soft
            spreadRadius: 0,
            offset: Offset(0, 1), // cuma bawah dikit
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Headers row
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.secondary,
                  width: 2,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                // Headers
                ...headers.asMap().entries.map((entry) {
                  // Use custom flex values if provided, otherwise default to 1
                  int flexValue = 1;
                  if (columnFlexValues != null &&
                      entry.key < columnFlexValues!.length) {
                    flexValue = columnFlexValues![entry.key];
                  }

                  return Expanded(
                    flex: flexValue,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Tooltip(
                        message: entry.value,
                        waitDuration: const Duration(milliseconds: 500),
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            color: AppColors.putih,
                            fontWeight: FontWeight.bold,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                // Action header - fixed width container
                if (onView != null || onEdit != null || onDelete != null)
                  SizedBox(
                    width: 120, // Reduced width for better spacing
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "Action",
                        style: TextStyle(
                          color: AppColors.putih,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.poppins().fontFamily,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Data rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rows.length,
            separatorBuilder: (_, __) => Divider(
              color: AppColors.secondary,
              thickness: 0.5,
              height: 1,
            ),
            itemBuilder: (context, rowIndex) {
              final row = rows[rowIndex];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Data cells
                    ...row.asMap().entries.map((entry) {
                      // Use custom flex values if provided, otherwise default to 1
                      int flexValue = 1;
                      if (columnFlexValues != null &&
                          entry.key < columnFlexValues!.length) {
                        flexValue = columnFlexValues![entry.key];
                      }

                      return Expanded(
                        flex: flexValue,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: _buildValueCell(
                            context,
                            entry.value,
                            rowIndex,
                            entry.key,
                          ),
                        ),
                      );
                    }),
                    // Action buttons - fixed width container
                    if (onView != null || onEdit != null || onDelete != null)
                      SizedBox(
                        width: context.isMobile ? 160 : 120,
                        // Reduced width for better spacing
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (onView != null)
                                Tooltip(
                                  message: 'View',
                                  child: IconButton(
                                    icon: FaIcon(
                                      FontAwesomeIcons.eye,
                                      color: AppColors.putih,
                                      size: 14,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    onPressed: () => onView!(rowIndex),
                                  ),
                                ),
                              if (onEdit != null)
                                Tooltip(
                                  message: 'Edit',
                                  child: IconButton(
                                    icon: FaIcon(
                                      FontAwesomeIcons.pen,
                                      color: AppColors.putih,
                                      size: 14,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    onPressed: () => onEdit!(rowIndex),
                                  ),
                                ),
                              if (onDelete != null)
                                Tooltip(
                                  message: 'Delete',
                                  child: IconButton(
                                    icon: FaIcon(
                                      FontAwesomeIcons.trash,
                                      color: AppColors.putih,
                                      size: 14,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    onPressed: () => onDelete!(rowIndex),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
