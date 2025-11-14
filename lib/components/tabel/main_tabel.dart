import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme/app_colors.dart';

class CustomDataTableWidget extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> rows;
  final List<int>? statusColumnIndexes;
  final List<int>? dropdownStatusColumnIndexes;
  final List<String>? statusOptions;
  final Function(int row, int col)? onCellTap;
  final Function(int row)? onView;
  final Function(int row)? onEdit;
  final Function(int row)? onDelete;
  final Function(int row)? onTapLampiran;
  final Function(int row, String newStatus)? onStatusChanged;

  const CustomDataTableWidget({
    super.key,
    required this.headers,
    required this.rows,
    this.statusColumnIndexes,
    this.dropdownStatusColumnIndexes,
    this.statusOptions,
    this.onCellTap,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.onTapLampiran,
    this.onStatusChanged,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
      case 'approved':
      case 'disetujui':
      case 'completed':
        return Colors.green;
      case 'proses':
      case 'pending':
      case 'menunggu':
      case 'processing':
        return Colors.orange;
      case 'ditolak':
      case 'rejected':
      case 'unknown':
      case 'terlambat':
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showStatusDropdown(
      BuildContext context, String currentStatus, int rowIndex, int colIndex) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

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

    final statusList = statusOptions ?? ['approved', 'pending', 'rejected'];
    double maxTextWidth = 0;

    for (String status in statusList) {
      double textWidth = calculateTextWidth(status);
      if (textWidth > maxTextWidth) {
        maxTextWidth = textWidth;
      }
    }

    final dropdownWidth = maxTextWidth + 36;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + dropdownWidth,
        offset.dy + size.height + 200,
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
          padding: EdgeInsets.zero,
          child: Container(
            width: dropdownWidth,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
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
                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    fontSize: 14,
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

  Widget _buildValueCell(
      BuildContext context, String value, int rowIndex, int colIndex) {
    if (dropdownStatusColumnIndexes != null &&
        dropdownStatusColumnIndexes!.contains(colIndex)) {
      final color = _getStatusColor(value);
      return Align(
        alignment: Alignment.centerLeft,
        child: IntrinsicWidth(
          child: Builder(
            builder: (context) => InkWell(
              onTap: () {
                onCellTap?.call(rowIndex, colIndex);
                _showStatusDropdown(context, value, rowIndex, colIndex);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                    Text(
                      value,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        fontFamily: GoogleFonts.poppins().fontFamily,
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
      );
    }

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
    final headerText = headers[colIndex].trim().toLowerCase();
    final isLampiranColumn =
        headerText.contains('lampiran') || headerText.contains('attachment');

    if (isLampiranColumn && onTapLampiran != null) {
      return GestureDetector(
        onTap: () => onTapLampiran!(rowIndex),
        child: Text(
          value,
          style: TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
            fontFamily: GoogleFonts.poppins().fontFamily,
          ),
        ),
      );
    }

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

  String firstTwoWords(String? text) {
    if (text == null || text.isEmpty) return '';
    final words = text.split(' ');
    if (words.length <= 2) return text;
    return '${words[0]} ${words[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rows.length,
      itemBuilder: (context, rowIndex) {
        final row = rows[rowIndex];

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.02,
            vertical: MediaQuery.of(context).size.height * 0.01,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (row.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            FaIcon(
                              FontAwesomeIcons.solidBookmark,
                              color: AppColors.putih,
                              size: 16,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                firstTwoWords(row[0]),
                                style: TextStyle(
                                  color: AppColors.putih,
                                  fontFamily: GoogleFonts.poppins().fontFamily,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (onView != null)
                            IconButton(
                              icon: FaIcon(
                                FontAwesomeIcons.eye,
                                color: AppColors.putih,
                                size: 16,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: const EdgeInsets.all(8),
                              onPressed: () => onView!(rowIndex),
                            ),
                          if (onEdit != null)
                            IconButton(
                              icon: FaIcon(
                                FontAwesomeIcons.pen,
                                color: AppColors.putih,
                                size: 16,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: const EdgeInsets.all(8),
                              onPressed: () => onEdit!(rowIndex),
                            ),
                          if (onDelete != null)
                            IconButton(
                              icon: FaIcon(
                                FontAwesomeIcons.trash,
                                color: AppColors.putih,
                                size: 16,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: const EdgeInsets.all(8),
                              onPressed: () => onDelete!(rowIndex),
                            ),
                        ],
                      ),
                    ],
                  ),
                Align(
                  alignment: Alignment.center,
                  child: FractionallySizedBox(
                    widthFactor: 1.09,
                    child: Divider(
                      color: AppColors.secondary,
                      thickness: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: headers.length,
                  separatorBuilder: (_, __) => Divider(
                    color: AppColors.secondary,
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
