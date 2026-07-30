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
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: "Search courses...",
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear, size: 20),
                splashRadius: 18,
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    final addButton = FilledButton.icon(
      onPressed: onAddPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: const Icon(Icons.add, size: 18),
      label: const Text("Add Course"),
    );

    if (width < 600) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [searchField, const SizedBox(height: 10), addButton],
      );
    }

    return Row(
      children: [
        Expanded(child: searchField),
        const SizedBox(width: 10),
        addButton,
      ],
    );
  }
}
