import 'package:uuid/uuid.dart';

class Student {
  final int? id;
  final String? recordUuid;

  final String admissionNumber;
  final String fullName;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Student({
    this.id,
    this.recordUuid,
    required this.admissionNumber,
    required this.fullName,
    required this.createdAt,
    required this.updatedAt,
  });

  Student copyWith({
    int? id,
    String? recordUuid,
    String? admissionNumber,
    String? fullName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Student(
      id: id ?? this.id,
      recordUuid: recordUuid ?? this.recordUuid,
      admissionNumber: admissionNumber ?? this.admissionNumber,
      fullName: fullName ?? this.fullName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as int?,
      recordUuid: map['record_uuid'] as String?,
      admissionNumber: map['admission_number'] as String,
      fullName: map['full_name'] as String,
      createdAt: DateTime.parse(map['created_at'] as String).toUtc(),
      updatedAt: DateTime.parse(map['updated_at'] as String).toUtc(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'record_uuid': recordUuid ?? const Uuid().v4(),
      'admission_number': admissionNumber,
      'full_name': fullName,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }

  factory Student.empty() {
    final now = DateTime.now().toUtc();

    return Student(
      admissionNumber: '',
      fullName: '',
      createdAt: now,
      updatedAt: now,
    );
  }
}
