import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/const/app_size.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResponsiveNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final bool isCollapsed;

  const ResponsiveNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.isCollapsed = false,
  });

  static const List<NavItem> _navItems = [
    NavItem(label: "Dashboard", icon: FontAwesomeIcons.house),
    NavItem(label: "Attendance", icon: FontAwesomeIcons.solidCalendarCheck),
    NavItem(label: "Task", icon: FontAwesomeIcons.listCheck),
    NavItem(label: "Over Time", icon: FontAwesomeIcons.solidClock),
    NavItem(label: "Leave", icon: FontAwesomeIcons.solidCalendarMinus),
    NavItem(label: "Employees", icon: FontAwesomeIcons.users),
    NavItem(label: "Payroll", icon: FontAwesomeIcons.moneyBill),
    NavItem(label: "Department", icon: FontAwesomeIcons.building),
    NavItem(label: "Position", icon: FontAwesomeIcons.idBadge),
    NavItem(label: "Access Rights", icon: FontAwesomeIcons.userShield),
    NavItem(label: "Salary Deduction", icon: FontAwesomeIcons.calculator),
    NavItem(label: "Company Info", icon: FontAwesomeIcons.info),
    NavItem(label: "Log Activity", icon: FontAwesomeIcons.history),
    NavItem(label: "Reminder", icon: FontAwesomeIcons.alarmClock),
    NavItem(label: "Settings", icon: FontAwesomeIcons.gear),
  ];

  static List<NavItem> get _mobileNavItems =>
      _navItems.length > 5 ? _navItems.sublist(0, 5) : _navItems;

  @override
  State<ResponsiveNavBar> createState() => _ResponsiveNavBarState();
}

class _ResponsiveNavBarState extends State<ResponsiveNavBar>
    with AutomaticKeepAliveClientMixin {
  static ScrollController? _scrollController;
  static double _lastScrollPosition = 0.0;
  static final PageStorageBucket _bucket = PageStorageBucket();
  static const String _scrollStorageKey = 'sidebar_scroll_position';

  String _nama = "";
  String _email = "";

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeScrollController();
    _loadUserData();
  }

  void _initializeScrollController() {
    if (_scrollController == null) {
      _scrollController =
          ScrollController(initialScrollOffset: _lastScrollPosition);

      // Listen untuk save scroll position
      _scrollController!.addListener(_saveScrollPosition);
    }

    // Restore scroll position setelah build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreScrollPosition();
    });
  }

  void _saveScrollPosition() {
    if (_scrollController != null && _scrollController!.hasClients) {
      _lastScrollPosition = _scrollController!.offset;

      // Simpan ke PageStorage juga
      PageStorage.of(context).writeState(
        context,
        _lastScrollPosition,
        identifier: _scrollStorageKey,
      );
    }
  }

  void _restoreScrollPosition() async {
    if (_scrollController == null || !_scrollController!.hasClients) return;

    // Coba restore dari PageStorage dulu
    final storedPosition = PageStorage.of(context).readState(
      context,
      identifier: _scrollStorageKey,
    );

    double targetPosition = _lastScrollPosition;
    if (storedPosition is double) {
      targetPosition = storedPosition;
    }

    // Pastikan position valid
    if (targetPosition > 0 &&
        targetPosition <= _scrollController!.position.maxScrollExtent) {
      await _scrollController!.animateTo(
        targetPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    // Jangan dispose static controller, tapi remove listener
    _scrollController?.removeListener(_saveScrollPosition);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    if (context.isMobile) {
      return _buildMobileBottomNav(context);
    } else {
      return _buildDesktopSidebar(context);
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _nama = prefs.getString('nama') ?? '';
        _email = prefs.getString('email') ?? '';
      });
    }
  }

  Widget _buildMobileBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.hitam,
        border: Border(
          top: BorderSide(
            color: Color(0xFF1a1a1a),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                ResponsiveNavBar._mobileNavItems.asMap().entries.map((entry) {
              int index = entry.key;
              NavItem item = entry.value;
              bool isSelected = index == widget.selectedIndex;

              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => widget.onItemTapped(index),
                    borderRadius: BorderRadius.circular(12),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: FaIcon(
                              item.icon,
                              size: 23,
                              color: isSelected ? Colors.white : Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopSidebar(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double sidebarWidth =
        widget.isCollapsed ? 70 : (screenWidth < 1024 ? 220 : 260);

    return Container(
      width: sidebarWidth,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF040404),
        border: Border(
          right: BorderSide(
            color: Color(0xFF1a1a1a),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSidebarHeader(context),
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: widget.isCollapsed ? 8 : AppSizes.paddingM,
            ),
            height: 1,
            color: const Color(0xFF1a1a1a),
          ),
          const SizedBox(height: AppSizes.paddingM),
          Expanded(
            child: PageStorage(
              bucket: _bucket,
              child: ListView.builder(
                key: const PageStorageKey('sidebar_navigation_list'),
                controller: _scrollController,
                physics: const BouncingScrollPhysics(), // Better physics
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isCollapsed ? 4 : AppSizes.paddingS,
                ),
                itemCount: ResponsiveNavBar._navItems.length,
                itemBuilder: (context, index) {
                  return _SidebarNavItemWidget(
                    key:
                        ValueKey('nav_item_$index'), // Unique key untuk caching
                    index: index,
                    item: ResponsiveNavBar._navItems[index],
                    selectedIndex: widget.selectedIndex,
                    isCollapsed: widget.isCollapsed,
                    onTap: widget.onItemTapped,
                  );
                },
              ),
            ),
          ),
          if (!widget.isCollapsed) _buildSidebarFooter(context),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        widget.isCollapsed ? AppSizes.paddingS : AppSizes.paddingL,
      ),
      child: widget.isCollapsed
          ? Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    "H",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF040404),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          : Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      "H",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF040404),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: Text(
                    "HRIS System",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSidebarFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        children: [
          Container(
            height: 1,
            color: const Color(0xFF1a1a1a),
            margin: const EdgeInsets.only(bottom: AppSizes.paddingM),
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white.withOpacity(0.1),
                child: const FaIcon(
                  FontAwesomeIcons.user,
                  size: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(width: AppSizes.paddingS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nama,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _email,
                      style: GoogleFonts.poppins(
                        color: Colors.white60,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SidebarNavItemWidget extends StatelessWidget {
  final int index;
  final NavItem item;
  final int selectedIndex;
  final bool isCollapsed;
  final Function(int) onTap;

  const _SidebarNavItemWidget({
    super.key,
    required this.index,
    required this.item,
    required this.selectedIndex,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = index == selectedIndex;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double iconSize = screenWidth < 1024 ? 18 : 20;
    final double fontSize = screenWidth < 1024 ? 14 : 15;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 8 : AppSizes.paddingM,
              vertical: AppSizes.paddingM,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? const Border(
                      left: BorderSide(
                        color: Colors.white,
                        width: 3,
                      ),
                    )
                  : null,
            ),
            child: isCollapsed
                ? Center(
                    child: FaIcon(
                      item.icon,
                      color: isSelected ? Colors.white : Colors.white70,
                      size: iconSize,
                    ),
                  )
                : Row(
                    children: [
                      FaIcon(
                        item.icon,
                        color: isSelected ? Colors.white : Colors.white70,
                        size: iconSize,
                      ),
                      const SizedBox(width: AppSizes.paddingM),
                      Expanded(
                        child: Text(
                          item.label,
                          style: GoogleFonts.poppins(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: fontSize,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final String label;
  final IconData icon;
  const NavItem({required this.label, required this.icon});
}
