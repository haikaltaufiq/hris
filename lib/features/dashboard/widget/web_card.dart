import 'package:flutter/material.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebCard extends StatefulWidget {
  const WebCard({super.key});

  @override
  State<WebCard> createState() => _WebCardState();
}

class _WebCardState extends State<WebCard> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  String _nama = '';
  String _peran = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nama = prefs.getString('nama') ?? '';
      _peran = prefs.getString('peran') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 800;

                    return isNarrow
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _welcomeCard(),
                              const SizedBox(height: 10),
                              _statSection(),
                              const SizedBox(height: 10),
                              _overviewCard(),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Welcome Card
                              Flexible(
                                flex: 2,
                                child: _welcomeCard(),
                              ),
                              const SizedBox(width: 10),

                              // Stats
                              Flexible(
                                flex: 3,
                                child: _statSection(),
                              ),
                              const SizedBox(width: 10),

                              // Overview
                              Flexible(
                                flex: 2,
                                child: _overviewCard(),
                              ),
                            ],
                          );
                  },
                ),
              ),
            ),
          );
        });
  }

  /// Bagian Stats Column biar rapih
  Widget _statSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _statCard(
          title: "Departments",
          value: "8",
          subtitle: "Active divisions",
          icon: Icons.business_outlined,
        ),
        const SizedBox(height: 10),
        _statCard(
          title: "Employees",
          value: "247",
          subtitle: "+12 this month",
          icon: Icons.people_outline,
          isGrowth: true,
        ),
        const SizedBox(height: 10),
        _statCard(
          title: "Active Tasks",
          value: "31",
          subtitle: "Due this week",
          icon: Icons.assignment_outlined,
        ),
      ],
    );
  }

  /// Welcome Card
  Widget _welcomeCard() {
    return Container(
      height: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome Back,",
                style: TextStyle(
                  color: AppColors.putih.withOpacity(0.8),
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                _nama,
                style: TextStyle(
                  color: AppColors.putih,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                _peran,
                style: TextStyle(
                  color: AppColors.putih.withOpacity(0.5),
                  fontSize: 16,
                  fontWeight: FontWeight.w200,
                  height: 1.1,
                  letterSpacing: -1.0,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 22,
          ),
          // Today's Cards Row
          Row(
            children: [
              Expanded(
                child: _todayCard(
                  title: "Today's Attendance",
                  value: "120 / 247",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _todayCard(
                  title: "User Online",
                  value: "12 / 247",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Reusable Today Card
  Widget _todayCard({required String title, required String value}) {
    final screenHeight = MediaQuery.of(context).size.height;

    final cardHeight = screenHeight * 0.2; // responsive height

    return Container(
      height: cardHeight,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[700],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          // make value responsive with Flexible + FittedBox
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.bottomLeft,
              child: Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize:
                      34, // tetap pake style asli, FittedBox yg nge-handle
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Stat Card
  Widget _statCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    bool isGrowth = false,
  }) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, color: AppColors.putih, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.putih,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.putih.withOpacity(0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.putih.withOpacity(0.5),
                  fontSize: 9,
                  fontWeight: FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Overview Card
  Widget _overviewCard() {
    return Container(
        height: 320,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Monthly Overview",
              style: TextStyle(
                color: AppColors.putih,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),

            // Progress items dibungkus biar gak nabrak
            Flexible(
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _progress("Attendance Rate", 0.94, const Color(0xFF4EDD53)),
                  const SizedBox(height: 16),
                  _progress("Project Completion", 0.78, Colors.orange),
                  const SizedBox(height: 16),
                  _progress("Performance Score", 0.86,
                      const Color.fromARGB(255, 62, 168, 255)),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Footer card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "This Week",
                        style: TextStyle(
                          color: AppColors.putih.withOpacity(0.7),
                          fontSize: 10, // lebih kecil
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "98.2%",
                        style: TextStyle(
                          color: AppColors.putih,
                          fontSize: 16, // tadinya 20, gue kecilin
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 28, // lebih kecil dari 36
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.check_circle_outline,
                      color: Colors.green[400],
                      size: 14, // kecilin juga biar proporsional
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }

  Widget _progress(String title, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppColors.putih.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "${(progress * 100).toInt()}%",
              style: TextStyle(
                color: AppColors.putih,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: progress,
            color: color,
            backgroundColor: AppColors.putih.withOpacity(0.1),
            minHeight: 12,
          ),
        ),
      ],
    );
  }
}
