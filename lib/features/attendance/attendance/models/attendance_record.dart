import 'package:attendance_management_system/features/attendance/attendance/tables/attendance_record_table.dart';

enum AttendanceRecordStatus { present }

class AttendanceRecord {
  final int? id;
  final int lectureSessionId;
  final int studentId;
  final AttendanceRecordStatus status;
  final DateTime scannedAt;

  const AttendanceRecord({
    this.id,
    required this.lectureSessionId,
    required this.studentId,
    required this.status,
    required this.scannedAt,
  });

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map[AttendanceRecordTable.id] as int?,
      lectureSessionId: map[AttendanceRecordTable.lectureSessionId] as int,
      studentId: map[AttendanceRecordTable.studentId] as int,
      status: AttendanceRecordStatus.values.firstWhere(
        (value) => value.name == map[AttendanceRecordTable.status],
        orElse: () => AttendanceRecordStatus.present,
      ),
      scannedAt: DateTime.parse(map[AttendanceRecordTable.scannedAt] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      AttendanceRecordTable.id: id,
      AttendanceRecordTable.lectureSessionId: lectureSessionId,
      AttendanceRecordTable.studentId: studentId,
      AttendanceRecordTable.status: status.name,
      AttendanceRecordTable.scannedAt: scannedAt.toIso8601String(),
    };
  }

  AttendanceRecord copyWith({
    int? id,
    int? lectureSessionId,
    int? studentId,
    AttendanceRecordStatus? status,
    DateTime? scannedAt,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      lectureSessionId: lectureSessionId ?? this.lectureSessionId,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
      scannedAt: scannedAt ?? this.scannedAt,
    );
  }
}
