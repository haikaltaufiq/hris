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
    NavItem(
      label: "Dashboard",
      icon: FontAwesomeIcons.house,
      selectedIcon: FontAwesomeIcons.houseChimney,
    ),
    NavItem(
      label: "Attendance",
      icon: FontAwesomeIcons.calendarCheck,
      selectedIcon: FontAwesomeIcons.solidCalendarCheck,
    ),
    NavItem(
      label: "Task",
      icon: FontAwesomeIcons.listCheck,
    ),
    NavItem(
        label: "Over Time",
        icon: FontAwesomeIcons.clock,
        selectedIcon: FontAwesomeIcons.solidClock),
    NavItem(
        label: "Leave",
        icon: FontAwesomeIcons.calendarMinus,
        selectedIcon: FontAwesomeIcons.solidCalendarMinus),
    NavItem(label: "Employees", icon: FontAwesomeIcons.users),
    NavItem(
      label: "Payroll",
      icon: FontAwesomeIcons.moneyBill,
    ),
    NavItem(
        label: "Department",
        icon: FontAwesomeIcons.building,
        selectedIcon: FontAwesomeIcons.solidBuilding),
    NavItem(
        label: "Position",
        icon: FontAwesomeIcons.idBadge,
        selectedIcon: FontAwesomeIcons.solidIdBadge),
    NavItem(label: "Access Rights", icon: FontAwesomeIcons.userShield),
    NavItem(label: "Salary Deduction", icon: FontAwesomeIcons.calculator),
    NavItem(label: "Log Activity", icon: FontAwesomeIcons.history),
    NavItem(
        label: "Reminder",
        icon: FontAwesomeIcons.alarmClock,
        selectedIcon: FontAwesomeIcons.solidAlarmClock),
    NavItem(label: "Settings", icon: FontAwesomeIcons.gear),
  ];

  static List<NavItem> get _mobileNavItems =>
      _navItems.length > 5 ? _navItems.sublist(0, 5) : _navItems;

  @override
  State<ResponsiveNavBar> createState() => _ResponsiveNavBarState();
}

