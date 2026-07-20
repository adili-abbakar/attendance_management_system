import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.fact_check_rounded,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    final shortestSide = size.shortestSide;

    final iconSize = shortestSide * 0.22;
    final titleSize = shortestSide * 0.085;
    final subtitleSize = shortestSide * 0.045;

    return Column(
      children: [
        SizedBox(
          width: iconSize.clamp(75.0, 115.0),
          height: iconSize.clamp(75.0, 115.0),
          child: FittedBox(
            fit: BoxFit.cover,
            child: Image.asset('assets/images/logo.png', color: colors.primary),
          ),
        ),
        const SizedBox(height: 5),
        Text(title, style: text.headlineMedium, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(subtitle, style: text.bodyMedium, textAlign: TextAlign.center),
      ],
    );
  }
}
