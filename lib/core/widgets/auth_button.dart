import 'package:attendance_management_system/data/providers/auth_provider.dart';
import 'package:attendance_management_system/features/auth/login/login_page.dart';
import 'package:attendance_management_system/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: context.read<AuthProvider>().isLoggedIn(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final loggedIn = snapshot.data!;

        return IconButton(
          tooltip: loggedIn ? 'Logout' : 'Login',
          icon: Icon(loggedIn ? Icons.logout_rounded : Icons.login_rounded),
          onPressed: () async {
            if (loggedIn) {
              await context.read<AuthProvider>().logout();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const SplashScreen()),
                (_) => false,
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            }
          },
        );
      },
    );
  }
}