class _ResponsiveNavBarState extends State<ResponsiveNavBar>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  static ScrollController? _scrollController;
  static double _lastScrollPosition = 0.0;
  static final PageStorageBucket _bucket = PageStorageBucket();
  static const String _scrollStorageKey = 'sidebar_scroll_position';

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  String _nama = "";
  String _email = "";

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeScrollController();
    _loadUserData();
  }

  void _initializeControllers() {
    // Animation controller untuk width transition
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    // Animation controller untuk opacity transition
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Smooth curve untuk slide animation
    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOutCubic,
    );

    // Fade animation untuk text elements
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Set initial state
    if (widget.isCollapsed) {
      _slideController.value = 1.0;
      _fadeController.value = 0.0;
    } else {
      _slideController.value = 0.0;
      _fadeController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ResponsiveNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger animations when collapse state changes
    if (oldWidget.isCollapsed != widget.isCollapsed) {
      if (widget.isCollapsed) {
        _fadeController.reverse();
        Future.delayed(const Duration(milliseconds: 100), () {
          _slideController.forward();
        });
      } else {
        _slideController.reverse();
        Future.delayed(const Duration(milliseconds: 200), () {
          _fadeController.forward();
        });
      }
    }
  }

  void _initializeScrollController() {
    if (_scrollController == null) {
      _scrollController =
          ScrollController(initialScrollOffset: _lastScrollPosition);

      _scrollController!.addListener(_saveScrollPosition);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreScrollPosition();
    });
  }

  void _saveScrollPosition() {
    if (_scrollController != null && _scrollController!.hasClients) {
      _lastScrollPosition = _scrollController!.offset;

      PageStorage.of(context).writeState(
        context,
        _lastScrollPosition,
        identifier: _scrollStorageKey,
      );
    }
  }

  void _restoreScrollPosition() async {
    if (_scrollController == null || !_scrollController!.hasClients) return;

    final storedPosition = PageStorage.of(context).readState(
      context,
      identifier: _scrollStorageKey,
    );

    double targetPosition = _lastScrollPosition;
    if (storedPosition is double) {
      targetPosition = storedPosition;
    }

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
    _slideController.dispose();
    _fadeController.dispose();
    _scrollController?.removeListener(_saveScrollPosition);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: FaIcon(
                              isSelected && item.selectedIcon != null
                                  ? item.selectedIcon!
                                  : item.icon,
                              color: isSelected ? Colors.white : Colors.white60,
                              size: 23,
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
    final double collapsedWidth = 70;
    final double expandedWidth = screenWidth < 1024 ? 220 : 260;

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        final double currentWidth =
            widget.isCollapsed ? collapsedWidth : expandedWidth;

        return Container(
          width: currentWidth,
          height: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(4, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 60,
              ),
              const SizedBox(height: AppSizes.paddingM),
              Expanded(
                child: PageStorage(
                  bucket: _bucket,
                  child: ListView.builder(
                    key: const PageStorageKey('sidebar_navigation_list'),
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.isCollapsed ? 4 : AppSizes.paddingS,
                    ),
                    itemCount: ResponsiveNavBar._navItems.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          _SidebarNavItemWidget(
                            key: ValueKey('nav_item_$index'),
                            index: index,
                            item: ResponsiveNavBar._navItems[index],
                            selectedIndex: widget.selectedIndex,
                            isCollapsed: widget.isCollapsed,
                            onTap: widget.onItemTapped,
                            fadeAnimation: _fadeAnimation,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              if (!widget.isCollapsed)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildSidebarFooter(context),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebarFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
          right: AppSizes.paddingM,
          left: AppSizes.paddingM,
          bottom: AppSizes.paddingM),
      child: Column(
        children: [
          Container(
            height: 1,
            margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.putih.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.putih.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.putih.withOpacity(0.1),
                  child: FaIcon(
                    FontAwesomeIcons.user,
                    size: 14,
                    color: AppColors.putih.withOpacity(0.5),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nama.isEmpty ? "User" : _nama,
                        style: GoogleFonts.poppins(
                          color: AppColors.putih,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _email.isEmpty ? "user@example.com" : _email,
                        style: GoogleFonts.poppins(
                          color: AppColors.putih.withOpacity(0.7),
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarNavItemWidget extends StatefulWidget {
  final int index;
  final NavItem item;
  final int selectedIndex;
  final bool isCollapsed;
  final Function(int) onTap;
  final Animation<double> fadeAnimation;

  const _SidebarNavItemWidget({
    super.key,
    required this.index,
    required this.item,
    required this.selectedIndex,
    required this.isCollapsed,
    required this.onTap,
    required this.fadeAnimation,
  });

  @override
  State<_SidebarNavItemWidget> createState() => _SidebarNavItemWidgetState();
}

class _SidebarNavItemWidgetState extends State<_SidebarNavItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hoverAnimation = CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSelected = widget.index == widget.selectedIndex;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double iconSize = screenWidth < 1024 ? 16 : 18;
    final double fontSize = screenWidth < 1024 ? 13 : 14;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      height: 50,
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          _hoverController.forward();
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          _hoverController.reverse();
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => widget.onTap(widget.index),
            borderRadius: BorderRadius.circular(12),
            splashColor: AppColors.putih.withOpacity(0.1),
            highlightColor: AppColors.putih.withOpacity(0.05),
            child: AnimatedBuilder(
              animation:
                  Listenable.merge([_hoverAnimation, widget.fadeAnimation]),
              builder: (context, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOutCubic,
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.isCollapsed ? 8 : AppSizes.paddingM,
                    vertical: AppSizes.paddingM,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.putih.withOpacity(0.12)
                        : _isHovered
                            ? AppColors.putih.withOpacity(0.2)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.putih.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: widget.isCollapsed
                      ? Center(
                          child: AnimatedScale(
                            scale: _isHovered ? 1.1 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: FaIcon(
                              isSelected && widget.item.selectedIcon != null
                                  ? widget.item.selectedIcon!
                                  : widget.item.icon,
                              color: isSelected
                                  ? AppColors.putih
                                  : AppColors.putih.withOpacity(0.7),
                              size: iconSize,
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            AnimatedScale(
                              scale: _isHovered ? 1.1 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: FaIcon(
                                isSelected && widget.item.selectedIcon != null
                                    ? widget.item.selectedIcon!
                                    : widget.item.icon,
                                color: isSelected
                                    ? AppColors.putih
                                    : AppColors.putih.withOpacity(0.7),
                                size: iconSize,
                              ),
                            ),
                            const SizedBox(width: AppSizes.paddingM),
                            Expanded(
                              child: FadeTransition(
                                opacity: widget.fadeAnimation,
                                child: Text(
                                  widget.item.label,
                                  style: GoogleFonts.poppins(
                                    color: isSelected
                                        ? AppColors.putih
                                        : AppColors.putih.withOpacity(0.7),
                                    fontSize: fontSize,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                );
              },
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
  final IconData? selectedIcon;
  const NavItem({required this.label, required this.icon, this.selectedIcon});
}
