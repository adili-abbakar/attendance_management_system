import 'package:attendance_management_system/features/courses/enrollments/services/course_enrollment_service.dart';
import 'package:attendance_management_system/features/courses/models/course.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:flutter/material.dart';

class CourseDetailsProvider extends ChangeNotifier {
  CourseDetailsProvider(this.course);

  final Course course;

  bool _isLoading = false;
  String? _error;

  List<Student> _students = [];
  List<Student> _filteredStudents = [];

  String _searchQuery = '';
  bool _showActiveOnly = false;
  bool _sortAscending = true;

  int _currentPage = 1;
  static const int _pageSize = 20;

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Student> get students => _students;

  List<Student> get filteredStudents => _filteredStudents;

  String get searchQuery => _searchQuery;

  bool get showActiveOnly => _showActiveOnly;

  bool get sortAscending => _sortAscending;

  int get currentPage => _currentPage;

  int get pageSize => _pageSize;

  Future<void> loadStudents() async {
    _isLoading = true;
    notifyListeners();

    try {
      _students = await CourseEnrollmentService.instance.getStudentsForCourse(
        course.id!,
      );

      _error = null;

      _applyFilters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int get totalPages {
    if (_filteredStudents.isEmpty) return 1;

    return (_filteredStudents.length / _pageSize).ceil();
  }

  List<Student> get paginatedStudents {
    final start = (_currentPage - 1) * _pageSize;

    if (start >= _filteredStudents.length) {
      return [];
    }

    var end = start + _pageSize;

    if (end > _filteredStudents.length) {
      end = _filteredStudents.length;
    }

    return _filteredStudents.sublist(start, end);
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
    if (_currentPage <= 1) return;

    _currentPage--;

    notifyListeners();
  }

  void nextPage() {
    if (_currentPage >= totalPages) return;

    _currentPage++;

    notifyListeners();
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

  Future<void> refresh() async {
    await loadStudents();
  }

  Future<bool> removeStudent(Student student) async {
    try {
      final success = await CourseEnrollmentService.instance
          .removeStudentFromCourse(
            courseId: course.id!,
            studentId: student.id!,
          );

      if (!success) return false;

      _students.removeWhere((s) => s.id == student.id);

      _applyFilters();

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
