import 'package:flutter/foundation.dart';

import 'package:attendance_management_system/features/attendance/lecture_session/models/models.dart';
import 'package:attendance_management_system/features/attendance/lecture_session/services/lecture_session_service.dart';
import 'package:attendance_management_system/features/students/models/student.dart';

class LectureSessionProvider extends ChangeNotifier {
  final LectureSessionService _lectureSessionService;

  LectureSessionProvider(
    LectureSessionService instance, {
    LectureSessionService? lectureSessionService,
  }) : _lectureSessionService =
           lectureSessionService ?? LectureSessionService.instance;

  static final ValueNotifier<int> statisticsChanged = ValueNotifier<int>(0);

  bool _isLoading = false;
  String? _errorMessage;

  int? _selectedCourseId;
  LectureSession? _selectedLectureSession;

  List<LectureSession> _lectureSessions = [];

  double? _averageAttendance;

  List<LectureSession> _todayLectureSessions = [];

  LectureSessionAttendanceStats? _selectedSessionAttendanceStats;

  List<Student> _presentStudents = [];
  List<Student> _absentStudents = [];

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  int? get selectedCourseId => _selectedCourseId;

  LectureSession? get selectedLectureSession => _selectedLectureSession;

  List<LectureSession> get lectureSessions =>
      List.unmodifiable(_lectureSessions);

  double? get averageAttendance => _averageAttendance;

  LectureSessionAttendanceStats? get selectedSessionAttendanceStats =>
      _selectedSessionAttendanceStats;

  List<LectureSession> get todayLectureSessions =>
      List.unmodifiable(_todayLectureSessions);

  List<Student> get presentStudents => List.unmodifiable(_presentStudents);

  List<Student> get absentStudents => List.unmodifiable(_absentStudents);

  void _notifyStatisticsChanged() {
    statisticsChanged.value++;
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }

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

  void _replaceSessionInList(LectureSession updatedSession) {
    final index = _lectureSessions.indexWhere(
      (session) => session.id == updatedSession.id,
    );

    if (index != -1) {
      final updated = [..._lectureSessions];
      updated[index] = updatedSession;
      _lectureSessions = updated;
    }
  }

  void _replaceSessionInTodayList(LectureSession updatedSession) {
    final index = _todayLectureSessions.indexWhere(
      (session) => session.id == updatedSession.id,
    );

    if (index != -1) {
      final updated = [..._todayLectureSessions];
      updated[index] = updatedSession;
      _todayLectureSessions = updated;
    }
  }

  void _removeSessionFromLists(int sessionId) {
    _lectureSessions = _lectureSessions
        .where((session) => session.id != sessionId)
        .toList();

    _todayLectureSessions = _todayLectureSessions
        .where((session) => session.id != sessionId)
        .toList();
  }

