import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as mobile_scanner;
import 'package:qr_code_dart_decoder/qr_code_dart_decoder.dart' as qr_decoder;

import 'package:attendance_management_system/core/responsive/app_responsive.dart';

import 'package:camera/camera.dart';
import 'package:camera_desktop/camera_desktop.dart';

class AttendanceScannerPage extends StatefulWidget {
  const AttendanceScannerPage({super.key, required this.lectureSessionId});

  final int lectureSessionId;

  @override
  State<AttendanceScannerPage> createState() => _AttendanceScannerPageState();
}

class _AttendanceScannerPageState extends State<AttendanceScannerPage> {
  // ---------------------------------------------------------------------------
  // MOBILE SCANNER
  // Android / iOS
  // ---------------------------------------------------------------------------

  final mobile_scanner.MobileScannerController _mobileScannerController =
      mobile_scanner.MobileScannerController();

  // ---------------------------------------------------------------------------
  // DESKTOP CAMERA
  // Windows / Linux
  // ---------------------------------------------------------------------------

  CameraController? _desktopCameraController;

  bool _desktopCameraReady = false;
  bool _desktopProcessing = false;

  // Prevent multiple scans from being processed simultaneously.
  bool _hasScanned = false;

  // Prevent multiple camera initialization attempts.
  bool _initializingDesktopCamera = false;

  @override
  void initState() {
    super.initState();

    if (_isDesktopPlatform) {
      _initializeDesktopCamera();
    }
  }

  bool get _isDesktopPlatform => Platform.isWindows || Platform.isLinux;

  // ---------------------------------------------------------------------------
  // DESKTOP CAMERA INITIALIZATION
  // ---------------------------------------------------------------------------

  Future<void> _initializeDesktopCamera() async {
    if (_initializingDesktopCamera) {
      return;
    }

    _initializingDesktopCamera = true;

    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _desktopCameraReady = false;
          });
        }

        return;
      }

      final camera = cameras.first;

      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      _desktopCameraController = controller;

      setState(() {
        _desktopCameraReady = true;
      });
    } catch (e) {
      debugPrint('Desktop camera initialization failed: $e');

      if (mounted) {
        setState(() {
          _desktopCameraReady = false;
        });
      }
    } finally {
      _initializingDesktopCamera = false;
    }
  }

  // ---------------------------------------------------------------------------
  // MOBILE QR DETECTION
  // ---------------------------------------------------------------------------

  void _onMobileDetect(mobile_scanner.BarcodeCapture capture) {
    if (_hasScanned) {
      return;
    }

    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim();

      if (value == null || value.isEmpty) {
        continue;
      }

      _returnScannedValue(value);
      return;
    }
  }

  // ---------------------------------------------------------------------------
  // DESKTOP QR DETECTION
  // ---------------------------------------------------------------------------

  Future<void> _scanDesktopFrame() async {
    if (_hasScanned ||
        _desktopProcessing ||
        !_desktopCameraReady ||
        _desktopCameraController == null) {
      return;
    }

    final controller = _desktopCameraController!;

    if (!controller.value.isInitialized) {
      return;
    }

    _desktopProcessing = true;

    try {
      final image = await controller.takePicture();

      final decoded = await _decodeDesktopImage(image);

      if (decoded != null && decoded.trim().isNotEmpty) {
        _returnScannedValue(decoded.trim());
      }
    } catch (e) {
      debugPrint('Desktop QR scan failed: $e');
    } finally {
      _desktopProcessing = false;
    }
  }

  // ---------------------------------------------------------------------------
  // DESKTOP QR DECODER
  // ---------------------------------------------------------------------------

