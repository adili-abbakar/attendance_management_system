import 'package:attendance_management_system/core/buttons/buttons.dart';
import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/attendance/attendance/models/models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum AttendanceVerificationDialogAction { done, scanAgain }

class AttendanceVerificationDialog extends StatelessWidget {
  const AttendanceVerificationDialog({super.key, required this.verification});

  final AttendanceVerification verification;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final theme = Theme.of(context);

    final screenWidth = MediaQuery.sizeOf(context).width;
    final availableWidth = screenWidth - (r.dialogInset * 2);

    final dialogWidth = availableWidth < r.dialogWidth
        ? availableWidth
        : r.dialogWidth;

    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: r.dialogInset,
        vertical: r.dialogInset,
      ),
      title: Text(
        'Attendance Verification',
        style: theme.textTheme.titleLarge?.copyWith(
          fontSize: r.titleLarge,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StudentHeader(verification: verification),
              SizedBox(height: r.spacingM),
              _AttendanceSummary(verification: verification),
              SizedBox(height: r.spacingL),
              Text(
                'Lecture Sessions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: r.titleMedium,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: r.spacingS),
              if (verification.sessions.isEmpty)
                _EmptySessions(
                  message: 'No lecture sessions have been recorded yet.',
                )
              else
                ...verification.sessions.map(
                  (session) => Padding(
                    padding: EdgeInsets.only(bottom: r.spacingS),
                    child: _SessionItem(verificationSession: session),
                  ),
                ),
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        AppTextButton(
          text: 'Done',
          onPressed: () =>
              Navigator.pop(context, AttendanceVerificationDialogAction.done),
        ),
        PrimaryButton(
          width: 125,
          text: 'Scan Again',
          icon: Icons.qr_code_scanner_rounded,
          onPressed: () => Navigator.pop(
            context,
            AttendanceVerificationDialogAction.scanAgain,
          ),
        ),
      ],
    );
  }
}

class _StudentHeader extends StatelessWidget {
  const _StudentHeader({required this.verification});

  final AttendanceVerification verification;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(r.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceBright,
        borderRadius: BorderRadius.circular(r.radius),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: r.avatarRadius,
            backgroundColor: colors.primaryContainer,
            child: Icon(
              Icons.person_rounded,
              size: r.iconMedium,
              color: colors.onPrimaryContainer,
            ),
          ),
          SizedBox(width: r.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  verification.student.fullName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: r.titleMedium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: r.spacingXS),
                Text(
                  verification.student.admissionNumber,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: r.bodySmall,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: r.spacingXS),
                Text(
                  '${verification.course.code} • ${verification.course.title}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: r.bodySmall,
                    color: colors.onSurfaceVariant,
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

class _AttendanceSummary extends StatelessWidget {
  const _AttendanceSummary({required this.verification});

  final AttendanceVerification verification;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final percentage = verification.attendancePercentage;

    return Container(
      padding: EdgeInsets.all(r.cardPadding),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(r.radius),
      ),
      child: Column(
        children: [
          Text(
            'Attendance Percentage',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: r.body,
              color: colors.onPrimaryContainer,
            ),
          ),
          SizedBox(height: r.spacingXS),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: theme.textTheme.displaySmall?.copyWith(
              fontSize: r.display,
              fontWeight: FontWeight.bold,
              color: colors.onPrimaryContainer,
            ),
          ),
          SizedBox(height: r.spacingS),
          Text(
            '${verification.attendedSessions} of '
            '${verification.totalSessions} sessions attended',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: r.bodySmall,
              color: colors.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionItem extends StatelessWidget {
  const _SessionItem({required this.verificationSession});

  final AttendanceVerificationSession verificationSession;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final session = verificationSession.lectureSession;

    final statusBackground = verificationSession.isPresent
        ? colors.primaryContainer
        : colors.errorContainer;

    final statusTextColor = verificationSession.isPresent
        ? colors.onPrimaryContainer
        : colors.onErrorContainer;

    return Container(
      padding: EdgeInsets.all(r.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceBright,
        borderRadius: BorderRadius.circular(r.radius),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: r.iconLarge,
            height: r.iconLarge,
            decoration: BoxDecoration(
              color: statusBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              verificationSession.isPresent
                  ? Icons.check_rounded
                  : Icons.close_rounded,
              size: r.iconMedium,
              color: statusTextColor,
            ),
          ),
          SizedBox(width: r.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _sessionName(session),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: r.titleMedium,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: r.spacingXS),
                Text(
                  _formatSessionDate(session.lectureDate),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: r.bodySmall,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: r.spacingXS),
                Text(
                  '${session.fromTime} - ${session.toTime}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: r.bodySmall,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                if (verificationSession.scannedAt != null) ...[
                  SizedBox(height: r.spacingXS),
                  Text(
                    'Scanned: ${_formatScannedAt(verificationSession.scannedAt!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: r.caption,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: r.spacingS),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: r.spacingS,
              vertical: r.spacingXS,
            ),
            decoration: BoxDecoration(
              color: statusBackground,
              borderRadius: BorderRadius.circular(r.radius),
            ),
            child: Text(
              verificationSession.isPresent ? 'Present' : 'Absent',
              style: theme.textTheme.labelMedium?.copyWith(
                fontSize: r.caption,
                fontWeight: FontWeight.w600,
                color: statusTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _sessionName(dynamic session) {
    try {
      return session.lectureSessionName as String;
    } catch (_) {
      return 'Session ${session.sessionNumber}';
    }
  }

  String _formatSessionDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatScannedAt(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }
}

class _EmptySessions extends StatelessWidget {
  const _EmptySessions({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(r.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceBright,
        borderRadius: BorderRadius.circular(r.radius),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: r.body,
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }
}
