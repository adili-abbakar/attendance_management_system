import 'package:uuid/uuid.dart';

class AcademicSession {
  final int? id;
  final String? recordUuid;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AcademicSession({
    this.id,
    this.recordUuid,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  AcademicSession copyWith({
    int? id,
    String? recordUuid,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AcademicSession(
      id: id ?? this.id,
      recordUuid: recordUuid ?? this.recordUuid,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AcademicSession.fromMap(Map<String, dynamic> map) {
    return AcademicSession(
      id: map['id'] as int?,
      recordUuid: map['record_uuid'] as String?,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['created_at'] as String).toUtc(),
      updatedAt: DateTime.parse(map['updated_at'] as String).toUtc(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'record_uuid': recordUuid ?? const Uuid().v4(),
      'name': name,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }

  factory AcademicSession.empty() {
    final now = DateTime.now().toUtc();

    return AcademicSession(
      name: '',
      createdAt: now,
      updatedAt: now,
    );
  }
}
