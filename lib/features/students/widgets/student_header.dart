import 'package:flutter/material.dart';

class StudentHeader extends StatelessWidget {
  const StudentHeader({super.key, required this.onAddStudent});

  final VoidCallback onAddStudent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Students',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage students enrolled in the system',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),

        FilledButton.icon(
          onPressed: onAddStudent,
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Add Student'),
        ),
      ],
    );
  }
}
