import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/helpers/feature_guard.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/data/models/dashboard_item.dart';

class DashboardMenu extends StatelessWidget {
  final List<DashboardMenuItem> items;

  const DashboardMenu({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    double iconSize = MediaQuery.of(context).size.width * 0.07;
    double fontSize = MediaQuery.of(context).size.width * 0.028;

    final accessibleItems =
        items.where((item) => FeatureAccess.has(item.requiredFeature)).toList();

    // Tentukan berapa kolom berdasarkan ukuran layar
    final crossAxisCount = MediaQuery.of(context).size.width < 360 ? 3 : 4;
    final maxItemsToShow = crossAxisCount * 2; // 2 rows

    // Pisahkan items yang akan ditampilkan dan yang disembunyikan
    final visibleItems = accessibleItems.length > maxItemsToShow
        ? accessibleItems.take(maxItemsToShow - 1).toList()
        : accessibleItems;

    final hiddenItems = accessibleItems.length > maxItemsToShow
        ? accessibleItems.skip(maxItemsToShow - 1).toList()
        : <DashboardMenuItem>[];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.04,
        vertical: MediaQuery.of(context).size.height * 0.01,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.isIndonesian ? "Layanan Kantor" : "Office Services",
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.045,
              color: AppColors.putih,
              fontFamily: GoogleFonts.poppins().fontFamily,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 24,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Tampilkan menu items yang visible
              ...visibleItems
                  .map((item) => _buildMenuItem(item, iconSize, fontSize)),

              // Tampilkan "More" button jika ada hidden items
              if (hiddenItems.isNotEmpty)
                _buildMoreButton(context, accessibleItems, iconSize, fontSize),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      DashboardMenuItem item, double iconSize, double fontSize) {
    return FeatureGuard(
      requiredFeature: item.requiredFeature,
      child: GestureDetector(
        onTap: item.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: iconSize * 1.8,
              width: iconSize * 1.8,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(item.icon, size: iconSize, color: AppColors.putih),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: fontSize,
                  color: AppColors.putih,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreButton(BuildContext context,
      List<DashboardMenuItem> allItems, double iconSize, double fontSize) {
    return GestureDetector(
      onTap: () => _showMoreBottomSheet(context, allItems),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: iconSize * 1.8,
            width: iconSize * 1.8,
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.grid_view_rounded,
              size: iconSize,
              color: const Color(0xFFD3D3D3),
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              context.isIndonesian ? "Lebih banyak" : "More",
              style: TextStyle(
                fontSize: fontSize,
                color: AppColors.putih,
                fontFamily: GoogleFonts.poppins().fontFamily,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreBottomSheet(
      BuildContext context, List<DashboardMenuItem> allItems) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MoreMenuBottomSheet(items: allItems),
    );
  }
}

class MoreMenuBottomSheet extends StatefulWidget {
  final List<DashboardMenuItem> items;

  const MoreMenuBottomSheet({super.key, required this.items});

  @override
  State<MoreMenuBottomSheet> createState() => _MoreMenuBottomSheetState();
}

class _MoreMenuBottomSheetState extends State<MoreMenuBottomSheet> {
  late DraggableScrollableController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DraggableScrollableController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.isIndonesian ? "Semua Layanan" : "All Services",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.putih,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: AppColors.putih,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Menu items list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    return _buildListMenuItem(context, item, index);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListMenuItem(
      BuildContext context, DashboardMenuItem item, int index) {
    final iconSize = MediaQuery.of(context).size.width * 0.06;
    final fontSize = MediaQuery.of(context).size.width * 0.038;

    return FeatureGuard(
      requiredFeature: item.requiredFeature,
      child: InkWell(
        onTap: () {
          Navigator.pop(context); // Tutup bottom sheet
          item.onTap.call(); // Panggil onTap item
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[100]!,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Icon container
              Container(
                height: iconSize * 1.4,
                width: iconSize * 1.4,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  item.icon,
                  size: iconSize,
                  color: AppColors.putih,
                ),
              ),

              const SizedBox(width: 16),

              // Text label
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: AppColors.putih,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),

              // Arrow icon
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
