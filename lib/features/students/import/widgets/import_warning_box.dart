import 'package:flutter/material.dart';

class ImportWarningBox extends StatelessWidget {
  const ImportWarningBox({
    super.key,
    required this.title,
    required this.messages,
    required this.color,
    this.showDescription = false,
  });

  final String title;
  final List<String> messages;
  final Color color;
  final bool showDescription;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),

          if (showDescription) ...[
            const SizedBox(height: 10),

            const Text(
              'The following rows will be skipped if you continue:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],

          const SizedBox(height: 10),

          ...messages.map(
            (message) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('⚠ $message', style: TextStyle(color: color)),
            ),
          ),
        ],
      ),
    );
  }
}
