import 'package:attendance_management_system/core/responsive/app_responsive.dart';
import 'package:flutter/material.dart';

class LectureSessionsSearchField extends StatelessWidget {
  const LectureSessionsSearchField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onClear,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);

    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search lecture sessions...',
        prefixIcon: Icon(Icons.search, size: r.iconMedium),
        suffixIcon: value.isNotEmpty
            ? IconButton(onPressed: onClear, icon: const Icon(Icons.clear))
            : null,
      ),
    );
  }
}
