import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 70, color: colors.primary),

            const SizedBox(height: 20),

            Text(title, style: Theme.of(context).textTheme.titleLarge),

            const SizedBox(height: 8),

            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
