import 'package:flutter/material.dart';
import 'package:hr/core/utils/device_size.dart';
import 'package:hr/features/task/mobile/tugas_page.dart';
import 'package:hr/features/task/web/task_web_page.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      return TugasMobile();
    }
    return TaskWebPage();
  }
}