  Future<bool> loadTodayLectureSessions() async {
    _clearError();

    try {
      _todayLectureSessions = await _lectureSessionService
          .getTodayLectureSessions();

      return true;
    } catch (e) {
      _todayLectureSessions = [];
      _errorMessage = e.toString();

      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<void> getAverageAttendance() async {
    try {
      _averageAttendance = await _lectureSessionService
          .calculateAverageAttendance();
    } catch (e) {
      _averageAttendance = 0.0;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<void> refreshDashboardData() async {
    await Future.wait([loadTodayLectureSessions(), getAverageAttendance()]);
  }

  void selectCourse(int courseId) {
    _selectedCourseId = courseId;
    _selectedLectureSession = null;
    _selectedSessionAttendanceStats = null;

    _lectureSessions = [];

    _presentStudents = [];
    _absentStudents = [];

    _clearError();

    notifyListeners();
  }

  void clearSelection() {
    _selectedCourseId = null;
    _selectedLectureSession = null;
    _selectedSessionAttendanceStats = null;

    _lectureSessions = [];

    _presentStudents = [];
    _absentStudents = [];

    _clearError();

    notifyListeners();
  }

  Future<bool> loadLectureSessionsByCourse(int courseId) async {
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

  Future<bool> loadLectureSessions() async {
    _setLoading(true);
    _clearError();

    try {
      _lectureSessions = await _lectureSessionService.getLectureSessions();

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

      if (lectureSession == null) {
        _selectedLectureSession = null;
        _selectedSessionAttendanceStats = null;

        _presentStudents = [];
        _absentStudents = [];

        _setError('Lecture session not found.');

        return null;
      }

      _selectedLectureSession = lectureSession;

      _selectedSessionAttendanceStats = await _lectureSessionService
          .getLectureSessionAttendanceStats(lectureSessionId);

      final students = await Future.wait([
        _lectureSessionService.getPresentStudents(lectureSessionId),
        _lectureSessionService.getAbsentStudents(lectureSessionId),
      ]);

      _presentStudents = students[0];
      _absentStudents = students[1];

      _replaceSessionInList(lectureSession);
      _replaceSessionInTodayList(lectureSession);

      return lectureSession;
    } catch (e) {
      _selectedLectureSession = null;
      _selectedSessionAttendanceStats = null;

      _presentStudents = [];
      _absentStudents = [];

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

      await loadLectureSessionsByCourse(lectureSession.courseId);

      await refreshDashboardData();

      _notifyStatisticsChanged();

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

      final updatedSession = await _lectureSessionService.getLectureSessionById(
        lectureSession.id!,
      );

      if (updatedSession != null) {
        _selectedLectureSession = updatedSession;

        _replaceSessionInList(updatedSession);
        _replaceSessionInTodayList(updatedSession);

        _selectedSessionAttendanceStats = await _lectureSessionService
            .getLectureSessionAttendanceStats(updatedSession.id!);

        final students = await Future.wait([
          _lectureSessionService.getPresentStudents(updatedSession.id!),
          _lectureSessionService.getAbsentStudents(updatedSession.id!),
        ]);

        _presentStudents = students[0];
        _absentStudents = students[1];
      }

      await loadLectureSessionsByCourse(lectureSession.courseId);

      await refreshDashboardData();

      _notifyStatisticsChanged();

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
        _selectedSessionAttendanceStats = null;

        _presentStudents = [];
        _absentStudents = [];
      }

      _removeSessionFromLists(lectureSession.id!);

      await refreshDashboardData();

      _notifyStatisticsChanged();

      notifyListeners();

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

      final updatedSession = await _lectureSessionService.getLectureSessionById(
        lectureSession.id!,
      );

      if (updatedSession == null) {
        _setError('Lecture session could not be loaded after starting.');

        return false;
      }

      _selectedLectureSession = updatedSession;

      _replaceSessionInList(updatedSession);
      _replaceSessionInTodayList(updatedSession);

      _selectedSessionAttendanceStats = await _lectureSessionService
          .getLectureSessionAttendanceStats(updatedSession.id!);

      _notifyStatisticsChanged();

      notifyListeners();

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

      final updatedSession = await _lectureSessionService.getLectureSessionById(
        lectureSession.id!,
      );

      if (updatedSession == null) {
        _setError('Lecture session could not be loaded after completion.');

        return false;
      }

      _selectedLectureSession = updatedSession;

      _replaceSessionInList(updatedSession);
      _replaceSessionInTodayList(updatedSession);

      _selectedSessionAttendanceStats = await _lectureSessionService
          .getLectureSessionAttendanceStats(updatedSession.id!);

      _notifyStatisticsChanged();

      notifyListeners();

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

  Future<bool> loadSessionStudents(int lectureSessionId) async {
    try {
      final students = await Future.wait([
        _lectureSessionService.getPresentStudents(lectureSessionId),
        _lectureSessionService.getAbsentStudents(lectureSessionId),
      ]);

      _presentStudents = students[0];
      _absentStudents = students[1];

      notifyListeners();

      return true;
    } catch (e) {
      _presentStudents = [];
      _absentStudents = [];

      _setError('Failed to load session students.');

      return false;
    }
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}
