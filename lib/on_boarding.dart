import 'package:flutter/material.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  final PageController _controller = PageController();
  bool _isLastPage = false;

  final List<Map<String, String>> _pages = [
    {
      "title": "Human Resource",
      "subtitle":
          "Kelola absensi, cuti, gaji, dan semua kebutuhan HR jadi lebih mudah.",
      "image": "assets/images/hris.png",
    },
    {
      "title": "Attendance Tracking",
      "subtitle": "Monitoring kehadiran karyawan jadi cepat dan transparan.",
      "image": "assets/images/attendance.png",
    },
    {
      "title": "Task Management",
      "subtitle": "Pengelolaan tugas karyawan yang efisien dan terstruktur.",
      "image": "assets/images/task.png",
    },
    {
      "title": "Integrated Data",
      "subtitle": "Gabung dan nikmati kemudahan dalam manajemen HR.",
      "image": "assets/images/data.png",
    },
  ];

  Future<void> _finishOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);

    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      context.isNativeMobile
          ? AppRoutes.landingPageMobile
          : AppRoutes.landingPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() => _isLastPage = index == _pages.length - 1);
            },
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                          height:
                              60), // jarak dari atas biar title ga nempel status bar
                      Text(
                        page["title"]!,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 150),

                      // gambar selalu di tengah
                      Center(
                        child: Image.asset(
                          page["image"]!,
                          fit: BoxFit.contain,
                          height: 280,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        page["subtitle"]!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 60), // jarak bawah biar lega
                    ],
                  ));
            },
          ),

          // Skip button
          Positioned(
            top: 30,
            right: 20,
            child: !_isLastPage
                ? TextButton(
                    onPressed: () {
                      _finishOnboarding(context);
                    },
                    child: const Text(
                      "Skip",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Indicator + Button
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _controller,
                  count: _pages.length,
                  effect: const WormEffect(
                    dotHeight: 10,
                    dotWidth: 10,
                    spacing: 12,
                    activeDotColor: Colors.white,
                    dotColor: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(AppColors.blue),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    onPressed: () {
                      if (_isLastPage) {
                        _finishOnboarding(context);
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(
                      "Next",
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
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