Future<String?> _decodeDesktopImage(XFile image) async {
    try {
      final decoder = qr_decoder.QrCodeDartDecoder();

      final imageBytes = await image.readAsBytes();

      final result = await decoder.decodeFile(imageBytes);

      return result?.text;
    } catch (e) {
      debugPrint('QR decoder error: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // RETURN RESULT
  // ---------------------------------------------------------------------------

  void _returnScannedValue(String value) {
    if (_hasScanned) {
      return;
    }

    _hasScanned = true;

    if (_isDesktopPlatform) {
      _desktopCameraController?.stopImageStream();
    } else {
      _mobileScannerController.stop();
    }

    Navigator.pop(context, value);
  }

  // ---------------------------------------------------------------------------
  // MOBILE TORCH
  // ---------------------------------------------------------------------------

  void _toggleTorch() {
    if (_isDesktopPlatform) {
      return;
    }

    _mobileScannerController.toggleTorch();
  }

  // ---------------------------------------------------------------------------
  // MOBILE CAMERA SWITCH
  // ---------------------------------------------------------------------------

  void _switchCamera() {
    if (_isDesktopPlatform) {
      return;
    }

    _mobileScannerController.switchCamera();
  }

  // ---------------------------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _mobileScannerController.dispose();
    _desktopCameraController?.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scan Student QR',
          style: TextStyle(fontSize: r.titleLarge),
        ),
        actions: [
          if (!_isDesktopPlatform)
            IconButton(
              onPressed: _toggleTorch,
              icon: const Icon(Icons.flash_on),
              tooltip: 'Toggle flashlight',
            ),

          if (!_isDesktopPlatform)
            IconButton(
              onPressed: _switchCamera,
              icon: const Icon(Icons.cameraswitch),
              tooltip: 'Switch camera',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isDesktopPlatform
                ? _buildDesktopScanner(context, r)
                : _buildMobileScanner(context, r),
          ),

          Padding(
            padding: EdgeInsets.all(r.pagePadding),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close),
                label: const Text('Cancel'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MOBILE SCANNER UI
  // ---------------------------------------------------------------------------

  Widget _buildMobileScanner(BuildContext context, AppResponsive r) {
    return Stack(
      alignment: Alignment.center,
      children: [
        mobile_scanner.MobileScanner(
          controller: _mobileScannerController,
          onDetect: _onMobileDetect,
          scanWindow: const Rect.fromLTWH(0, 0, 300, 300),
        ),

        _buildScannerFrame(context),

        Positioned(
          bottom: r.spacingL,
          left: r.pagePadding,
          right: r.pagePadding,
          child: _buildScannerInstruction(context, r),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // DESKTOP SCANNER UI
  // ---------------------------------------------------------------------------

  Widget _buildDesktopScanner(BuildContext context, AppResponsive r) {
    if (!_desktopCameraReady) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera_alt_outlined, size: 56),

            SizedBox(height: r.spacingM),

            Text(
              'Camera is not available.',
              style: TextStyle(
                fontSize: r.titleMedium,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: r.spacingS),

            Text(
              'Make sure a camera is connected and accessible.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: r.body,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),

            SizedBox(height: r.spacingM),

            FilledButton.icon(
              onPressed: _initializeDesktopCamera,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final controller = _desktopCameraController!;

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(child: CameraPreview(controller)),

        _buildScannerFrame(context),

        Positioned(
          bottom: r.spacingL,
          left: r.pagePadding,
          right: r.pagePadding,
          child: Column(
            children: [
              _buildScannerInstruction(context, r),

              SizedBox(height: r.spacingM),

              FilledButton.icon(
                onPressed: _desktopProcessing ? null : _scanDesktopFrame,
                icon: _desktopProcessing
                    ? SizedBox(
                        width: r.iconSmall,
                        height: r.iconSmall,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.qr_code_scanner),
                label: Text(
                  _desktopProcessing ? 'Scanning...' : 'Scan QR Code',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SCANNER FRAME
  // ---------------------------------------------------------------------------

  Widget _buildScannerFrame(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INSTRUCTION
  // ---------------------------------------------------------------------------

  Widget _buildScannerInstruction(BuildContext context, AppResponsive r) {
    return Container(
      padding: EdgeInsets.all(r.cardPadding),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Position the student QR code inside the frame.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: r.body),
      ),
    );
  }
}
