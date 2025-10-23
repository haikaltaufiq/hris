import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/utils/device_size.dart';

class CustomDataTableWeb extends StatefulWidget {
  final List<String> headers;
  final List<List<String>> rows;
  final List<int>? statusColumnIndexes;
  final List<int>? dropdownStatusColumnIndexes;
  final List<String>? statusOptions;
  final List<int>? textLengthLimits;
  final List<int>? columnFlexValues;
  final Function(int row, int col, int actualRowIndex)? onCellTap;
  final Function(int actualRowIndex)? onView;
  final Function(int actualRowIndex)? onEdit;
  final Function(int actualRowIndex)? onDelete;
  final Function(int row, String value)? onStatusChanged;
  final Function(int actualRowIndex)? onTapLampiran;

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

  @override
  State<CustomDataTableWeb> createState() => _CustomDataTableWebState();
}

class _CustomDataTableWebState extends State<CustomDataTableWeb> {
  int currentPage = 0;
  static const int rowsPerPage = 10;

  List<List<String>> get paginatedRows {
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, widget.rows.length);
    return widget.rows.sublist(start, end);
  }

  /// Convert paginated row index to actual row index in full list
  int _getActualRowIndex(int paginatedRowIndex) {
    return (currentPage * rowsPerPage) + paginatedRowIndex;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
      case 'approved':
      case 'sudah dibayar':
      case 'disetujui':
        return Colors.green;
      case 'proses':
      case 'pending':
      case 'belum dibayar':
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

  void _showStatusDropdown(BuildContext context, String currentStatus,
      int paginatedRowIndex, int colIndex) {
    final actualRowIndex = _getActualRowIndex(paginatedRowIndex);

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

    final statusList =
        widget.statusOptions ?? ['approved', 'pending', 'rejected'];
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
        widget.onStatusChanged?.call(actualRowIndex, selectedStatus);
      }
    });
  }

  Widget _buildValueCell(
      BuildContext context, String value, int paginatedRowIndex, int colIndex) {
    final actualRowIndex = _getActualRowIndex(paginatedRowIndex);

    if (widget.dropdownStatusColumnIndexes != null &&
        widget.dropdownStatusColumnIndexes!.contains(colIndex)) {
      final color = _getStatusColor(value);
      return Align(
        alignment: Alignment.centerLeft,
        child: IntrinsicWidth(
          child: Builder(
            builder: (context) => Tooltip(
              message: value,
              waitDuration: const Duration(milliseconds: 300),
              child: InkWell(
                onTap: () {
                  widget.onCellTap
                      ?.call(paginatedRowIndex, colIndex, actualRowIndex);
                  _showStatusDropdown(
                      context, value, paginatedRowIndex, colIndex);
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

    if (widget.statusColumnIndexes != null &&
        widget.statusColumnIndexes!.contains(colIndex)) {
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

    if (value.toLowerCase() == "lihat lampiran" ||
        value.toLowerCase() == "see photo" ||
        value.toLowerCase() == "see video" ||
        value.toLowerCase() == "view attachment") {
      if (widget.onTapLampiran != null) {
        return Tooltip(
          message: value,
          waitDuration: const Duration(milliseconds: 300),
          child: GestureDetector(
            onTap: () => widget.onTapLampiran!(actualRowIndex),
            child: Text(
              value,
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                fontFamily: GoogleFonts.poppins().fontFamily,
              ),
              overflow: TextOverflow.clip,
            ),
          ),
        );
      }
    }

    return Tooltip(
      message: value,
      waitDuration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: () =>
            widget.onCellTap?.call(paginatedRowIndex, colIndex, actualRowIndex),
        child: Text(
          value,
          style: TextStyle(
            color: AppColors.putih,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: GoogleFonts.poppins().fontFamily,
          ),
          overflow: TextOverflow.clip,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (widget.rows.length / rowsPerPage).ceil();

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
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
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.secondary,
                      width: 2,
                    ),
                  ),
                ),
                padding: const EdgeInsets.only(bottom: 15, top: 10),
                child: Row(
                  children: [
                    ...widget.headers.asMap().entries.map((entry) {
                      int flexValue = 1;
                      if (widget.columnFlexValues != null &&
                          entry.key < widget.columnFlexValues!.length) {
                        flexValue = widget.columnFlexValues![entry.key];
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
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily: GoogleFonts.poppins().fontFamily,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    if (widget.onView != null ||
                        widget.onEdit != null ||
                        widget.onDelete != null)
                      SizedBox(
                        width: 120,
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
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: paginatedRows.length,
                separatorBuilder: (_, __) => Divider(
                  color: AppColors.secondary,
                  thickness: 0.5,
                  height: 1,
                ),
                itemBuilder: (context, paginatedRowIndex) {
                  final row = paginatedRows[paginatedRowIndex];
                  final actualRowIndex = _getActualRowIndex(paginatedRowIndex);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ...row.asMap().entries.map((entry) {
                          int flexValue = 1;
                          if (widget.columnFlexValues != null &&
                              entry.key < widget.columnFlexValues!.length) {
                            flexValue = widget.columnFlexValues![entry.key];
                          }
                          return Expanded(
                            flex: flexValue,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: _buildValueCell(
                                context,
                                entry.value,
                                paginatedRowIndex,
                                entry.key,
                              ),
                            ),
                          );
                        }),
                        if (widget.onView != null ||
                            widget.onEdit != null ||
                            widget.onDelete != null)
                          SizedBox(
                            width: context.isMobile ? 160 : 120,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.onView != null)
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
                                        onPressed: () =>
                                            widget.onView!(actualRowIndex),
                                      ),
                                    ),
                                  if (widget.onEdit != null)
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
                                        onPressed: () =>
                                            widget.onEdit!(actualRowIndex),
                                      ),
                                    ),
                                  if (widget.onDelete != null)
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
                                        onPressed: () =>
                                            widget.onDelete!(actualRowIndex),
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
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: AppColors.putih,
              ),
              onPressed: currentPage > 0
                  ? () {
                      setState(() {
                        currentPage--;
                      });
                    }
                  : null,
            ),
            Text(
              "${currentPage + 1} / $totalPages",
              style: TextStyle(
                color: AppColors.putih,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.chevron_right,
                color: AppColors.putih,
              ),
              onPressed: currentPage < totalPages - 1
                  ? () {
                      setState(() {
                        currentPage++;
                      });
                    }
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}
