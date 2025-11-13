// ignore_for_file: await_only_futures, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/dialog/show_confirmation.dart';
import 'package:hr/core/const/app_size.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResponsiveNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final bool isCollapsed;
  final List<String> userFitur;
  final Future<void> Function()? onLogout;
  const ResponsiveNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.isCollapsed = false,
    required this.userFitur,
    this.onLogout,
  });

  // Definisi semua menu
  List<NavItemWithFeature> getAllNavItems(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    bool isIndonesian = langProvider.isIndonesian;
    return [
      NavItemWithFeature(
        label: "Dashboard",
        icon: FontAwesomeIcons.house,
        selectedIcon: FontAwesomeIcons.houseChimney,
        requiredFeatures: null,
        route: AppRoutes.dashboard,
      ),
      NavItemWithFeature(
        label: isIndonesian ? "Kehadiran" : "Attendance",
        icon: FontAwesomeIcons.calendarCheck,
        selectedIcon: FontAwesomeIcons.solidCalendarCheck,
        requiredFeatures: ["lihat_absensi_sendiri", "lihat_semua_absensi"],
        route: AppRoutes.attendance,
      ),
      NavItemWithFeature(
        label: isIndonesian ? "Tugas" : "Task",
        icon: FontAwesomeIcons.listCheck,
        requiredFeatures: ["lihat_tugas"],
        route: AppRoutes.task,
      ),
      NavItemWithFeature(
        label: isIndonesian ? 'Lembur' : "Over Time",
        icon: FontAwesomeIcons.clock,
        selectedIcon: FontAwesomeIcons.solidClock,
        requiredFeatures: ["lihat_lembur"],
        route: AppRoutes.overTime,
      ),
      NavItemWithFeature(
        label: isIndonesian ? 'Cuti' : "Leave",
        icon: FontAwesomeIcons.calendarMinus,
        selectedIcon: FontAwesomeIcons.solidCalendarMinus,
        requiredFeatures: ["lihat_cuti"],
        route: AppRoutes.leave,
      ),
      // Dropdown parent: Data Pegawai
      NavItemWithFeature(
        label: isIndonesian ? 'Data Pegawai' : "Employee Data",
        icon: FontAwesomeIcons.users,
        requiredFeatures: null,
        isDropdownParent: true,
        dropdownChildren: [
          NavItemWithFeature(
            label: isIndonesian ? 'Pegawai' : "Employees",
            icon: FontAwesomeIcons.users,
            requiredFeatures: ["karyawan"],
            route: AppRoutes.employee,
          ),
          NavItemWithFeature(
            label: isIndonesian ? 'Departemen' : "Department",
            icon: FontAwesomeIcons.building,
            selectedIcon: FontAwesomeIcons.solidBuilding,
            requiredFeatures: ["departemen"],
            route: AppRoutes.department,
          ),
          NavItemWithFeature(
            label: isIndonesian ? 'Jabatan' : "Position",
            icon: FontAwesomeIcons.idBadge,
            selectedIcon: FontAwesomeIcons.solidIdBadge,
            requiredFeatures: ["jabatan"],
            route: AppRoutes.jabatan,
          ),
          NavItemWithFeature(
            label: isIndonesian ? 'Hak Akses' : "Access Rights",
            icon: FontAwesomeIcons.userShield,
            requiredFeatures: ["peran"],
            route: AppRoutes.peran,
          ),
          NavItemWithFeature(
            label: isIndonesian ? 'Potongan Gaji' : "Salary Deduction",
            icon: FontAwesomeIcons.calculator,
            requiredFeatures: ["potongan_gaji"],
            route: AppRoutes.potonganGaji,
          ),
        ],
      ),
      NavItemWithFeature(
        label: isIndonesian ? 'Penggajian' : "Payroll",
        icon: FontAwesomeIcons.moneyBill,
        requiredFeatures: ["gaji"],
        route: AppRoutes.payroll,
      ),
      NavItemWithFeature(
        label: isIndonesian ? 'Log Aktivitas' : "Log Activity",
        icon: FontAwesomeIcons.history,
        requiredFeatures: ["log_aktifitas"],
        route: AppRoutes.logActivity,
      ),
      NavItemWithFeature(
        label: isIndonesian ? 'Pengingat' : "Reminder",
        icon: FontAwesomeIcons.alarmClock,
        selectedIcon: FontAwesomeIcons.solidAlarmClock,
        requiredFeatures: ["pengingat"],
        route: AppRoutes.reminder,
      ),
      NavItemWithFeature(
        label: isIndonesian ? 'Pengaturan' : "Settings",
        icon: FontAwesomeIcons.gear,
        requiredFeatures: null,
        route: AppRoutes.pengaturan,
      ),
      NavItemWithFeature(
        label: isIndonesian ? "Info Kantor" : "Company info",
        icon: FontAwesomeIcons.circleInfo,
        requiredFeatures: ["kantor"],
        route: AppRoutes.infoKantor,
      ),
      // Dropdown parent: Reset
      NavItemWithFeature(
        label: "Reset",
        icon: FontAwesomeIcons.triangleExclamation,
        requiredFeatures: null,
        isDropdownParent: true,
        dropdownChildren: [
          NavItemWithFeature(
            label: isIndonesian ? 'Reset Data' : "Reset Data",
            icon: FontAwesomeIcons.triangleExclamation,
            requiredFeatures: ["denger"],
            route: AppRoutes.danger,
          ),
          NavItemWithFeature(
            label: isIndonesian ? 'Reset Perangkat' : "Reset Device",
            icon: FontAwesomeIcons.trashRestore,
            requiredFeatures: ["reset_device"],
            route: AppRoutes.resetDevice,
          ),
          NavItemWithFeature(
            label: isIndonesian ? 'Buka Akun' : "Unlock Account",
            icon: FontAwesomeIcons.unlock,
            requiredFeatures: ["buka_akun"],
            route: AppRoutes.bukaAkun,
          ),
        ],
      ),
    ];
  }

  // Filter menu
  List<NavItem> getFilteredNavItems(
      BuildContext context, List<String> userFitur) {
    final allItems = getAllNavItems(context);
    List<NavItem> result = [];

    for (var item in allItems) {
      if (item.isDropdownParent) {
        final filteredChildren = item.dropdownChildren
            ?.where((child) =>
                child.requiredFeatures == null ||
                child.requiredFeatures!.any((f) => userFitur.contains(f)))
            .toList();

        if (filteredChildren != null && filteredChildren.isNotEmpty) {
          result.add(NavItem(
            label: item.label,
            icon: item.icon,
            selectedIcon: item.selectedIcon,
            isDropdownParent: true,
            dropdownChildren: filteredChildren
                .map((child) => NavItem(
                      label: child.label,
                      icon: child.icon,
                      selectedIcon: child.selectedIcon,
                      route: child.route,
                    ))
                .toList(),
          ));
        }
      } else {
        if (item.requiredFeatures == null ||
            item.requiredFeatures!.any((f) => userFitur.contains(f))) {
          result.add(NavItem(
            label: item.label,
            icon: item.icon,
            selectedIcon: item.selectedIcon,
            route: item.route,
          ));
        }
      }
    }

    return result;
  }

  List<NavItem> getMobileNavItems(
      BuildContext context, List<String> userFitur) {
    final filtered = getFilteredNavItems(context, userFitur);
    final nonDropdownItems =
        filtered.where((item) => !item.isDropdownParent).toList();
    return nonDropdownItems.length > 5
        ? nonDropdownItems.sublist(0, 5)
        : nonDropdownItems;
  }

  @override
  State<ResponsiveNavBar> createState() => _ResponsiveNavBarState();
}

