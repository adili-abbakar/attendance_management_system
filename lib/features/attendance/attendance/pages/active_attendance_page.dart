import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/core/widgets/widgets.dart';
import 'package:attendance_management_system/features/attendance/attendance/dialogs/dialogs.dart';
import 'package:attendance_management_system/features/attendance/attendance/providers/attendance_provider.dart';
import 'package:attendance_management_system/features/attendance/attendance/results/attendance_result.dart';
import 'package:attendance_management_system/features/attendance/attendance/services/attendance_service.dart';
import 'package:attendance_management_system/features/attendance/attendance/widgets/widgets.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/helpers/lecture_session_helper.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/models/lecture_session.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/providers/lecture_session_provider.dart';
import 'package:attendance_management_system/features/courses/models/course.dart';
import 'package:attendance_management_system/features/scanner/pages/scanner_page.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:attendance_management_system/features/students/services/student_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActiveAttendancePage extends StatefulWidget {
  const ActiveAttendancePage({
    super.key,
    required this.lectureSession,
    required this.course,
  });

  final LectureSession lectureSession;
  final Course course;

  @override
  State<ActiveAttendancePage> createState() => _ActiveAttendancePageState();
}

class _ActiveAttendancePageState extends State<ActiveAttendancePage> {
  final StudentService _studentService = StudentService.instance;
  final AttendanceService _attendanceService = AttendanceService.instance;

