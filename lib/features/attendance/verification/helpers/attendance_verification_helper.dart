import 'package:attendance_management_system/features/attendance/attendance/dialogs/dialogs.dart';
import 'package:attendance_management_system/features/attendance/attendance/providers/attendance_provider.dart';
import 'package:attendance_management_system/features/attendance/attendance/results/attendance_verification_result.dart';
import 'package:attendance_management_system/features/attendance/attendance/widgets/attendance_dialog_action.dart';
import 'package:attendance_management_system/features/courses/models/course.dart';
import 'package:attendance_management_system/features/scanner/pages/scanner_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AttendanceVerificationHelper {
  const AttendanceVerificationHelper._();

  /// Starts the complete attendance verification workflow for a course.
  ///
  /// This includes:
  /// - Opening the scanner.
  /// - Reading the student's admission number.
  /// - Verifying the student through [AttendanceProvider].
  /// - Showing the appropriate verification result dialog.
  /// - Allowing the user to scan another student when requested.
  static Future<void> verifyStudent({
    required BuildContext context,
    required Course course,
  }) async {
    await _scanStudent(context: context, course: course);
  }

  /// Opens the scanner and verifies the scanned student.
  static Future<void> _scanStudent({
    required BuildContext context,
    required Course course,
  }) async {
    final admissionNumber = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => ScannerPage()),
    );

    if (!context.mounted || admissionNumber == null) {
      return;
    }

    final provider = context.read<AttendanceProvider>();

    final result = await provider.verifyStudentAttendance(
      course: course,
      admissionNumber: admissionNumber,
    );

    if (!context.mounted) {
      return;
    }

    await _handleVerificationResult(
      context: context,
      course: course,
      result: result,
    );
  }

  /// Handles every possible attendance verification result.
  static Future<void> _handleVerificationResult({
    required BuildContext context,
    required Course course,
    required AttendanceVerificationResult result,
  }) async {
    if (result.isSuccess && result.verification != null) {
      final action = await showDialog<AttendanceVerificationDialogAction>(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            AttendanceVerificationDialog(verification: result.verification!),
      );

      if (!context.mounted) {
        return;
      }

      if (action == AttendanceVerificationDialogAction.scanAgain) {
        await _scanStudent(context: context, course: course);
      }

      return;
    }

    if (result.isStudentNotFound) {
      final action = await showDialog<AttendanceDialogAction>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const InvalidStudentDialog(),
      );

      if (!context.mounted) {
        return;
      }

      if (action == AttendanceDialogAction.scanNext) {
        await _scanStudent(context: context, course: course);
      }

      return;
    }

    if (result.isStudentNotEnrolled) {
      final student = result.student;

      if (student == null) {
        await _showVerificationError(
          context: context,
          message:
              result.message ?? 'The student is not enrolled in this course.',
        );
        return;
      }

      final action = await showDialog<AttendanceDialogAction>(
        context: context,
        barrierDismissible: false,
        builder: (_) => StudentNotEnrolledDialog(student: student),
      );

      if (!context.mounted) {
        return;
      }

      if (action == AttendanceDialogAction.scanNext) {
        await _scanStudent(context: context, course: course);
      }

      return;
    }

    await _showVerificationError(
      context: context,
      message: result.message ?? 'Failed to verify student attendance.',
    );
  }

  /// Displays a generic attendance verification error.
  static Future<void> _showVerificationError({
    required BuildContext context,
    required String message,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AttendanceErrorDialog(message: message),
    );
  }
}
