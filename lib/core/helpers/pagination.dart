import 'package:flutter/material.dart';
import 'package:hr/core/theme/app_colors.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int rowsPerPage;
  final int totalItems;
  final ValueChanged<int> onPageChanged;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.rowsPerPage,
    required this.totalItems,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final totalPages = (totalItems / rowsPerPage).ceil();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
        ),
        Text(
          '${currentPage + 1} / $totalPages',
          style: TextStyle(color: AppColors.putih),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: (currentPage + 1) * rowsPerPage < totalItems
              ? () => onPageChanged(currentPage + 1)
              : null,
        ),
      ],
    );
  }
}
