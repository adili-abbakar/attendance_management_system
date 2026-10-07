import 'package:flutter/material.dart';

class EmptyReportView extends StatelessWidget {
  const EmptyReportView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              Icons.assessment_outlined,
              size: 48,
            ),
            SizedBox(height: 12),
            Text(
              'Generate a report to view attendance statistics.',
            ),
          ],
        ),
      ),
    );
  }
}

