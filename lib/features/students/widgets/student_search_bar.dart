import 'package:flutter/material.dart';

class StudentSearchBar extends StatelessWidget {
  const StudentSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onAddStudent,
    required this.onImportStudents,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onAddStudent;
  final VoidCallback onImportStudents;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final searchField = TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search students...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    final importButton = OutlinedButton.icon(
      onPressed: onImportStudents,
      icon: const Icon(Icons.upload_file),
      label: const Text('Import'),
    );

    final addButton = FilledButton.icon(
      onPressed: onAddStudent,
      icon: const Icon(Icons.person_add_alt_1),
      label: const Text('Add Student'),
    );

    // ==========================
    // Phone
    // ==========================
    if (width < 600) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          searchField,
          const SizedBox(height: 12),

          SizedBox(width: double.infinity, child: importButton),

          const SizedBox(height: 12),

          SizedBox(width: double.infinity, child: addButton),
        ],
      );
    }

    // ==========================
    // Tablet
    // ==========================
    if (width < 900) {
      return Column(
        children: [
          searchField,
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(child: importButton),
              const SizedBox(width: 12),
              Expanded(child: addButton),
            ],
          ),
        ],
      );
    }

    // ==========================
    // Desktop
    // ==========================
    return Row(
      children: [
        Expanded(child: searchField),

        const SizedBox(width: 16),

        importButton,

        const SizedBox(width: 12),

        addButton,
      ],
    );
  }
}
