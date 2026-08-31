
import 'package:attendance_management_system/features/scanner/widgets/scanner_frame_painter.dart';
import 'package:flutter/material.dart';

class ScannerGuide extends StatelessWidget {
  const ScannerGuide({
    super.key,
    required this.animation,
  });

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Center(
      child: SizedBox(
        width: 280,
        height: 280,
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: ScannerFramePainter(
                    color: primary,
                    strokeWidth: 4,
                    cornerLength: 38,
                  ),
                ),
              ),
            ),

            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    final position = animation.value;

                    return Align(
                      alignment: Alignment(
                        0,
                        -1 + (position * 2),
                      ),
                      child: Container(
                        height: 3,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(
                                alpha: 0.7,
                              ),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

