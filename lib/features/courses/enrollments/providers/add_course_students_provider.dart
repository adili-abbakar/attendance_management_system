import 'package:attendance_management_system/features/courses/enrollments/models/course_student.dart';
import 'package:attendance_management_system/features/courses/enrollments/services/course_enrollment_service.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:attendance_management_system/features/students/results/student_result.dart';
import 'package:attendance_management_system/features/students/services/student_service.dart';
import 'package:flutter/material.dart';

class AddCourseStudentsProvider extends ChangeNotifier {
  AddCourseStudentsProvider({
    required this.courseId,
    required StudentService studentService,
  }) : _studentService = studentService;

  final int courseId;

  final StudentService _studentService;

  bool _isLoading = false;
  String? _error;

  List<Student> _students = [];
  List<Student> _filteredStudents = [];

  final Set<int> _selectedStudentIds = {};

  String _searchQuery = '';
  bool _showActiveOnly = true;
  bool _sortAscending = true;

  int _currentPage = 1;

  static const int _pageSize = 20;

  bool get isLoading => _isLoading;

  String? get error => _error;

  List<Student> get students => _students;

  List<Student> get filteredStudents => _filteredStudents;

  List<Student> get paginatedStudents {
    final start = (_currentPage - 1) * _pageSize;

    if (start >= _filteredStudents.length) {
      return [];
    }

    final end = (start + _pageSize).clamp(0, _filteredStudents.length);

    return _filteredStudents.sublist(start, end);
  }

  int get currentPage => _currentPage;

  int get totalPages =>
      (_filteredStudents.length / _pageSize).ceil().clamp(1, 999999);

  bool get showActiveOnly => _showActiveOnly;

  bool get sortAscending => _sortAscending;

  Set<int> get selectedStudents => _selectedStudentIds;
  int get selectedCount => _selectedStudentIds.length;

  Future<void> loadStudents() async {
    _isLoading = true;
    notifyListeners();

    try {
      final allStudents = await _studentService.getStudents();

      final enrolled = await CourseEnrollmentService.instance
          .getStudentsForCourse(courseId);

      final enrolledIds = enrolled.map((e) => e.id).toSet();

      _students = allStudents
          .where((e) => !enrolledIds.contains(e.id))
          .toList();

      _error = null;

      _applyFilters(notify: false);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void search(String value) {
    _searchQuery = value;
    _applyFilters();
  }

  void setShowActiveOnly(bool value) {
    _showActiveOnly = value;
    _applyFilters();
  }

  void setSortAscending(bool value) {
    _sortAscending = value;
    _applyFilters();
  }

  void previousPage() {
    if (_currentPage == 1) return;

    _currentPage--;
    notifyListeners();
  }

  void nextPage() {
    if (_currentPage >= totalPages) return;

    _currentPage++;
    notifyListeners();
  }

  void toggleStudentSelection(Student student) {
    if (_selectedStudentIds.contains(student.id)) {
      _selectedStudentIds.remove(student.id);
    } else {
      _selectedStudentIds.add(student.id!);
    }

    notifyListeners();
  }

  void clearSelection() {
    _selectedStudentIds.clear();
    notifyListeners();
  }

  Future<void> addSelectedStudents() async {
    if (_selectedStudentIds.isEmpty) return;

    final now = DateTime.now();

    final enrollments = _selectedStudentIds
        .map(
          (id) =>
              CourseStudent(courseId: courseId, studentId: id, createdAt: now),
        )
        .toList();

    await CourseEnrollmentService.instance.enrollStudents(enrollments);

    await loadStudents();

    clearSelection();
  }

  void _applyFilters({bool notify = true}) {
    var results = List<Student>.from(_students);

    if (_showActiveOnly) {
      results = results.where((e) => e.isActive).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();

      results = results.where((student) {
        return student.fullName.toLowerCase().contains(query) ||
            student.admissionNumber.toLowerCase().contains(query);
      }).toList();
    }

    results.sort((a, b) {
      final comparison = a.fullName.compareTo(b.fullName);

      return _sortAscending ? comparison : -comparison;
    });

    _filteredStudents = results;

    _currentPage = 1;

    if (notify) {
      notifyListeners();
    }
  }

  Future<StudentResult> createAndEnrollStudent(Student student) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await StudentService.instance.createStudent(student);

      if (!result.success || result.student == null) {
        return result;
      }

      final enrollment = CourseStudent(
        courseId: courseId,
        studentId: result.student!.id!,
        createdAt: DateTime.now(),
      );

      await CourseEnrollmentService.instance.enrollStudent(enrollment);

      await loadStudents();

      return result;
    } catch (e) {
      return StudentResult(success: false, admissionNumberError: e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
