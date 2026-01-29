import 'package:flutter/material.dart';
import 'dart:math';

import 'package:hr/core/theme/app_colors.dart';

class DashboardData extends StatefulWidget {
  const DashboardData({super.key});

  @override
  State<DashboardData> createState() => _DashboardDataState();
}

class _DashboardDataState extends State<DashboardData> {
  static const double _sectionHeight = 420; // fixed height section

  // Dummy data Top 5 Kehadiran
  final List<Map<String, dynamic>> topAttendance = List.generate(5, (index) {
    return {
      "name": "User ${index + 1}",
      "department": ["HR", "Dev", "Finance", "Ops", "Marketing"][index],
      "present": Random().nextInt(100),
      "ontime": Random().nextInt(100),
    };
  });

  // Dummy data Request Approval
  final List<Map<String, dynamic>> requestApproval = List.generate(5, (index) {
    return {
      "type": index % 2 == 0 ? "Cuti" : "Lembur",
      "employee": "User ${index + 6}",
      "date": "2026-01-${10 + index}",
    };
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return SizedBox(
      height: _sectionHeight, // pakai fixed height
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 3/4 Table Top 5 Kehadiran
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Top 5 Kehadiran",
                          style: TextStyle(
                            color: AppColors.putih,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            child: DataTable(
                              headingRowColor:
                                  MaterialStateProperty.all(AppColors.latar3),
                              dataRowColor: MaterialStateProperty.all(
                                  AppColors.secondary),
                              headingTextStyle: TextStyle(
                                color: AppColors.putih,
                                fontWeight: FontWeight.bold,
                              ),
                              dataTextStyle: TextStyle(color: AppColors.putih),
                              columns: const [
                                DataColumn(label: Text("Nama")),
                                DataColumn(label: Text("Dept")),
                                DataColumn(label: Text("Hadir")),
                                DataColumn(label: Text("Tepat Waktu")),
                              ],
                              rows: topAttendance.map((e) {
                                return DataRow(cells: [
                                  DataCell(Text(e["name"])),
                                  DataCell(Text(e["department"])),
                                  DataCell(Text("${e["present"]}%")),
                                  DataCell(Text("${e["ontime"]}%")),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 1/4 List Request Approval
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Request Approval",
                          style: TextStyle(
                            color: AppColors.putih,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.separated(
                            itemCount: requestApproval.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = requestApproval[index];
                              final color = item["type"] == "Cuti"
                                  ? AppColors.green
                                  : AppColors.yellow;
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item["employee"],
                                          style: TextStyle(
                                            color: AppColors.putih,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${item["type"]} - ${item["date"]}",
                                          style: TextStyle(
                                            color: AppColors.putih
                                                .withOpacity(0.8),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        "Pending",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                // versi mobile stack
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  height: _sectionHeight / 2, // mobile pakai setengah height
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Top 5 Kehadiran",
                        style: TextStyle(
                          color: AppColors.putih,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: DataTable(
                            headingRowColor:
                                MaterialStateProperty.all(AppColors.latar3),
                            dataRowColor:
                                MaterialStateProperty.all(AppColors.secondary),
                            headingTextStyle: TextStyle(
                              color: AppColors.putih,
                              fontWeight: FontWeight.bold,
                            ),
                            dataTextStyle: TextStyle(color: AppColors.putih),
                            columns: const [
                              DataColumn(label: Text("Nama")),
                              DataColumn(label: Text("Dept")),
                              DataColumn(label: Text("Hadir")),
                              DataColumn(label: Text("Tepat Waktu")),
                            ],
                            rows: topAttendance.map((e) {
                              return DataRow(cells: [
                                DataCell(Text(e["name"])),
                                DataCell(Text(e["department"])),
                                DataCell(Text("${e["present"]}%")),
                                DataCell(Text("${e["ontime"]}%")),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  height: _sectionHeight / 2, // mobile pakai setengah height
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Request Approval",
                        style: TextStyle(
                          color: AppColors.putih,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.separated(
                          itemCount: requestApproval.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = requestApproval[index];
                            final color = item["type"] == "Cuti"
                                ? AppColors.green
                                : AppColors.yellow;
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item["employee"],
                                        style: TextStyle(
                                          color: AppColors.putih,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${item["type"]} - ${item["date"]}",
                                        style: TextStyle(
                                          color:
                                              AppColors.putih.withOpacity(0.8),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      "Pending",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
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
