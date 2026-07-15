import 'package:attendance_management_system/data/database/tables/user_table.dart';
import 'package:attendance_management_system/data/results/auth/register_result.dart';
import 'package:attendance_management_system/data/results/auth/update_result.dart';
import 'package:bcrypt/bcrypt.dart';
import '../database/database_service.dart';
import '../models/auth/user.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final DatabaseService _databaseService = DatabaseService.instance;

  Future<RegisterResult> register(User user) async {
    final db = await _databaseService.database;

    String? emailError;
    String? staffIdError;

    final emailResult = await db.query(
      UserTable.tableName,
      where: '${UserTable.email} = ?',
      whereArgs: [user.email],
    );

    if (emailResult.isNotEmpty) {
      emailError = 'Email already exists.';
    }

    final staffResult = await db.query(
      UserTable.tableName,
      where: '${UserTable.staffId} = ?',
      whereArgs: [user.staffId],
    );

    if (staffResult.isNotEmpty) {
      staffIdError = 'Staff ID already exists.';
    }

    if (emailError != null || staffIdError != null) {
      return RegisterResult(
        success: false,
        emailError: emailError,
        staffIdError: staffIdError,
      );
    }

    final hashedPassword = BCrypt.hashpw(user.password, BCrypt.gensalt());
    final newUser = user.copyWith(password: hashedPassword);

    final userId = await db.insert(UserTable.tableName, newUser.toMap());

    return RegisterResult(success: true, userId: userId);
  }

  Future<User?> login({required String email, required String password}) async {
    // TODO
    return null;
  }

  Future<void> logout() async {
    // TODO
  }

  Future<List<User>> getUsers() async {
    final db = await _databaseService.database;

    final result = await db.query(
      UserTable.tableName,
      orderBy: '${UserTable.id} DESC',
    );

    return result.map((e) => User.fromMap(e)).toList();
  }

  Future<bool> emailExists(String email) async {
    // TODO
    return false;
  }

  Future<bool> deleteUser(int id) async {
    final db = await _databaseService.database;

    final rows = await db.delete(
      UserTable.tableName,
      where: '${UserTable.id} = ?',
      whereArgs: [id],
    );

    return rows > 0;
  }

  Future<UpdateResult> updateUser(User user) async {
    final db = await _databaseService.database;

    String? emailError;
    String? staffIdError;

    final emailResult = await db.query(
      UserTable.tableName,
      where: '${UserTable.email} = ? AND ${UserTable.id} != ?',
      whereArgs: [user.email, user.id],
    );

    if (emailResult.isNotEmpty) {
      emailError = "Email already exist";
    }

    final staffResult = await db.query(
      UserTable.tableName,
      where: '${UserTable.staffId} = ? AND ${UserTable.id} != ?',
      whereArgs: [user.staffId, user.id],
    );

    if (staffResult.isNotEmpty) {
      staffIdError = 'Staff ID already exists.';
    }

    if (emailError != null || staffIdError != null) {
      return UpdateResult(
        success: false,
        emailError: emailError,
        staffIdError: staffIdError,
      );
    }

    String password = user.password;
    if (!password.startsWith(r'$2')) {
      password = BCrypt.hashpw(password, BCrypt.gensalt());
    }
    final existingUser = user.copyWith(password: password);

    await db.update(
      UserTable.tableName,
      existingUser.toMap(),
      where: '${UserTable.id} = ?',
      whereArgs: [user.id],
    );

    return const UpdateResult(success: true);
  }
}
