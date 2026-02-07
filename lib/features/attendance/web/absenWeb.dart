import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/components/custom/loading.dart';
import 'package:hr/core/helpers/feature_guard.dart';
import 'package:hr/core/theme/language_provider.dart';
import 'package:hr/data/api/api_config.dart';
import 'package:hr/features/attendance/view_model/absen_provider.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:video_player/video_player.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/helpers/notification_helper.dart';
import 'package:hr/data/models/absen_model.dart';

class AbsenWeb extends StatefulWidget {
  const AbsenWeb({super.key});

  @override
  State<AbsenWeb> createState() => _AbsenWebState();
}

class _AbsenWebState extends State<AbsenWeb> {
  // ===========================================================================
  // CONTROLLERS & STATE
  // ===========================================================================

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  AbsenSortType _selectedSort = AbsenSortType.day;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  int _currentPage = 1;
  int _rowsPerPage = 10;
  int _totalPages = 1;

  List<AbsenModel> _paginatedData = [];

  // ===========================================================================
  // LIFECYCLE
  // ===========================================================================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================

  Future<void> _initializeData() async {
    final provider = context.read<AbsenProvider>();
    await provider.fetchAbsensi();
    _applyFiltersAndPagination();
  }

  void _onSearchChanged() {
    _currentPage = 1;
    _applyFiltersAndPagination();
  }

  // ===========================================================================
  // FILTER & PAGINATION LOGIC
  // ===========================================================================

  void _applyFiltersAndPagination() {
    final provider = context.read<AbsenProvider>();

    final filter = AbsenAdvancedFilter(
      search: _searchController.text,
      month: _selectedMonth,
      year: _selectedYear,
      sort: _selectedSort,
      day: _selectedSort == AbsenSortType.day ? DateTime.now() : null,
    );

    provider.applyAdvancedFilter(filter);

    final filteredList = provider.advancedAbsensi;
    _totalPages = (filteredList.length / _rowsPerPage).ceil();
    if (_totalPages == 0) _totalPages = 1;

    final startIndex = (_currentPage - 1) * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage).clamp(0, filteredList.length);