  int get _lectureSessionId => widget.lectureSession.id!;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPageData();
    });
  }

  Future<void> _loadPageData() async {
    if (!mounted) return;

    final lectureSessionProvider = context.read<LectureSessionProvider>();
    final attendanceProvider = context.read<AttendanceProvider>();

    await Future.wait([
      lectureSessionProvider.loadLectureSession(_lectureSessionId),
      attendanceProvider.loadRecords(_lectureSessionId),
    ]);
  }

  LectureSession _currentLectureSession(LectureSessionProvider provider) {
    return provider.selectedLectureSession ?? widget.lectureSession;
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    return Consumer2<LectureSessionProvider, AttendanceProvider>(
      builder: (context, lectureSessionProvider, attendanceProvider, child) {
        final lectureSession = _currentLectureSession(lectureSessionProvider);

        return Scaffold(
          appBar: AppBarWidget(title: 'Active Attendance'),
          endDrawer: AppDrawer(),

          body: Padding(
            padding: EdgeInsets.all(r.pagePadding),
            child: Column(
              children: [
                ActiveAttendanceHeader(
                  lectureSession: lectureSession,
                  courseName: widget.course.title,
                  courseCode: widget.course.code,
                  attendanceCount: attendanceProvider.attendanceCount,
                ),

                SizedBox(height: r.spacingL),

                Expanded(
                  child: AttendanceRecordsList(
                    lectureSessionId: lectureSession.id!,
                    records: attendanceProvider.records,
                    isLoading: attendanceProvider.isLoading,
                    errorMessage: attendanceProvider.errorMessage,
                    onRetry: () {
                      attendanceProvider.loadRecords(lectureSession.id!);
                    },
                    studentService: _studentService,
                  ),
                ),
              ],
            ),
          ),

          floatingActionButton: _buildFloatingActions(
            context,
            lectureSession,
            attendanceProvider,
          ),
        );
      },
    );
  }

  Widget? _buildFloatingActions(
    BuildContext context,
    LectureSession lectureSession,
    AttendanceProvider attendanceProvider,
  ) {
    if (lectureSession.isActive) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () async {
              await LectureSessionHelper.completeSession(
                context,
                lectureSession,
              );
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Complete Attendance'),
          ),

          const SizedBox(height: 12),

          FloatingActionButton.extended(
            onPressed: attendanceProvider.isScanning
                ? null
                : () => _openScanner(context),
            icon: attendanceProvider.isScanning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.qr_code_scanner),
            label: Text(
              attendanceProvider.isScanning ? 'Processing...' : 'Scan QR',
            ),
          ),
        ],
      );
    }

    if (lectureSession.isScheduled) {
      return FloatingActionButton.extended(
        onPressed: lectureSessionProviderIsLoading(context)
            ? null
            : () async {
                await LectureSessionHelper.startSession(
                  context,
                  lectureSession,
                  isInActivaPage: true,
                  course: widget.course,
                );
              },
        icon: const Icon(Icons.play_arrow),
        label: const Text('Start Lecture'),
      );
    }

    // Completed session.
    return null;
  }

  bool lectureSessionProviderIsLoading(BuildContext context) {
    return context.read<LectureSessionProvider>().isLoading;
  }

  Future<void> _openScanner(BuildContext context) async {
    final admissionNumber = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const ScannerPage()),
    );

    if (!context.mounted || admissionNumber == null) {
      return;
    }

    await _processScannedStudent(context, admissionNumber);
  }

  Future<void> _processScannedStudent(
    BuildContext context,
    String admissionNumber,
  ) async {
    final attendanceProvider = context.read<AttendanceProvider>();

    final student = await _studentService.getStudentByAdmissionNumber(
      admissionNumber,
    );

    if (!context.mounted) {
      return;
    }

    if (student == null) {
      await _showInvalidStudentDialog(context);
      return;
    }

    if (student.id == null) {
      await _showErrorDialog(context, 'The student record is invalid.');
      return;
    }

    final isEnrolled = await _attendanceService
        .isStudentEnrolledForLectureSession(
          lectureSessionId: _lectureSessionId,
          studentId: student.id!,
        );

    if (!context.mounted) {
      return;
    }

    if (!isEnrolled) {
      await _showNotEnrolledDialog(context, student);
      return;
    }

    final result = await attendanceProvider.recordAttendance(
      lectureSessionId: _lectureSessionId,
      admissionNumber: admissionNumber,
    );

    if (!context.mounted) {
      return;
    }

    await _handleAttendanceResult(context, result);
  }

  Future<void> _handleAttendanceResult(
    BuildContext context,
    AttendanceResult result,
  ) async {
    switch (result.status) {
      case AttendanceResultStatus.success:
        await _showSuccessDialog(context, result);
        break;

      case AttendanceResultStatus.studentNotFound:
      case AttendanceResultStatus.invalidAdmissionNumber:
        await _showInvalidStudentDialog(context);
        break;

      case AttendanceResultStatus.studentNotEnrolled:
        if (result.student != null) {
          await _showNotEnrolledDialog(context, result.student!);
        } else {
          await _showErrorDialog(
            context,
            result.message ?? 'The student is not enrolled in this course.',
          );
        }
        break;

      case AttendanceResultStatus.alreadyAttended:
        await _showAlreadyAttendedDialog(context, result);
        break;

      case AttendanceResultStatus.lectureSessionNotActive:
        await _showSessionInactiveDialog(context, result);
        break;

      case AttendanceResultStatus.error:
        await _showErrorDialog(
          context,
          result.message ??
              'An unexpected error occurred while recording attendance.',
        );
        break;
    }
  }

  Future<void> _showSuccessDialog(
    BuildContext context,
    AttendanceResult result,
  ) async {
    if (result.student == null) {
      return;
    }

    final action = await showDialog<AttendanceDialogAction>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AttendanceSuccessDialog(student: result.student!),
    );

    if (!context.mounted) {
      return;
    }

    if (action == AttendanceDialogAction.scanNext) {
      await _openScanner(context);
    }
  }

  Future<void> _showInvalidStudentDialog(BuildContext context) async {
    final action = await showDialog<AttendanceDialogAction>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const InvalidStudentDialog(),
    );

    if (!context.mounted) {
      return;
    }

    if (action == AttendanceDialogAction.scanNext) {
      await _openScanner(context);
    }
  }

  Future<void> _showNotEnrolledDialog(
    BuildContext context,
    Student student,
  ) async {
    final action = await showDialog<AttendanceDialogAction>(
      context: context,
      barrierDismissible: false,
      builder: (_) => StudentNotEnrolledDialog(student: student),
    );

    if (!context.mounted) {
      return;
    }

    switch (action) {
      case AttendanceDialogAction.scanNext:
        await _openScanner(context);
        break;

      case AttendanceDialogAction.addToCourse:
        await _enrollStudentOnly(context, student);
        break;

      case AttendanceDialogAction.recordAndScanNext:
        await _enrollAndRecord(context, student);
        break;

      case AttendanceDialogAction.done:
      case null:
        break;
    }
  }

  Future<void> _enrollStudentOnly(BuildContext context, Student student) async {
    final result = await _attendanceService.enrollStudent(
      lectureSessionId: _lectureSessionId,
      admissionNumber: student.admissionNumber,
    );

    if (!context.mounted) {
      return;
    }

    if (!result.isSuccess) {
      await _showErrorDialog(
        context,
        result.message ?? 'Failed to add the student to this course.',
      );
      return;
    }

    await context.read<AttendanceProvider>().loadRecords(_lectureSessionId);

    if (!context.mounted) {
      return;
    }

    final action = await showDialog<AttendanceDialogAction>(
      context: context,
      barrierDismissible: false,
      builder: (_) => StudentEnrolledDialog(student: student),
    );

    if (!context.mounted) {
      return;
    }

    if (action == AttendanceDialogAction.scanNext) {
      await _openScanner(context);
    }
  }

  Future<void> _enrollAndRecord(BuildContext context, Student student) async {
    final result = await _attendanceService.enrollAndRecordAttendance(
      lectureSessionId: _lectureSessionId,
      admissionNumber: student.admissionNumber,
    );

    if (!context.mounted) {
      return;
    }

    if (!result.isSuccess) {
      await _handleAttendanceResult(context, result);
      return;
    }

    await context.read<AttendanceProvider>().loadRecords(_lectureSessionId);

    if (!context.mounted) {
      return;
    }

    await _openScanner(context);
  }

  Future<void> _showAlreadyAttendedDialog(
    BuildContext context,
    AttendanceResult result,
  ) async {
    final action = await showDialog<AttendanceDialogAction>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlreadyAttendedDialog(
        student: result.student,
        message: result.message,
      ),
    );

    if (!context.mounted) {
      return;
    }

    if (action == AttendanceDialogAction.scanNext) {
      await _openScanner(context);
    }
  }

  Future<void> _showSessionInactiveDialog(
    BuildContext context,
    AttendanceResult result,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AttendanceSessionInactiveDialog(message: result.message),
    );
  }

  Future<void> _showErrorDialog(BuildContext context, String message) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AttendanceErrorDialog(message: message),
    );
  }
}
