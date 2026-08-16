import 'package:flutter/foundation.dart';

import 'package:attendance_management_system/features/attendance/lecture_session/models/lecture_session.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/services/lecture_session_service.dart';

class LectureSessionProvider extends ChangeNotifier {
  final LectureSessionService _lectureSessionService;

  LectureSessionProvider({LectureSessionService? lectureSessionService})
    : _lectureSessionService =
          lectureSessionService ?? LectureSessionService.instance;

  bool _isLoading = false;
  String? _errorMessage;

  int? _selectedCourseId;
  LectureSession? _selectedLectureSession;

  List<LectureSession> _lectureSessions = [];

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  int? get selectedCourseId => _selectedCourseId;

  LectureSession? get selectedLectureSession => _selectedLectureSession;

  List<LectureSession> get lectureSessions =>
      List.unmodifiable(_lectureSessions);

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void selectCourse(int courseId) {
    _selectedCourseId = courseId;
    _selectedLectureSession = null;
    _lectureSessions = [];
    _clearError();

    notifyListeners();
  }

  void clearSelection() {
    _selectedCourseId = null;
    _selectedLectureSession = null;
    _lectureSessions = [];
    _clearError();

    notifyListeners();
  }

  Future<bool> loadLectureSessions(int courseId) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedCourseId = courseId;

      _lectureSessions = await _lectureSessionService
          .getLectureSessionsByCourse(courseId);

      return true;
    } catch (e) {
      _setError('Failed to load lecture sessions.');

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<LectureSession?> loadLectureSession(int lectureSessionId) async {
    _setLoading(true);
    _clearError();

    try {
      final lectureSession = await _lectureSessionService.getLectureSessionById(
        lectureSessionId,
      );

      _selectedLectureSession = lectureSession;

      return lectureSession;
    } catch (e) {
      _setError('Failed to load lecture session.');

      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createLectureSession(LectureSession lectureSession) async {
    _setLoading(true);
    _clearError();

    try {
      await _lectureSessionService.createLectureSession(lectureSession);

      await loadLectureSessions(lectureSession.courseId);

      return true;
    } catch (e) {
      _setError('Failed to create lecture session.');

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateLectureSession(LectureSession lectureSession) async {
    _setLoading(true);
    _clearError();

    try {
      await _lectureSessionService.updateLectureSession(lectureSession);

      _selectedLectureSession = await _lectureSessionService
          .getLectureSessionById(lectureSession.id!);

      await loadLectureSessions(lectureSession.courseId);

      return true;
    } catch (e) {
      _setError('Failed to update lecture session.');

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteLectureSession(LectureSession lectureSession) async {
    _setLoading(true);
    _clearError();

    try {
      await _lectureSessionService.deleteLectureSession(lectureSession.id!);

      if (_selectedLectureSession?.id == lectureSession.id) {
        _selectedLectureSession = null;
      }

      await loadLectureSessions(lectureSession.courseId);

      return true;
    } catch (e) {
      _setError('Failed to delete lecture session.');

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> startLectureSession(LectureSession lectureSession) async {
    _setLoading(true);
    _clearError();

    try {
      await _lectureSessionService.startLectureSession(lectureSession.id!);

      _selectedLectureSession = await _lectureSessionService
          .getLectureSessionById(lectureSession.id!);

      await loadLectureSessions(lectureSession.courseId);

      return true;
    } catch (e) {
      _setError(
        e is StateError ? e.message : 'Failed to start lecture session.',
      );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> completeLectureSession(LectureSession lectureSession) async {
    _setLoading(true);
    _clearError();

    try {
      await _lectureSessionService.completeLectureSession(lectureSession.id!);

      _selectedLectureSession = await _lectureSessionService
          .getLectureSessionById(lectureSession.id!);

      await loadLectureSessions(lectureSession.courseId);

      return true;
    } catch (e) {
      _setError(
        e is StateError ? e.message : 'Failed to complete lecture session.',
      );

      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}
