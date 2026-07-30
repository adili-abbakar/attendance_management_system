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
    final compact = MediaQuery.sizeOf(context).width < 550;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          Chip(
            avatar: const Icon(Icons.people_outline, size: 18),
            label: Text(
              '$selectedCount student${selectedCount == 1 ? '' : 's'} selected',
            ),
          ),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton(
                onPressed: isLoading ? null : onCancel,
                child: const Text('Cancel'),
              ),

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
                  isLoading
                      ? 'Adding...'
                      : compact
                      ? 'Add'
                      : 'Add Students',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
