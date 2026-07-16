import 'package:flutter/material.dart';

import '../models/course.dart';
import '../services/course_service.dart';

class CourseProvider extends ChangeNotifier {
  final CourseService _service;

  CourseProvider(this._service);

  List<Course> _courses = [];

  bool _isLoading = false;

  String? _error;

  List<Course> get courses => _courses;

  bool get isLoading => _isLoading;

  String? get error => _error;

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
    try {
      await _service.createCourse(course);

      await loadCourses();

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCourse(Course course) async {
    try {
      await _service.updateCourse(course);

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
      await _service.deleteCourse(id);

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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
