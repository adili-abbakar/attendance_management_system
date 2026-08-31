import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/attendance/attendance/models/attendance_record.dart';
import 'package:attendance_management_system/features/attendance/attendance/widgets/attendance_record_tile.dart';
import 'package:attendance_management_system/features/students/services/student_service.dart';
import 'package:flutter/material.dart';

class AttendanceRecordsList extends StatelessWidget {
  const AttendanceRecordsList({
    super.key,
    required this.lectureSessionId,
    required this.records,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.studentService,
  });

  final int lectureSessionId;
  final List<AttendanceRecord> records;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final StudentService studentService;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: r.iconLarge),
            SizedBox(height: r.spacingM),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: r.body),
            ),
            SizedBox(height: r.spacingM),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: r.iconLarge),
            SizedBox(height: r.spacingM),
            Text(
              'No attendance recorded yet.',
              style: TextStyle(fontSize: r.body),
            ),
            SizedBox(height: r.spacingXS),
            Text(
              'Scan a student QR code to record attendance.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: r.bodySmall,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];

        return FutureBuilder(
          future: studentService.getStudent(record.studentId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ListTile(
                leading: CircleAvatar(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                title: Text('Loading student...'),
              );
            }

            final student = snapshot.data;

            if (student == null) {
              return const ListTile(
                leading: Icon(Icons.person_off_outlined),
                title: Text('Student not found'),
                subtitle: Text('The student record could not be loaded.'),
              );
            }

            return AttendanceRecordTile(
              record: record,
              studentName: student.fullName,
              admissionNumber: student.admissionNumber,
            );
          },
        );
      },
    );
  }
}
