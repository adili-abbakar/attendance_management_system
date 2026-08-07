import 'package:attendance_management_system/features/dashboard/dashboard_page.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _openDashboard();
  }

  Future<void> _openDashboard() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const DashboardPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final shortestSide = size.shortestSide;
            final iconSize = shortestSide * 0.22;

            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: iconSize.clamp(300.0, 460.0),
                        height: iconSize.clamp(300.0, 460.0),
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: Image.asset(
                            'assets/images/welcome.png',
                            color: colors.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      const CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}