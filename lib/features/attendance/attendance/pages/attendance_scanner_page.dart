import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:attendance_management_system/core/responsive/app_responsive.dart';

class AttendanceScannerPage extends StatefulWidget {
  const AttendanceScannerPage({super.key, required this.lectureSessionId});

  final int lectureSessionId;

  @override
  State<AttendanceScannerPage> createState() => _AttendanceScannerPageState();
}

class _AttendanceScannerPageState extends State<AttendanceScannerPage> {
  final MobileScannerController _scannerController = MobileScannerController();

  bool _hasScanned = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) {
      return;
    }

    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim();

      if (value == null || value.isEmpty) {
        continue;
      }

      _hasScanned = true;
      _scannerController.stop();

      Navigator.pop(context, value);
      return;
    }
  }

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
          IconButton(
            onPressed: () {
              _scannerController.toggleTorch();
            },
            icon: const Icon(Icons.flash_on),
            tooltip: 'Toggle flashlight',
          ),
          IconButton(
            onPressed: () {
              _scannerController.switchCamera();
            },
            icon: const Icon(Icons.cameraswitch),
            tooltip: 'Switch camera',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                MobileScanner(
                  controller: _scannerController,
                  onDetect: _onDetect,
                ),

                IgnorePointer(
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
                ),

                Positioned(
                  bottom: r.spacingL,
                  left: r.pagePadding,
                  right: r.pagePadding,
                  child: Container(
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
                  ),
                ),
              ],
            ),
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
}
