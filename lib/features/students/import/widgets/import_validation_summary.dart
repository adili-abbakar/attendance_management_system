import 'package:flutter/material.dart';

class ImportValidationSummary extends StatelessWidget {
  const ImportValidationSummary({
    super.key,
    required this.totalRows,
    required this.validRows,
    required this.skippedRows,
  });

  final int totalRows;
  final int validRows;
  final int skippedRows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Validation Summary',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Text('Rows found: $totalRows'),

          Text('Ready to import: $validRows'),

          Text('Will be skipped: $skippedRows'),
        ],
      ),
    );
  }
}
