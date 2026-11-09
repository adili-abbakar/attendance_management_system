import 'dart:math';

import 'package:attendance_management_system/data/database/database_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class DeviceIdentityService {
  DeviceIdentityService._();

  static final DeviceIdentityService instance = DeviceIdentityService._();

  static const String _deviceIdKey = 'attendance_sync_device_id';
  static const String _groupIdKey = 'attendance_sync_group_id';
  static const String _syncSettingsTable = 'sync_settings';

  Future<String> getOrCreateDeviceId() async {
    final deviceId = await _getValue(_deviceIdKey);
    if (deviceId != null && deviceId.isNotEmpty) {
      return deviceId;
    }

    final value = const Uuid().v4();
    await _saveValue(_deviceIdKey, value);
    return value;
  }

  Future<String> getOrCreateGroupId() async {
    final groupId = await _getValue(_groupIdKey);
    if (groupId != null && groupId.isNotEmpty) {
      return groupId;
    }

    final value = const Uuid().v4();
    await _saveValue(_groupIdKey, value);
    return value;
  }

  Future<String> getDeviceLabel() async {
    final deviceId = await getOrCreateDeviceId();
    final shortId = deviceId.substring(0, 8);
    final random = Random();
    final suffix = (random.nextInt(9000) + 1000).toString();
    return 'Device $shortId-$suffix';
  }

  Future<String?> _getValue(String key) async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query(
      _syncSettingsTable,
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    final value = rows.first['value'];
    return value?.toString();
  }

  Future<void> _saveValue(String key, String value) async {
    final db = await DatabaseService.instance.database;
    await db.insert(
      _syncSettingsTable,
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