    setState(() {
      _paginatedData = filteredList.sublist(
        startIndex,
        endIndex,
      );
    });
  }

  void _changePage(int newPage) {
    if (newPage < 1 || newPage > _totalPages) return;
    setState(() => _currentPage = newPage);
    _applyFiltersAndPagination();
  }

  void _changeRowsPerPage(int? newRows) {
    if (newRows == null) return;
    setState(() {
      _rowsPerPage = newRows;
      _currentPage = 1;
    });
    _applyFiltersAndPagination();
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  String _monthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[month - 1];
  }

  String get _monthTitle => "${_monthName(_selectedMonth)} $_selectedYear";

  bool _isLateCheckIn(String? time) {
    if (time == null || time.isEmpty) return false;
    try {
      final checkInTime = DateTime.parse("1970-01-01 $time");
      final limitTime = DateTime.parse("1970-01-01 08:10");
      return checkInTime.isAfter(limitTime);
    } catch (_) {
      return false;
    }
  }

  // ===========================================================================
  // UI BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Consumer<AbsenProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.allAbsensi.isEmpty) {
            return const Center(child: LoadingWidget());
          }

          return SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterBar(),
                  const SizedBox(height: 24),
                  _buildTableCard(),
                  const SizedBox(height: 16),
                  _buildPaginationControls(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ===========================================================================
  // FILTER BAR
  // ===========================================================================

  Widget _buildFilterBar() {
    final lihatSemuaAbsensi = FeatureAccess.has('lihat_semua_absensi');
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: AppColors.putih),
            decoration: InputDecoration(
              hintText: "Search by name, date, status...",
              hintStyle: TextStyle(
                  color: AppColors.putih.withOpacity(0.5), fontSize: 12),
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.putih,
              ),
              filled: true,
              fillColor: AppColors.primary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildDropdown<AbsenSortType>(
          value: _selectedSort,
          items: const [
            DropdownMenuItem(
                value: AbsenSortType.day, child: Text("Sort by Day")),
            DropdownMenuItem(
                value: AbsenSortType.week, child: Text("Sort by Week")),
            DropdownMenuItem(
                value: AbsenSortType.name, child: Text("Sort by Name")),
            DropdownMenuItem(
                value: AbsenSortType.terbaru, child: Text("Newest First")),
            DropdownMenuItem(
                value: AbsenSortType.terlama, child: Text("Oldest First")),
          ],
          onChanged: (v) {
            setState(() => _selectedSort = v!);
            _currentPage = 1;
            _applyFiltersAndPagination();
          },
        ),
        const SizedBox(width: 8),
        _buildDropdown<int>(
          value: _selectedMonth,
          items: List.generate(
            12,
            (i) => DropdownMenuItem(
              value: i + 1,
              child: Text(_monthName(i + 1)),
            ),
          ),
          onChanged: (v) {
            setState(() => _selectedMonth = v!);
            _currentPage = 1;
            _applyFiltersAndPagination();
          },
        ),
        const SizedBox(width: 8),
        _buildDropdown<int>(
          value: _selectedYear,
          items: List.generate(
            5,
            (i) {
              final year = DateTime.now().year - 2 + i;
              return DropdownMenuItem(
                value: year,
                child: Text(year.toString()),
              );
            },
          ),
          onChanged: (v) {
            setState(() => _selectedYear = v!);
            _currentPage = 1;
            _applyFiltersAndPagination();
          },
        ),
        if (lihatSemuaAbsensi) ...[
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.locationTrack);
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_history_rounded,
                      size: 24,
                      color: AppColors.putih,
                    ),
                    const SizedBox(width: 4),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.isIndonesian ? "Pantau" : "Track",
                          style: TextStyle(
                            color: AppColors.putih,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          context.isIndonesian ? "Lokasi" : "Location",
                          style: TextStyle(
                            color: AppColors.putih,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ],
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        dropdownColor: AppColors.primary,
        underline: const SizedBox(),
        style: TextStyle(color: AppColors.putih, fontSize: 14),
        iconEnabledColor: AppColors.putih,
      ),
    );
  }

  // ===========================================================================
  // TABLE CARD
  // ===========================================================================

  Widget _buildTableCard() {
    final hasAbsensi = FeatureAccess.has("absensi");
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Attendance ",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.putih,
                    ),
                  ),
                  Text(
                    "$_monthTitle",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppColors.putih,
                    ),
                  ),
                ],
              ),
              if (hasAbsensi) ...[
                const SizedBox(width: 900),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondary,
                          AppColors.secondary.withOpacity(0.8),
                        ],
                      ),
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
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          final absenProvider = context.read<AbsenProvider>();
                          if (!absenProvider.hasCheckedInToday) {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.checkin,
                            );
                          } else {
                            final message = context.isIndonesian
                                ? "Anda Sudah Check-in hari ini"
                                : "You have already checked in today";
                            NotificationHelper.showTopNotification(
                                context, message,
                                isSuccess: false);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.rightToBracket,
                              color: AppColors.putih,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.isIndonesian ? "Masuk Kerja" : "Clock In",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.putih,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.putih.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          final absenProvider = context.read<AbsenProvider>();
                          if (absenProvider.hasCheckedInToday) {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.checkout,
                            );
                          } else {
                            final message = context.isIndonesian
                                ? "Anda Belum Check-in hari ini"
                                : "You haven't checked in today";
                            NotificationHelper.showTopNotification(
                                context, message,
                                isSuccess: false);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.rightFromBracket,
                              color: AppColors.putih.withOpacity(0.8),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.isIndonesian
                                  ? "Keluar Kerja"
                                  : "Clock Out",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.putih.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          _buildTableHeader(),
          Divider(color: AppColors.putih.withOpacity(0.2)),
          _paginatedData.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      "No data available",
                      style: GoogleFonts.poppins(
                        color: AppColors.putih.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              : Column(
                  children: _paginatedData
                      .map((absen) => _buildTableRow(absen))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return _buildRow(
      isHeader: true,
      cells: const [
        "Date",
        "Name",
        "Check In",
        "Check Out",
        "Location",
        "Video",
        "Status",
      ],
    );
  }

  String parseDate(String? date) {
    if (date == null || date.isEmpty) return '';
    try {
      final parsed = DateTime.parse(date).toLocal();
      return DateFormat('dd/MM/yyyy').format(parsed);
    } catch (_) {
      return date;
    }
  }

  Widget _buildTableRow(AbsenModel absen) {
    final isLate = _isLateCheckIn(absen.checkinTime);

    return _buildRow(
      cells: [
        parseDate(absen.checkinDate),
        absen.user?.nama ?? "-",
        absen.checkinTime ?? "-",
        absen.checkoutTime ?? "-",
        "See Location",
        "See Video",
        absen.status ?? "-",
      ],
      rowData: absen,
      isLateCheckIn: isLate,
    );
  }

  Widget _buildRow({
    required List<String> cells,
    bool isHeader = false,
    AbsenModel? rowData,
    bool isLateCheckIn = false,
  }) {
    final textStyle = GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: isHeader ? FontWeight.bold : FontWeight.w500,
      color: AppColors.putih,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: List.generate(cells.length, (index) {
          if (!isHeader && cells[index] == "See Location") {
            return Expanded(
              child: GestureDetector(
                onTap: () => _openMap(
                    "${rowData?.checkinLat ?? ''}, ${rowData?.checkinLng ?? ''}"),
                child: Text(
                  cells[index],
                  style: textStyle.copyWith(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            );
          }

          if (!isHeader && cells[index] == "See Video") {
            return Expanded(
              child: GestureDetector(
                onTap: () => _openVideo(rowData?.videoUser),
                child: Text(
                  cells[index],
                  style: textStyle.copyWith(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            );
          }

          // Check In column (index 2) - Late check-in color
          if (!isHeader && index == 2 && isLateCheckIn) {
            return Expanded(
              child: Text(
                cells[index],
                style: textStyle.copyWith(color: Colors.redAccent),
              ),
            );
          }

          // Status column (index 4) - Color based on status
          if (!isHeader && index == 6) {
            Color statusColor = AppColors.putih;
            final status = cells[index].toLowerCase();

            if (status == "tepat waktu") {
              statusColor = AppColors.green;
            } else if (status == "terlambat") {
              statusColor = AppColors.red;
            }

            return Expanded(
              child: Text(
                cells[index],
                style: textStyle.copyWith(color: statusColor),
              ),
            );
          }

          return Expanded(
            child: Text(cells[index], style: textStyle),
          );
        }),
      ),
    );
  }

  // ===========================================================================
  // PAGINATION CONTROLS
  // ===========================================================================

  Widget _buildPaginationControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "Rows per page:",
                style: TextStyle(color: AppColors.putih, fontSize: 13),
              ),
              const SizedBox(width: 8),
              _buildDropdown<int>(
                value: _rowsPerPage,
                items: const [
                  DropdownMenuItem(value: 10, child: Text("10")),
                  DropdownMenuItem(value: 25, child: Text("25")),
                  DropdownMenuItem(value: 50, child: Text("50")),
                  DropdownMenuItem(value: 100, child: Text("100")),
                ],
                onChanged: _changeRowsPerPage,
              ),
            ],
          ),
          Row(
            children: [
              Text(
                "Page $_currentPage of $_totalPages",
                style: TextStyle(color: AppColors.putih, fontSize: 13),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: Icon(Icons.chevron_left, color: AppColors.putih),
                onPressed: _currentPage > 1
                    ? () => _changePage(_currentPage - 1)
                    : null,
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: AppColors.putih),
                onPressed: _currentPage < _totalPages
                    ? () => _changePage(_currentPage + 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // MAP MODAL
  // ===========================================================================

  void _openMap(String latlongStr) {
    try {
      final parts = latlongStr.split(',');
      final lat = double.parse(parts[0].trim());
      final lng = double.parse(parts[1].trim());

      Navigator.pushNamed(context, AppRoutes.mapPage,
          arguments: LatLng(lat, lng));
    } catch (_) {
      // debugPrint("Format latlong salah: $latlongStr");
    }
  }

  // ===========================================================================
  // VIDEO MODAL
  // ===========================================================================

  void _openVideo(String? videoPath) {
    if (videoPath == null || videoPath.isEmpty) {
      NotificationHelper.showTopNotification(
        context,
        "No video available",
        isSuccess: false,
      );
      return;
    }

    final fullUrl = videoPath.startsWith('http')
        ? videoPath
        : "${ApiConfig.baseUrl}$videoPath";

    final controller = VideoPlayerController.network(fullUrl);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (_, __, ___) {
        return FutureBuilder(
          future: controller.initialize(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              controller.play();
              return StatefulBuilder(
                builder: (context, setStateDialog) {
                  return Scaffold(
                    backgroundColor: Colors.black.withOpacity(0.9),
                    body: Stack(
                      children: [
                        Center(
                          child: AspectRatio(
                            aspectRatio: controller.value.aspectRatio,
                            child: VideoPlayer(controller),
                          ),
                        ),
                        Positioned(
                          top: 40,
                          right: 20,
                          child: IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 32,
                            ),
                            onPressed: () {
                              controller.dispose();
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 30,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: FloatingActionButton(
                              backgroundColor: Colors.white,
                              onPressed: () {
                                if (controller.value.isPlaying) {
                                  controller.pause();
                                } else {
                                  controller.play();
                                }
                                setStateDialog(() {});
                              },
                              child: Icon(
                                controller.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.black,
                                size: 36,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            return const Center(child: LoadingWidget());
          },
        );
      },
    );
  }
}
