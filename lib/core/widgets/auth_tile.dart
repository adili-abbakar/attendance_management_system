import 'package:attendance_management_system/data/providers/auth_provider.dart';
import 'package:attendance_management_system/features/auth/login/login_page.dart';
import 'package:attendance_management_system/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthTile extends StatefulWidget {
  const AuthTile({super.key});

  @override
  State<AuthTile> createState() => _AuthTileState();
}

class _AuthTileState extends State<AuthTile> {
  bool? _loggedIn;

  @override
  void initState() {
    super.initState();
    _loadLoginState();
  }

  Future<void> _loadLoginState() async {
    final authProvider = context.read<AuthProvider>();
    final loggedIn = await authProvider.isLoggedIn();

    if (!mounted) return;

    setState(() {
      _loggedIn = loggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loggedIn == null) {
      return const SizedBox.shrink();
    }
    
    return ListTile(
      leading: Icon(
        _loggedIn! ? Icons.logout_rounded : Icons.login_rounded,
        color: _loggedIn! ? Colors.red : Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        _loggedIn! ? "Logout" : "Login",
        style: TextStyle(
          color: _loggedIn!
              ? Colors.red
              : Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () async {
        final navigator = Navigator.of(context);
        final authProvider = context.read<AuthProvider>();

        navigator.pop(); // Close drawer

        if (!_loggedIn!) {
          navigator.push(MaterialPageRoute(builder: (_) => const LoginPage()));
          return;
        }

        final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Logout"),
            content: const Text("Are you sure you want to logout?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Logout"),
              ),
            ],
          ),
        );

        if (shouldLogout != true) return;

        await authProvider.logout();

        if (!mounted) return;

        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SplashScreen()),
          (_) => false,
        );
      },
    );
  }
}
