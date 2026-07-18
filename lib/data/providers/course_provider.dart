import 'package:flutter/material.dart';

import '../models/course.dart';
import '../services/course_service.dart';

class CourseProvider extends ChangeNotifier {
  final CourseService _service;
  
  CourseProvider(this._service);
  List<Course> _courses = [];
  bool _isLoading = false;
  String? _error;
  String? _courseCodeError;

  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get courseCodeError => _courseCodeError;

  Future<void> loadCourses() async {
    _setLoading(true);

    try {
      _courses = await _service.getCourses();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _setLoading(false);
  }

  Future<bool> createCourse(Course course) async {
    _error = null;
    _courseCodeError = null;

    notifyListeners();

    try {
      final result = await _service.createCourse(
        _normalizeCourse(course.copyWith(createdAt: DateTime.now())),
      );

      if (!result.success) {
        _courseCodeError = result.courseCodeError;

        notifyListeners();

        return false;
      }

      await loadCourses();

      return true;
    } catch (e) {
      _error = e.toString();

      notifyListeners();

      return false;
    }
  }

  Future<bool> updateCourse(Course course) async {
    _error = null;
    _courseCodeError = null;

    notifyListeners();

    try {
      final result = await _service.updateCourse(_normalizeCourse(course));

      if (!result.success) {
        _courseCodeError = result.courseCodeError;

        notifyListeners();

        return false;
      }

      await loadCourses();

      return true;
    } catch (e) {
      _error = e.toString();

      notifyListeners();

      return false;
    }
  }

  Future<bool> deleteCourse(int id) async {
    try {
      final success = await _service.deleteCourse(id);

      if (!success) {
        return false;
      }

      _courses.removeWhere((course) => course.id == id);

      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();

      notifyListeners();

      return false;
    }
  }

  Course? getCourseById(int id) {
    try {
      return _courses.firstWhere((course) => course.id == id);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearCourseCodeError() {
    _courseCodeError = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Course _normalizeCourse(Course course) {
    return course.copyWith(
      code: course.code.trim().toUpperCase(),
      title: course.title.trim(),
      levelId: course.levelId,
      academicSessionId: course.academicSessionId,
      updatedAt: DateTime.now(),
    );
  }
}
