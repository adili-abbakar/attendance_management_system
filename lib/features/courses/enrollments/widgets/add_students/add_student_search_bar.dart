import 'package:flutter/material.dart';

class AddStudentSearchBar extends StatelessWidget {
  const AddStudentSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
    this.hintText = 'Search by admission number or student name...',
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,

            prefixIcon: const Icon(Icons.search),

            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear Search',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                      onClear?.call();
                    },
                  ),

            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

            filled: true,
          ),
        );
      },
    );
  }
}