class _ResponsiveNavBarState extends State<ResponsiveNavBar>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  ScrollController? _scrollController;
  static double _lastScrollPosition = 0.0;
  static final PageStorageBucket _bucket = PageStorageBucket();
  static const String _scrollStorageKey = 'sidebar_scroll_position';

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  String _nama = "";
  String _email = "";
  final Map<int, bool> _expandedDropdowns = {};

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
    _slideController = AnimationController(
        duration: const Duration(milliseconds: 350), vsync: this);
    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);

    _slideAnimation =
        CurvedAnimation(parent: _slideController, curve: Curves.easeInOutCubic);
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);

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
    if (storedPosition is double) targetPosition = storedPosition;
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
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return context.isMobile
        ? _buildMobileBottomNav(context)
        : _buildDesktopSidebar(context);
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
    final mobileItems = widget.getMobileNavItems(context, widget.userFitur);
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.hitam,
        border: Border(top: BorderSide(color: Color(0xFF1a1a1a), width: 1)),
      ),
      child: SafeArea(
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: mobileItems.map((item) {
              final bool isSelected = item.route == currentRoute;
              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (item.route != null && item.route != currentRoute) {
                        Navigator.pushNamed(context, item.route!);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
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
    final double expandedWidth = screenWidth < 1024 ? 220 : 220;
    final filteredItems = widget.getFilteredNavItems(context, widget.userFitur);

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, _) {
        final double currentWidth =
            widget.isCollapsed ? collapsedWidth : expandedWidth;

        return Container(
          width: currentWidth,
          color: AppColors.latar3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Expanded(
                child: PageStorage(
                  bucket: _bucket,
                  child: ListView.builder(
                    key: const PageStorageKey('sidebar_navigation_list'),
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                        horizontal: widget.isCollapsed ? 4 : AppSizes.paddingS),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      if (item.isDropdownParent) {
                        return _buildDropdownNavItem(index: index, item: item);
                      }
                      return _SidebarNavItemWidget(
                        key: ValueKey('nav_item_$index'),
                        index: index,
                        item: item,
                        selectedIndex: widget.selectedIndex,
                        isCollapsed: widget.isCollapsed,
                        onTap: (_) {},
                        fadeAnimation: _fadeAnimation,
                      );
                    },
                  ),
                ),
              ),
              if (!widget.isCollapsed)
                FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildSidebarFooter(context)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDropdownNavItem({
    required int index,
    required NavItem item,
  }) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final bool hasActiveChild =
        item.dropdownChildren?.any((c) => c.route == currentRoute) ?? false;

    // Jika user sudah toggle manual, pakai nilai itu.
    // Kalau belum ada entry, fallback ke hasActiveChild.
    final bool isExpanded = _expandedDropdowns.containsKey(index)
        ? (_expandedDropdowns[index] ?? false)
        : hasActiveChild;

    return Column(
      children: [
        MouseRegion(
          onEnter: (_) => setState(() {}),
          onExit: (_) => setState(() {}),
          child: InkWell(
            onTap: () {
              if (widget.isCollapsed) {
                // buka sidebar & expand dropdown
                widget.onItemTapped(index); // pastikan ini buka sidebar
                setState(() {
                  _expandedDropdowns[index] = true;
                });
              } else {
                setState(() {
                  _expandedDropdowns[index] = !isExpanded;
                });
              }
            },
            borderRadius: BorderRadius.circular(12),
            splashColor: AppColors.putih.withOpacity(0.1),
            highlightColor: Colors.transparent,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(
                horizontal: widget.isCollapsed ? 8 : AppSizes.paddingM,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: widget.isCollapsed
                  ? Center(
                      child: FaIcon(
                        item.icon,
                        color: AppColors.putih.withOpacity(0.7),
                        size: 18,
                      ),
                    )
                  : Row(
                      children: [
                        FaIcon(
                          item.icon,
                          color: AppColors.putih.withOpacity(0.7),
                          size: 18,
                        ),
                        const SizedBox(width: AppSizes.paddingM),
                        Expanded(
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              item.label,
                              style: GoogleFonts.poppins(
                                color: AppColors.putih.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        AnimatedRotation(
                          turns: isExpanded ? 0.25 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.keyboard_arrow_right,
                            color: AppColors.putih.withOpacity(0.7),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),

        // children
        if (!widget.isCollapsed)
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Column(
                    children: item.dropdownChildren?.map((child) {
                          return _SidebarNavItemWidget(
                            key: ValueKey('nav_item_child_${child.label}'),
                            index: 0,
                            item: child,
                            selectedIndex: widget.selectedIndex,
                            isCollapsed: false,
                            // important: navigate by route, don't toggle dropdown
                            onTap: (_) {
                              if (child.route != null &&
                                  child.route !=
                                      ModalRoute.of(context)?.settings.name) {
                                Navigator.pushNamed(context, child.route!);
                              }
                            },
                            fadeAnimation: _fadeAnimation,
                            isChild: true,
                          );
                        }).toList() ??
                        [],
                  )
                : const SizedBox.shrink(),
          ),
      ],
    );
  }

  Widget _buildSidebarFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        right: AppSizes.paddingM,
        left: AppSizes.paddingM,
        bottom: AppSizes.paddingM,
      ),
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
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: AppColors.putih.withOpacity(0.7),
                    size: 18,
                  ),
                  onSelected: (value) async {
                    if (value == 'settings') {
                      // debugPrint("Settings diklik");
                      Navigator.pushNamed(context, AppRoutes.pengaturan);
                    } else if (value == 'logout') {
                      final confirmed = await showConfirmationDialog(
                        context,
                        title: context.isIndonesian
                            ? "Konfirmasi Logout"
                            : "Logout Confirmation",
                        content: context.isIndonesian
                            ? "Apakah Anda yakin ingin keluar dari akun ini?"
                            : "Are you sure you want to log out of this account?",
                        confirmText: context.isIndonesian ? "Keluar" : "Logout",
                        cancelText: context.isIndonesian ? "Batal" : "Cancel",
                        confirmColor: AppColors.red,
                      );

                      if (!confirmed) return;

                      //  kalo parent (MainLayout) punya callback logout, panggil langsung
                      if (widget.onLogout != null) {
                        await widget.onLogout!();
                        return;
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: const [
                          Icon(Icons.settings, size: 16),
                          SizedBox(width: 8),
                          Text("Settings"),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: const [
                          Icon(Icons.logout, size: 16),
                          SizedBox(width: 8),
                          Text("Logout"),
                        ],
                      ),
                    ),
                  ],
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
  final bool isChild;

  const _SidebarNavItemWidget({
    super.key,
    required this.index,
    required this.item,
    required this.selectedIndex,
    required this.isCollapsed,
    required this.onTap,
    required this.fadeAnimation,
    this.isChild = false,
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
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final bool isSelected = widget.item.route == currentRoute;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double iconSize = screenWidth < 1024 ? 16 : 18;
    final double fontSize = screenWidth < 1024 ? 13 : 14;

    return Container(
      margin: EdgeInsets.only(
        top: 6,
        bottom: 4,
        left: widget.isChild ? 24 : 0,
      ),
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
            onTap: () {
              if (widget.item.route != null &&
                  widget.item.route != currentRoute) {
                Navigator.pushNamed(context, widget.item.route!);
              }
            },
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
                    vertical: 12,
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

// Class untuk menu item dengan fitur yang diperlukan
class NavItemWithFeature {
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final List<String>? requiredFeatures;
  final bool isDropdownParent;
  final List<NavItemWithFeature>? dropdownChildren;
  final String? route;
  const NavItemWithFeature({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.requiredFeatures,
    this.isDropdownParent = false,
    this.dropdownChildren,
    this.route,
  });
}

// Class untuk menu item biasa (tanpa fitur)
class NavItem {
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final bool isDropdownParent;
  final List<NavItem>? dropdownChildren;
  final String? route;
  const NavItem({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.isDropdownParent = false,
    this.dropdownChildren,
    this.route,
  });
}
