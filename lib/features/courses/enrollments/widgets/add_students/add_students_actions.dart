import 'package:flutter/material.dart';

class AddStudentActions extends StatelessWidget {
  const AddStudentActions({
    super.key,
    required this.selectedCount,
    required this.isLoading,
    required this.onCancel,
    required this.onAddStudents,
  });

  final int selectedCount;
  final bool isLoading;

  final VoidCallback onCancel;
  final VoidCallback onAddStudents;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 550;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 12,
        spacing: 12,
        children: [
          Chip(
            avatar: const Icon(Icons.people_outline, size: 18),
            label: Text('$selectedCount selected'),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: isLoading ? null : onCancel,
                child: const Text('Cancel'),
              ),

              const SizedBox(width: 8),

              FilledButton.icon(
                onPressed: isLoading || selectedCount == 0
                    ? null
                    : onAddStudents,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.person_add_alt_1),
                label: Text(
                  compact ? 'Add' : (isLoading ? 'Adding...' : 'Add Students'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
