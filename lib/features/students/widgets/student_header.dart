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
                'Manage students enrolled in the system',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),

        
      ],
    );
  }
}
