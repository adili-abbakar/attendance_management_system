import 'package:attendance_management_system/features/attendance/attendance/tables/attendance_record_table.dart';
import 'package:uuid/uuid.dart';

enum AttendanceRecordStatus { present }

class AttendanceRecord {
  AttendanceRecord({
    this.id,
    this.recordUuid,
    required this.lectureSessionId,
    required this.studentId,
    required this.status,
    DateTime? scannedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : scannedAt = scannedAt ?? DateTime.now().toUtc(),
       createdAt = createdAt ?? scannedAt ?? DateTime.now().toUtc(),
       updatedAt = updatedAt ?? createdAt ?? scannedAt ?? DateTime.now().toUtc();

  final int? id;
  final String? recordUuid;
  final int lectureSessionId;
  final int studentId;
  final AttendanceRecordStatus status;
  final DateTime scannedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map[AttendanceRecordTable.id] as int?,
      recordUuid: map[AttendanceRecordTable.recordUuid] as String?,
      lectureSessionId: map[AttendanceRecordTable.lectureSessionId] as int,
      studentId: map[AttendanceRecordTable.studentId] as int,
      status: AttendanceRecordStatus.values.firstWhere(
        (value) => value.name == map[AttendanceRecordTable.status],
        orElse: () => AttendanceRecordStatus.present,
      ),
      scannedAt: DateTime.parse(map[AttendanceRecordTable.scannedAt] as String).toUtc(),
      createdAt: DateTime.parse((map[AttendanceRecordTable.createdAt] ?? map[AttendanceRecordTable.scannedAt]) as String).toUtc(),
      updatedAt: DateTime.parse((map[AttendanceRecordTable.updatedAt] ?? map[AttendanceRecordTable.scannedAt]) as String).toUtc(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      AttendanceRecordTable.id: id,
      AttendanceRecordTable.recordUuid: recordUuid ?? const Uuid().v4(),
      AttendanceRecordTable.lectureSessionId: lectureSessionId,
      AttendanceRecordTable.studentId: studentId,
      AttendanceRecordTable.status: status.name,
      AttendanceRecordTable.scannedAt: scannedAt.toUtc().toIso8601String(),
      AttendanceRecordTable.createdAt: createdAt.toUtc().toIso8601String(),
      AttendanceRecordTable.updatedAt: updatedAt.toUtc().toIso8601String(),
    };
  }

  AttendanceRecord copyWith({
    int? id,
    String? recordUuid,
    int? lectureSessionId,
    int? studentId,
    AttendanceRecordStatus? status,
    DateTime? scannedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      recordUuid: recordUuid ?? this.recordUuid,
      lectureSessionId: lectureSessionId ?? this.lectureSessionId,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
      scannedAt: scannedAt ?? this.scannedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
