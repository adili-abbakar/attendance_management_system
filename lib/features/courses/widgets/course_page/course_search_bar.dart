import 'package:flutter/material.dart';

class CourseSearchBar extends StatelessWidget {
  const CourseSearchBar({
    super.key,
    required this.onChanged,
    required this.onAddPressed,
    required this.controller,
  });

  final ValueChanged<String> onChanged;
  final VoidCallback onAddPressed;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final searchField = TextField(
      onChanged: onChanged,
      controller: controller,
      decoration: InputDecoration(
        hintText: "Search courses...",
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

    final addButton = FilledButton.icon(
      onPressed: onAddPressed,
      icon: const Icon(Icons.add),
      label: const Text("Add Course"),
    );

    if (width < 600) {
      return Column(
        children: [
          searchField,
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: addButton),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: searchField),
        const SizedBox(width: 16),
        addButton,
      ],
    );
  }
}
