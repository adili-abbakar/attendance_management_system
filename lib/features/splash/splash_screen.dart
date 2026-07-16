import 'package:attendance_management_system/core/widgets/buttons/primary_button.dart';
import 'package:attendance_management_system/data/providers/auth_provider.dart';
import 'package:attendance_management_system/features/auth/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../dashboard/dashboard_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final auth = context.read<AuthProvider>();

    if (await auth.isLoggedIn()) {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {  
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final shortestSide = size.shortestSide;

            // Responsive sizing
            final iconSize = shortestSide * 0.22;
            final titleSize = shortestSide * 0.085;
            final subtitleSize = shortestSide * 0.045;

            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fact_check_rounded,
                        size: iconSize.clamp(80.0, 140.0),
                        color: colors.primary,
                      ),

                      const SizedBox(height: 32),

                      Text(
                        'Attendance Management',
                        textAlign: TextAlign.center,
                        style: textTheme.headlineMedium?.copyWith(
                          fontSize: titleSize.clamp(28.0, 42.0),
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Smart • Fast • Reliable',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge?.copyWith(
                          fontSize: subtitleSize.clamp(16.0, 20.0),
                          color: colors.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 48),

                      SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          text: 'Continue',
                          icon: Icons.arrow_forward,
                          isIconLeading: false,
                          onPressed: () async {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                            );
                          },
                        ),
                      ),
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
