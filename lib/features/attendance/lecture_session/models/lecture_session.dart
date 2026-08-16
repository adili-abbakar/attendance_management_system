import 'package:attendance_management_system/features/attendance/lecture_session/tables/lecture_session_table.dart';

enum LectureSessionStatus { scheduled, active, completed }

class LectureSession {
  final int? id;
  final int courseId;
  final int sessionNumber;
  final int weekNumber;
  final DateTime lectureDate;
  final String fromTime;
  final String toTime;
  final int durationMinutes;
  final LectureSessionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startedAt;

  const LectureSession({
    this.id,
    required this.courseId,
    required this.sessionNumber,
    required this.weekNumber,
    required this.lectureDate,
    required this.fromTime,
    required this.toTime,
    required this.durationMinutes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.startedAt,
  });

  factory LectureSession.fromMap(Map<String, dynamic> map) {
    return LectureSession(
      id: map[LectureSessionTable.id] as int?,
      courseId: map[LectureSessionTable.courseId] as int,
      sessionNumber: map[LectureSessionTable.sessionNumber] as int,
      weekNumber: map[LectureSessionTable.weekNumber] as int,
      lectureDate: DateTime.parse(
        map[LectureSessionTable.lectureDate] as String,
      ),
      fromTime: map[LectureSessionTable.fromTime] as String,
      toTime: map[LectureSessionTable.toTime] as String,
      durationMinutes: map[LectureSessionTable.durationMinutes] as int,
      status: LectureSessionStatus.values.firstWhere(
        (value) => value.name == map[LectureSessionTable.status],
        orElse: () => LectureSessionStatus.scheduled,
      ),
      createdAt: DateTime.parse(map[LectureSessionTable.createdAt] as String),
      updatedAt: DateTime.parse(map[LectureSessionTable.updatedAt] as String),
      startedAt: map[LectureSessionTable.startedAt] != null
          ? DateTime.parse(map[LectureSessionTable.startedAt] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      LectureSessionTable.id: id,
      LectureSessionTable.courseId: courseId,
      LectureSessionTable.sessionNumber: sessionNumber,
      LectureSessionTable.weekNumber: weekNumber,
      LectureSessionTable.lectureDate: lectureDate.toIso8601String(),
      LectureSessionTable.fromTime: fromTime,
      LectureSessionTable.toTime: toTime,
      LectureSessionTable.durationMinutes: durationMinutes,
      LectureSessionTable.status: status.name,
      LectureSessionTable.createdAt: createdAt.toIso8601String(),
      LectureSessionTable.updatedAt: updatedAt.toIso8601String(),
      LectureSessionTable.startedAt: startedAt?.toIso8601String(),
    };
  }

  LectureSession copyWith({
    int? id,
    int? courseId,
    int? sessionNumber,
    int? weekNumber,
    DateTime? lectureDate,
    String? fromTime,
    String? toTime,
    int? durationMinutes,
    LectureSessionStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? startedAt,
  }) {
    return LectureSession(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      sessionNumber: sessionNumber ?? this.sessionNumber,
      weekNumber: weekNumber ?? this.weekNumber,
      lectureDate: lectureDate ?? this.lectureDate,
      fromTime: fromTime ?? this.fromTime,
      toTime: toTime ?? this.toTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startedAt: startedAt ?? this.startedAt,
    );
  }

  factory LectureSession.empty({required int courseId, int sessionNumber = 1}) {
    final now = DateTime.now();

    return LectureSession(
      courseId: courseId,
      sessionNumber: sessionNumber,
      weekNumber: 1,
      lectureDate: DateTime(now.year, now.month, now.day),
      fromTime: '08:00',
      toTime: '10:00',
      durationMinutes: 120,
      status: LectureSessionStatus.scheduled,
      createdAt: now,
      updatedAt: now,
    );
  }

  String get lectureSessionName => 'Lecture Session $sessionNumber';

  bool get isScheduled => status == LectureSessionStatus.scheduled;

  bool get isActive => status == LectureSessionStatus.active;

  bool get isCompleted => status == LectureSessionStatus.completed;
}
