import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hr/core/theme/app_colors.dart';
import 'package:hr/features/auth/login_viewmodels.dart/login_provider.dart';
import 'package:hr/features/dashboard/widget/hover_tooltip.dart';
import 'package:hr/features/department/view_model/department_viewmodels.dart';
import 'package:hr/features/task/task_viewmodel/tugas_provider.dart';
import 'package:provider/provider.dart';

class DashboardCard extends StatefulWidget {
  const DashboardCard({super.key});

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  late final totalUser = context.read<UserProvider>().totalUsers.toString();
  late final totalDepartment =
      context.read<DepartmentViewModel>().totalDepartment.toString();
  late final totalTask = context.read<TugasProvider>().totalTugas.toString();

  late List<Map<String, dynamic>> rawCardData = [
    {
      'title': 'Employee Total',
      'value': totalUser,
      'icon': '3',
    },
    {
      'title': 'Departments',
      'value': totalDepartment,
      'icon': '2',
    },
    {
      'title': 'Active Projects',
      'value': totalTask,
      'icon': '1',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    // generate cardData runtime
    final List<Map<String, dynamic>> cardData = rawCardData.map((data) {
      return {
        ...data,
        'icon': isMobile
            ? 'assets/images/${data['icon']}.png'
            : 'assets/images/${data['icon']}.webp',
      };
    }).toList();
    if (isMobile) {
      // Mobile pake PageView
      return SizedBox(
        height: max(100, MediaQuery.of(context).size.height * 0.12),
        child: PageView.builder(
          itemCount: cardData.length,
          controller: PageController(viewportFraction: 1.0),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: _buildCard(context, cardData[index]),
            );
          },
        ),
      );
    } else {
      // Non mobile jadi 3 row langsung
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: cardData.map((data) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: _buildCard(context, data),
            ),
          );
        }).toList(),
      );
    }
  }

  Widget _buildCard(BuildContext context, Map<String, dynamic> data) {
    return HoverTooltip(
      message: "${data['title']}: ${data['value']}",
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primary,
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data['title'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                      color: AppColors.putih,
                    ),
                  ),
                  Text(
                    data['value'],
                    style: TextStyle(
                      fontSize: 25,
                      color: AppColors.putih,
                      fontWeight: FontWeight.w900,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -10,
            right: 10,
            child: SizedBox(
              height: max(130, MediaQuery.of(context).size.height * 0.12) * 0.9,
              child: Image.asset(
                data['icon'],
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
