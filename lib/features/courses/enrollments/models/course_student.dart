class CourseStudent {
  const CourseStudent({
    this.id,
    required this.courseId,
    required this.studentId,
    required this.createdAt,
  });

  final int? id;
  final int courseId;
  final int studentId;
  final DateTime createdAt;

  CourseStudent copyWith({
    int? id,
    int? courseId,
    int? studentId,
    DateTime? createdAt,
  }) {
    return CourseStudent(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      studentId: studentId ?? this.studentId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_id': courseId,
      'student_id': studentId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CourseStudent.fromMap(Map<String, dynamic> map) {
    return CourseStudent(
      id: map['id'] as int?,
      courseId: map['course_id'] as int,
      studentId: map['student_id'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
