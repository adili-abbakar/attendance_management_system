import 'package:attendance_management_system/data/services/session_service.dart';
import 'package:flutter/material.dart';
import '../models/auth/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _emailError;
  String? _staffIdError;
  User? _currentUser;
  String? _loginError;
  bool get isLoading => _isLoading;
  String? get emailError => _emailError;
  String? get staffIdError => _staffIdError;
  User? get currentUser => _currentUser;
  String? get loginError => _loginError;

  void clearEmailError() {
    _emailError = null;
    notifyListeners();
  }

  void clearStaffIdError() {
    _staffIdError = null;
    notifyListeners();
  }

  void clearLoginError() {
    _loginError = null;
    notifyListeners();
  }

  void resetLoginState() {
    _loginError = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCurrentUser() async {
    final user = await authUser();

    _currentUser = user;

    notifyListeners();
  }

  Future<bool> register(User user) async {
    _isLoading = true;
    _emailError = null;
    _staffIdError = null;

    notifyListeners();

    try {
      final result = await AuthService.instance.register(user);

      _isLoading = false;
      _emailError = result.emailError;
      _staffIdError = result.staffIdError;

      notifyListeners();

      return result.success;
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      rethrow;
    }
  }

  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    _isLoading = true;
    _loginError = null;

    notifyListeners();

    try {
      final user = await AuthService.instance.login(
        identifier: identifier,
        password: password,
      );

      _isLoading = false;

      if (user == null) {
        _loginError = 'Invalid email/staff ID or password.';
        notifyListeners();
        return false;
      }
      await SessionService.instance.saveLogin(user.id!);

      _currentUser = user;

      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    await AuthService.instance.logout();

    _currentUser = null;
    _loginError = null;
    _isLoading = false;

    notifyListeners();

    print('Logged out provide');

  }

  Future<bool> isLoggedIn() async {
    return await SessionService.instance.isLoggedIn();
  }

  Future<User?> authUser() async {
    if (!await isLoggedIn()) return null;
    final id = await SessionService.instance.currentUserId();
    if (id == null) return null;
    return AuthService.instance.getUser(id);
  }
}
