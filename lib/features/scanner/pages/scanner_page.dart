import 'dart:async';
import 'dart:io';

import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:attendance_management_system/features/scanner/widgets/widgets.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as mobile_scanner;
import 'package:qr_code_dart_decoder/qr_code_dart_decoder.dart' as qr_decoder;

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key, this.title = 'Scan Student QR'});

  final String title;

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage>
    with SingleTickerProviderStateMixin {
  // ---------------------------------------------------------------------------
  // MOBILE
  // ---------------------------------------------------------------------------

  final mobile_scanner.MobileScannerController _mobileScannerController =
      mobile_scanner.MobileScannerController();

  // ---------------------------------------------------------------------------
  // DESKTOP
  // ---------------------------------------------------------------------------

  CameraController? _desktopCameraController;

  Timer? _desktopScanTimer;

  bool _desktopCameraReady = false;
  bool _desktopProcessing = false;
  bool _initializingDesktopCamera = false;

  // ---------------------------------------------------------------------------
  // SCAN STATE
  // ---------------------------------------------------------------------------

  bool _hasScanned = false;

  // ---------------------------------------------------------------------------
  // ANIMATION
  // ---------------------------------------------------------------------------

  late final AnimationController _scanAnimationController;

  // ---------------------------------------------------------------------------
  // PLATFORM
  // ---------------------------------------------------------------------------

  bool get _isDesktopPlatform => Platform.isWindows || Platform.isLinux;

  // ---------------------------------------------------------------------------
  // INIT
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    if (_isDesktopPlatform) {
      _initializeDesktopCamera();
    }
  }

  // ---------------------------------------------------------------------------
  // DESKTOP CAMERA INITIALIZATION
  // ---------------------------------------------------------------------------

  Future<void> _initializeDesktopCamera() async {
    if (_initializingDesktopCamera || _hasScanned) {
      return;
    }

    _initializingDesktopCamera = true;

    _desktopScanTimer?.cancel();
    _desktopScanTimer = null;

    if (mounted) {
      setState(() {});
    }

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

      await _desktopCameraController?.dispose();

      _desktopCameraController = controller;

      setState(() {
        _desktopCameraReady = true;
      });

      _startDesktopScanning();
    } catch (e) {
      debugPrint('Desktop camera initialization failed: $e');

      if (mounted) {
        setState(() {
          _desktopCameraReady = false;
        });
      }
    } finally {
      _initializingDesktopCamera = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  // ---------------------------------------------------------------------------
  // DESKTOP CONTINUOUS SCANNING
  // ---------------------------------------------------------------------------

  void _startDesktopScanning() {
    _desktopScanTimer?.cancel();

    _desktopScanTimer = Timer.periodic(const Duration(milliseconds: 700), (_) {
      _scanDesktopFrame();
    });
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
  // DESKTOP FRAME SCANNING
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

      if (!mounted || _hasScanned) {
        return;
      }

      final value = decoded?.trim();

      if (value != null && value.isNotEmpty) {
        _returnScannedValue(value);
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
  // RETURN SCANNED VALUE
  // ---------------------------------------------------------------------------

  void _returnScannedValue(String value) {
    if (_hasScanned || !mounted) {
      return;
    }

    _hasScanned = true;

    _desktopScanTimer?.cancel();
    _desktopScanTimer = null;

    if (!_isDesktopPlatform) {
      _mobileScannerController.stop();
    }

    Navigator.pop(context, value);
  }

  // ---------------------------------------------------------------------------
  // MOBILE TORCH
  // ---------------------------------------------------------------------------

  void _toggleTorch() {
    if (_isDesktopPlatform || _hasScanned) {
      return;
    }

    _mobileScannerController.toggleTorch();
  }

  // ---------------------------------------------------------------------------
  // MOBILE CAMERA SWITCH
  // ---------------------------------------------------------------------------

  void _switchCamera() {
    if (_isDesktopPlatform || _hasScanned) {
      return;
    }

    _mobileScannerController.switchCamera();
  }

  // ---------------------------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _desktopScanTimer?.cancel();
    _desktopScanTimer = null;

    _scanAnimationController.dispose();

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
        title: Text(widget.title, style: TextStyle(fontSize: r.titleLarge)),
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
  // MOBILE UI
  // ---------------------------------------------------------------------------

  Widget _buildMobileScanner(BuildContext context, AppResponsive r) {
    return Stack(
      fit: StackFit.expand,
      children: [
        mobile_scanner.MobileScanner(
          controller: _mobileScannerController,
          onDetect: _onMobileDetect,
        ),

        const ScannerOverlay(),

        ScannerGuide(animation: _scanAnimationController),

        Positioned(
          bottom: r.spacingL,
          left: r.pagePadding,
          right: r.pagePadding,
          child: ScannerInstruction(fontSize: r.body),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // DESKTOP UI
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
              onPressed: _initializingDesktopCamera
                  ? null
                  : _initializeDesktopCamera,
              icon: _initializingDesktopCamera
                  ? SizedBox(
                      width: r.iconSmall,
                      height: r.iconSmall,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              label: Text(
                _initializingDesktopCamera ? 'Initializing...' : 'Retry',
              ),
            ),
          ],
        ),
      );
    }

    final controller = _desktopCameraController!;

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(controller),

        const ScannerOverlay(),

        ScannerGuide(animation: _scanAnimationController),

        Positioned(
          bottom: r.spacingL,
          left: r.pagePadding,
          right: r.pagePadding,
          child: ScannerInstruction(fontSize: r.body),
        ),
      ],
    );
  }
}
