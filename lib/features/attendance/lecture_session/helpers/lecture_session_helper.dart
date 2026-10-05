import 'dart:core';

import 'package:attendance_management_system/core/dialogs/delete_confirmation_dialog.dart';
import 'package:attendance_management_system/features/attendance/attendance/pages/active_attendance_page.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/dialogs/lecture_session_form_dialog.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/models/lecture_session.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/pages/lecture_session_details_page.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/providers/lecture_session_provider.dart';
import 'package:attendance_management_system/features/courses/models/course.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LectureSessionHelper {
  const LectureSessionHelper._();

  static Future<void> startSession(
    BuildContext context,
    LectureSession lectureSession, {
    bool isInActivaPage = false,
    required Course course,
  }) async {
    final provider = context.read<LectureSessionProvider>();

    final success = await provider.startLectureSession(lectureSession);

    if (!context.mounted) {
      return;
    }

    if (!success) {
      showResult(
        context,
        provider.errorMessage ?? 'Failed to start lecture session.',
      );
      return;
    }

    if (!isInActivaPage) {
      final updatedSession = provider.selectedLectureSession ?? lectureSession;

      await viewAttendance(context, updatedSession, course: course);
    }
  }

  static Future<void> completeSession(
    BuildContext context,
    LectureSession lectureSession,
  ) async {
    final provider = context.read<LectureSessionProvider>();

    final success = await provider.completeLectureSession(lectureSession);

    if (!context.mounted) {
      return;
    }

    showResult(
      context,
      success
          ? 'Lecture session completed.'
          : provider.errorMessage ?? 'Failed to complete lecture session.',
    );
  }

  static Future<void> viewAttendance(
    BuildContext context,
    LectureSession lectureSession, {
    required Course course,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveAttendancePage(
          lectureSession: lectureSession,
          course: course,
        ),
      ),
    );
  }

  static void showResult(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  static void openDetails(
    BuildContext context,
    LectureSession lectureSession,
    Course course,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LectureSessionDetailsPage(
          lectureSessionId: lectureSession.id!,
          course: course,
        ),
      ),
    );
  }

  static Future<void> showDeleteSessionDialog(
    BuildContext context,
    LectureSession lectureSession,
    String courseCode,
  ) async {
    await showDialog(
      context: context,
      builder: (_) {
        return DeleteConfirmationDialog(
          title: 'Delete Lecture Session',
          itemName: '$courseCode — ${lectureSession.lectureSessionName}',
          onDelete: () async {
            await deleteSession(context, lectureSession);
          },
        );
      },
    );
  }

  static Future<void> deleteSession(
    BuildContext context,
    LectureSession lectureSession,
  ) async {
    final provider = context.read<LectureSessionProvider>();

    final success = await provider.deleteLectureSession(lectureSession);

    if (!context.mounted) {
      return;
    }

    showResult(
      context,
      success
          ? 'Lecture session deleted.'
          : provider.errorMessage ?? 'Failed to delete lecture session.',
    );
  }

  static Future<void> updateSession(
    BuildContext context,
    LectureSession lectureSession,
    int courseId,
  ) async {
    await showDialog(
      context: context,
      builder: (_) => LectureSessionFormDialog(
        courseId: courseId,
        initialSession: lectureSession,
      ),
    );
  }
}
