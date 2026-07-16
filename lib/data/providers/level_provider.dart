import 'package:flutter/material.dart';

import '../models/level.dart';
import '../services/level_service.dart';

class LevelProvider extends ChangeNotifier {
  final LevelService _service;

  LevelProvider(this._service);

  List<Level> _levels = [];

  bool _isLoading = false;

  String? _error;

  List<Level> get levels => _levels;

  bool get isLoading => _isLoading;

  String? get error => _error;
  String? _levelNameError;
  String? get levelNameError => _levelNameError;

  Future<void> loadLevels() async {
    _setLoading(true);

    try {
      _levels = await _service.getLevels();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _setLoading(false);
  }

  Future<bool> createLevel(Level level) async {
    _error = null;
    _levelNameError = null;

    notifyListeners();

    try {
      final result = await _service.createLevel(
        _normalizeLevel(level.copyWith(createdAt: DateTime.now())),
      );

      if (!result.success) {
        _levelNameError = result.levelNameError;

        notifyListeners();

        return false;
      }

      await loadLevels();

      return true;
    } catch (e) {
      _error = e.toString();

      notifyListeners();

      return false;
    }
  }

  Future<bool> updateLevel(Level level) async {
    _error = null;
    _levelNameError = null;

    notifyListeners();

    try {
      final result = await _service.updateLevel(_normalizeLevel(level));

      if (!result.success) {
        _levelNameError = result.levelNameError;

        notifyListeners();

        return false;
      }

      await loadLevels();

      return true;
    } catch (e) {
      _error = e.toString();

      notifyListeners();

      return false;
    }
  }

  Future<bool> deleteLevel(int id) async {
    try {
      await _service.deleteLevel(id);

      _levels.removeWhere((level) => level.id == id);

      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();

      return false;
    }
  }

  Level? getLevelById(int id) {
    try {
      return _levels.firstWhere((level) => level.id == id);
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

  void clearlevelNameError() {
    _levelNameError = null;
    notifyListeners();
  }

  Level _normalizeLevel(Level level) {
    return level.copyWith(
      name: level.name.trim().toUpperCase(),
      updatedAt: DateTime.now(),
    );
  }
}
