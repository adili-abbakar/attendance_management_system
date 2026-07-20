import 'package:flutter/material.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.child});

  final Widget child;

  static const double _phoneBreakpoint = 600;
  static const double _desktopBreakpoint = 1024;
  static const double _maxFormWidth = 450;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            // ==========================
            // Responsive Values
            // ==========================

            final bool isPhone = width < _phoneBreakpoint;
            final bool isTablet =
                width >= _phoneBreakpoint && width < _desktopBreakpoint;

            final double horizontalPadding = isPhone
                ? 24
                : isTablet
                ? 40
                : 64;

            final double verticalPadding = isPhone
                ? 24
                : isTablet
                ? 32
                : 48;

            final double iconSize = isPhone
                ? 80
                : isTablet
                ? 100
                : 150;

            // final double titleSize = isPhone
            //     ? 32
            //     : isTablet
            //     ? 40
            //     : 48;

            // ==========================
            // Phone & Tablet
            // ==========================

            if (width < _desktopBreakpoint) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        height -
                        (verticalPadding * 2), // Enables vertical centering
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _maxFormWidth,
                      ),
                      child: child,
                    ),
                  ),
                ),
              );
            }

            // ==========================
            // Desktop
            // ==========================

            return Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    color: colors.primaryContainer,
                    padding: const EdgeInsets.all(64),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon(
                            //   Icons.fact_check_rounded,
                            //   size: iconSize,
                            //   color: colors.primary,
                            // ),

                            // const SizedBox(height: 32),

                            // Text(
                            //   'Attendance\nManagement System',
                            //   textAlign: TextAlign.center,
                            //   style: text.displaySmall?.copyWith(
                            //     fontSize: titleSize,
                            //     fontWeight: FontWeight.bold,
                            //     color: colors.onPrimaryContainer,
                            //   ),
                            // ),

                            // const SizedBox(height: 20),

                            // Text(
                            //   'Fast • Secure • Reliable',
                            //   textAlign: TextAlign.center,
                            //   style: text.titleMedium?.copyWith(
                            //     color: colors.onPrimaryContainer.withValues(
                            //       alpha: .85,
                            //     ),
                            //   ),
                            // ),

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
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  flex: 4,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(64),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: _maxFormWidth,
                        ),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
