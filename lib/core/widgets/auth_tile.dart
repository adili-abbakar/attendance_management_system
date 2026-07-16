import 'package:attendance_management_system/data/providers/auth_provider.dart';
import 'package:attendance_management_system/features/auth/login/login_page.dart';
import 'package:attendance_management_system/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthTile extends StatelessWidget {
  const AuthTile({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: context.read<AuthProvider>().isLoggedIn(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final loggedIn = snapshot.data!;

        return ListTile(
          leading: Icon(
            loggedIn ? Icons.logout_rounded : Icons.login_rounded,
            color: loggedIn
                ? Colors.red
                : Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            loggedIn ? 'Logout' : 'Login',
            style: TextStyle(
              color: loggedIn
                  ? Colors.red
                  : Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: () async {
            if (!loggedIn) {
              Navigator.of(context).pop(); // Close drawer

              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const LoginPage()));
              return;
            }

            // Show dialog BEFORE closing the drawer
            final shouldLogout = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );

            if (shouldLogout != true) return;

            await context.read<AuthProvider>().logout();

            if (!context.mounted) return;

            // Close drawer AFTER logout
            Navigator.of(context).pop();

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const SplashScreen()),
              (_) => false,
            );
          },
        );
      },
    );
  }
}
