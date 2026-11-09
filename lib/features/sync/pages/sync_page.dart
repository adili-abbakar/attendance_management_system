import 'dart:convert';

import 'package:attendance_management_system/features/sync/providers/sync_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SyncPage extends StatefulWidget {
  const SyncPage({super.key});

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  bool _showGenerateCode = true;
  final TextEditingController _manualCodeController = TextEditingController();
  late final MobileScannerController _scannerController;
  late final ValueNotifier<int> _countdownNotifier;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController();
    _countdownNotifier = ValueNotifier<int>(300);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SyncProvider>().initialize();
      _startCountdown();
    });
  }

  void _startCountdown() {
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      final current = _countdownNotifier.value;
      if (current <= 0) {
        return;
      }
      _countdownNotifier.value = current - 1;
      _startCountdown();
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _manualCodeController.dispose();
    _countdownNotifier.dispose();
    super.dispose();
  }

  String _formatCountdown(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    final minutesLabel = minutes.toString().padLeft(2, '0');
    final secondsLabel = remainingSeconds.toString().padLeft(2, '0');
    return '$minutesLabel:$secondsLabel';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SyncProvider>();
    final payload = provider.activeSession?.toPayload();
    final code = provider.activeSession?.code ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Synchronization')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment<bool>(
                            value: true,
                            label: Text('Generate Sync Code'),
                          ),
                          ButtonSegment<bool>(
                            value: false,
                            label: Text('Scan Sync Code'),
                          ),
                        ],
                        selected: {_showGenerateCode},
                        onSelectionChanged: (selection) {
                          setState(() {
                            _showGenerateCode = selection.first;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      if (_showGenerateCode) ...[
                        _buildGenerateCodeSection(
                          context,
                          provider,
                          payload,
                          code,
                        ),
                      ] else ...[
                        _buildScanCodeSection(context, provider),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGenerateCodeSection(
    BuildContext context,
    SyncProvider provider,
    dynamic payload,
    String code,
  ) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (provider.activeSession != null && payload != null) ...[
                  Center(
                    child: QrImageView(
                      data: jsonEncode(payload.toJson()),
                      version: QrVersions.auto,
                      size: 220,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pairing Code',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    code,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<int>(
                    valueListenable: _countdownNotifier,
                    builder: (context, value, _) {
                      return Text(
                        'Expires in ${_formatCountdown(value)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.icon(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.maybeOf(context);
                          await Clipboard.setData(ClipboardData(text: code));
                          if (!mounted) return;
                          messenger?.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Pairing code copied to clipboard.',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_all_rounded),
                        label: const Text('Copy code'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          provider.cancelSession();
                        },
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Cancel'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    provider.isConnected
                        ? 'Connected to another device.'
                        : 'Waiting for another device…',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Generate a secure pairing code for a new device.',
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () async {
                      await provider.generatePairingSession();
                    },
                    icon: const Icon(Icons.qr_code_2_rounded),
                    label: const Text('Generate Sync Code'),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (provider.isConnected) ...[
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connected Device',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Device ID: ${provider.remotePayload?.deviceId ?? 'n/a'}',
                  ),
                  Text('Group ID: ${provider.remotePayload?.groupId ?? 'n/a'}'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: provider.isSynchronizing
                        ? null
                        : () async {
                            await provider.synchronizeNow();
                          },
                    icon: const Icon(Icons.sync_rounded),
                    label: const Text('Synchronize Now'),
                  ),
                  if (provider.summary.status != 'ready') ...[
                    const SizedBox(height: 16),
                    Text(
                      'Compared: ${provider.summary.totalRecordsCompared} • Sent: ${provider.summary.recordsSent} • Received: ${provider.summary.recordsReceived} • Updated: ${provider.summary.recordsUpdated}',
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildScanCodeSection(BuildContext context, SyncProvider provider) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  height: 260,
                  child: MobileScanner(
                    controller: _scannerController,
                    onDetect: (capture) {
                      if (capture.barcodes.isEmpty) {
                        return;
                      }
                      final value = capture.barcodes.first.rawValue;
                      if (value == null || value.isEmpty) {
                        return;
                      }
                      context.read<SyncProvider>().connectWithPayload(value);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Scan a QR code from a paired device.'),
                const SizedBox(height: 12),
                TextField(
                  controller: _manualCodeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    hintText: 'Enter pairing code manually',
                    prefixIcon: Icon(Icons.keyboard),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () async {
                    final code = _manualCodeController.text.trim();
                    if (code.isEmpty) {
                      return;
                    }
                    await provider.establishConnectionFromCode(code);
                  },
                  icon: const Icon(Icons.link_rounded),
                  label: const Text('Validate Pairing Code'),
                ),
              ],
            ),
          ),
        ),
        if (provider.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            provider.errorMessage!,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ],
    );
  }
}
