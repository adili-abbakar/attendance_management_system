class Course {
  final int? id;
  final String code;
  final String title;
  final String level;
  final int semester;
  final String academicSession;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Course({
    this.id,
    required this.code,
    required this.title,
    required this.level,
    required this.semester,
    required this.academicSession,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  Course copyWith({
    int? id,
    String? code,
    String? title,
    String? level,
    int? semester,
    String? academicSession,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Course(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      level: level ?? this.level,
      semester: semester ?? this.semester,
      academicSession: academicSession ?? this.academicSession,
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
      level: map['level'] as String,
      semester: map['semester'] as int,
      academicSession: map['academic_session'] as String,
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
      'level': level,
      'semester': semester,
      'academic_session': academicSession,
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
      level: '100',
      semester: 1,
      academicSession: '',
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }
}
