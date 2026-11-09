import 'package:uuid/uuid.dart';

class CourseStudent {
  CourseStudent({
    this.id,
    this.recordUuid,
    required this.courseId,
    required this.studentId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now().toUtc(),
       updatedAt = updatedAt ?? createdAt ?? DateTime.now().toUtc();

  final int? id;
  final String? recordUuid;
  final int courseId;
  final int studentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  CourseStudent copyWith({
    int? id,
    String? recordUuid,
    int? courseId,
    int? studentId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseStudent(
      id: id ?? this.id,
      recordUuid: recordUuid ?? this.recordUuid,
      courseId: courseId ?? this.courseId,
      studentId: studentId ?? this.studentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'record_uuid': recordUuid ?? const Uuid().v4(),
      'course_id': courseId,
      'student_id': studentId,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }

  factory CourseStudent.fromMap(Map<String, dynamic> map) {
    return CourseStudent(
      id: map['id'] as int?,
      recordUuid: map['record_uuid'] as String?,
      courseId: map['course_id'] as int,
      studentId: map['student_id'] as int,
      createdAt: DateTime.parse(map['created_at'] as String).toUtc(),
      updatedAt: DateTime.parse((map['updated_at'] ?? map['created_at']) as String).toUtc(),
    );
  }
}
