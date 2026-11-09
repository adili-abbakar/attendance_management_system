import 'dart:convert';

import 'package:attendance_management_system/features/sync/models/sync_models.dart';
import 'package:attendance_management_system/features/sync/services/device_identity_service.dart';
import 'package:attendance_management_system/features/sync/services/pairing_service.dart';
import 'package:attendance_management_system/features/sync/services/sync_engine_service.dart';
import 'package:attendance_management_system/features/sync/services/sync_manifest_service.dart';
import 'package:flutter/foundation.dart';

class SyncProvider extends ChangeNotifier {
  SyncProvider({
    required DeviceIdentityService deviceIdentityService,
    required PairingService pairingService,
    required SyncManifestService manifestService,
    required SyncEngineService syncEngineService,
  })  : _deviceIdentityService = deviceIdentityService,
        _pairingService = pairingService,
        _manifestService = manifestService,
        _syncEngineService = syncEngineService;

  final DeviceIdentityService _deviceIdentityService;
  final PairingService _pairingService;
  final SyncManifestService _manifestService;
  final SyncEngineService _syncEngineService;

  bool _isGenerating = false;
  bool _isSynchronizing = false;
  bool _isConnected = false;
  String? _deviceId;
  String? _groupId;
  PairingSession? _activeSession;
  PairingPayload? _remotePayload;
  SyncSummary _summary = const SyncSummary();
  String? _errorMessage;

  bool get isGenerating => _isGenerating;
  bool get isSynchronizing => _isSynchronizing;
  bool get isConnected => _isConnected;
  String? get deviceId => _deviceId;
  String? get groupId => _groupId;
  PairingSession? get activeSession => _activeSession;
  PairingPayload? get remotePayload => _remotePayload;
  SyncSummary get summary => _summary;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    _deviceId = await _deviceIdentityService.getOrCreateDeviceId();
    _groupId = await _deviceIdentityService.getOrCreateGroupId();
    notifyListeners();
  }

  Future<void> generatePairingSession() async {
    _isGenerating = true;
    _errorMessage = null;
    notifyListeners();

    final deviceId = _deviceId ?? await _deviceIdentityService.getOrCreateDeviceId();
    final groupId = _groupId ?? await _deviceIdentityService.getOrCreateGroupId();
    _activeSession = _pairingService.createSession(
      deviceId: deviceId,
      groupId: groupId,
    );
    _isGenerating = false;
    notifyListeners();
  }

  void cancelSession() {
    _activeSession = null;
    _isConnected = false;
    notifyListeners();
  }

  Future<void> connectWithPayload(String payloadJson) async {
    final parsed = jsonDecode(payloadJson) as Map<String, dynamic>;
    final payload = PairingPayload.fromJson(parsed);
    final validation = _pairingService.validateCode(payload.code);

    if (validation == null || validation.groupId != payload.groupId) {
      _errorMessage = 'The pairing code is invalid or expired.';
      notifyListeners();
      return;
    }

    _pairingService.consumeCode(payload.code);
    _remotePayload = payload;
    _isConnected = true;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> establishConnectionFromCode(String rawCode) async {
    final session = _pairingService.validateCode(rawCode);
    if (session == null) {
      _errorMessage = 'Invalid or expired pairing code.';
      notifyListeners();
      return;
    }

    _remotePayload = session.toPayload();
    _isConnected = true;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> synchronizeNow() async {
    _isSynchronizing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final localManifest = await _manifestService.buildManifest();
      final remoteManifest = <SyncManifestEntry>[];

      final summary = _syncEngineService.reconcileManifests(
        localManifest: localManifest,
        remoteManifest: remoteManifest,
      );
      _summary = summary.copyWith(status: 'synchronized');
    } catch (error) {
      _errorMessage = 'Synchronization failed: ${error.toString()}';
      _summary = _summary.copyWith(status: 'error');
    } finally {
      _isSynchronizing = false;
      notifyListeners();
    }
  }
}
