import 'package:flutter/material.dart';

class AcademicSessionSearchBar extends StatelessWidget {
  const AcademicSessionSearchBar({
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
        hintText: "Search sessions...",
        prefixIcon: const Icon(Icons.search, size: 20),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        minimumSize: const Size(0, 44),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: const Icon(Icons.add, size: 18),
      label: const Text("Add Session"),
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
