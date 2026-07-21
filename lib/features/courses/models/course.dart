class Course {
  final int? id;

  final String code;
  final String title;

  // Foreign Keys
  final int levelId;
  final int academicSessionId;

  // Joined values (nullable because they don't exist when inserting)
  final String? levelName;
  final String? academicSessionName;

  final int semester;
  final bool isActive;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Course({
    this.id,
    required this.code,
    required this.title,
    required this.levelId,
    required this.academicSessionId,
    this.levelName,
    this.academicSessionName,
    required this.semester,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  Course copyWith({
    int? id,
    String? code,
    String? title,
    int? levelId,
    int? academicSessionId,
    String? levelName,
    String? academicSessionName,
    int? semester,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Course(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      levelId: levelId ?? this.levelId,
      academicSessionId: academicSessionId ?? this.academicSessionId,
      levelName: levelName ?? this.levelName,
      academicSessionName: academicSessionName ?? this.academicSessionName,
      semester: semester ?? this.semester,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] as int?,
      code: map['code'] as String,
      title: map['title'] as String,

      levelId: map['level_id'] as int,
      academicSessionId: map['academic_session_id'] as int,

      levelName: map['level_name'] as String?,
      academicSessionName: map['academic_session_name'] as String?,

      semester: map['semester'] as int,

      isActive: (map['is_active'] as int) == 1,

      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'level_id': levelId,
      'academic_session_id': academicSessionId,
      'semester': semester,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Course.empty() {
    final now = DateTime.now();

    return Course(
      code: '',
      title: '',
      levelId: 1,
      academicSessionId: 1,
      levelName: null,
      academicSessionName: null,
      semester: 1,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }
}
