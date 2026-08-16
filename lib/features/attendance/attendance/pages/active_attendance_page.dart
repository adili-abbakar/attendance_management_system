import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/attendance/attendance/providers/attendance_provider.dart';
import 'package:attendance_management_system/features/attendance/attendance/widgets/attendance_record_tile.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/models/lecture_session.dart';
import 'package:attendance_management_system/features/students/services/student_service.dart';

class ActiveAttendancePage extends StatefulWidget {
  const ActiveAttendancePage({super.key, required this.lectureSession});

  final LectureSession lectureSession;

  @override
  State<ActiveAttendancePage> createState() => _ActiveAttendancePageState();
}

class _ActiveAttendancePageState extends State<ActiveAttendancePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().loadRecords(widget.lectureSession.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Active Attendance',
          style: TextStyle(fontSize: r.titleLarge),
        ),
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: EdgeInsets.all(r.pagePadding),
            child: Column(
              children: [
                _buildSessionHeader(context, r, provider),
                SizedBox(height: r.spacingL),
                Expanded(child: _buildAttendanceList(context, r, provider)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showScannerPlaceholder(context);
        },
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scan QR'),
      ),
    );
  }

  Widget _buildSessionHeader(
    BuildContext context,
    AppResponsive r,
    AttendanceProvider provider,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(r.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.lectureSession.lectureSessionName,
              style: TextStyle(
                fontSize: r.titleLarge,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: r.spacingS),

            Text(
              '${widget.lectureSession.fromTime} – '
              '${widget.lectureSession.toTime}',
              style: TextStyle(fontSize: r.body),
            ),

            SizedBox(height: r.spacingXS),

            Text(
              'Week ${widget.lectureSession.weekNumber}',
              style: TextStyle(
                fontSize: r.bodySmall,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),

            SizedBox(height: r.spacingM),

            Row(
              children: [
                Icon(Icons.people_outline, size: r.iconSmall),
                SizedBox(width: r.spacingXS),
                Text(
                  '${provider.attendanceCount} students present',
                  style: TextStyle(
                    fontSize: r.body,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceList(
    BuildContext context,
    AppResponsive r,
    AttendanceProvider provider,
  ) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: r.iconLarge),
            SizedBox(height: r.spacingM),
            Text(
              provider.errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: r.body),
            ),
            SizedBox(height: r.spacingM),
            FilledButton(
              onPressed: () {
                provider.loadRecords(widget.lectureSession.id!);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.records.isEmpty) {
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
      itemCount: provider.records.length,
      itemBuilder: (context, index) {
        final record = provider.records[index];

        return FutureBuilder(
          future: StudentService.instance.getStudent(record.studentId),
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

              // Replace this with the actual name fields
              // from your Student model.
              studentName: student.admissionNumber,

              admissionNumber: student.admissionNumber,
            );
          },
        );
      },
    );
  }

  void _showScannerPlaceholder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR scanner will be connected here.')),
    );
  }
}
