import 'package:attendance_management_system/core/widgets/auth_button.dart';
import 'package:attendance_management_system/features/testing/test_page.dart';
import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        const AuthButton(),
        IconButton(
          icon: const Icon(Icons.science),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TestPage()),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
