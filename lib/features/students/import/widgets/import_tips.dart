import 'package:attendance_management_system/features/students/import/widgets/tip_item.dart';
import 'package:flutter/material.dart';

class ImportTips extends StatelessWidget {
  const ImportTips({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tips', style: Theme.of(context).textTheme.titleMedium),

        const SizedBox(height: 12),

        const TipItem(text: 'Download the template before editing.'),

        const TipItem(text: 'Do not modify the column names.'),

        const TipItem(text: 'Duplicate admission numbers will be skipped.'),

        const TipItem(text: 'Only .xlsx and .csv files are supported.'),
      ],
    );
  }
}
