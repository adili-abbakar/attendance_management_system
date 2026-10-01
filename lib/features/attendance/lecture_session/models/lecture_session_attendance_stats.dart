class LectureSessionAttendanceStats {
  const LectureSessionAttendanceStats({
    required this.presentCount,
    required this.totalStudents,
  });

  final int presentCount;
  final int totalStudents;

  double get attendancePercentage {
    if (totalStudents == 0) {
      return 0;
    }

    return (presentCount / totalStudents) * 100;
  }
}