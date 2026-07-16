import 'package:flutter/material.dart';

class LevelSearchBar extends StatelessWidget {
  const LevelSearchBar({
    super.key,
    required this.onChanged,
    required this.onAddPressed,
  });

  final ValueChanged<String> onChanged;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final searchField = TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: "Search levels...",
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    final addButton = FilledButton.icon(
      onPressed: onAddPressed,
      icon: const Icon(Icons.add),
      label: const Text("Add Level"),
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
