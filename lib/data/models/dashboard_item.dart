import 'package:flutter/material.dart';

class DashboardMenuItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final dynamic requiredFeature;
  DashboardMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.requiredFeature,
  });
}
