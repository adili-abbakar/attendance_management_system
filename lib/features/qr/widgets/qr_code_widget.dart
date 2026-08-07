import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeWidget extends StatelessWidget {
  const QrCodeWidget({
    super.key,
    required this.data,
    this.size = 180,
    this.padding = const EdgeInsets.all(8),
    this.backgroundColor = Colors.white,
  });

  final String data;
  final double size;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        size: size,
        backgroundColor: backgroundColor,
        gapless: true,
        errorCorrectionLevel: QrErrorCorrectLevel.M,
      ),
    );
  }
}
