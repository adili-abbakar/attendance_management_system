import 'package:flutter/material.dart';

class StatisticsGrid extends StatelessWidget {
  const StatisticsGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    late final int columns;
    late final double ratio;

    if (width >= 1200) {
      // Desktop
      columns = 4;
      ratio = 1.45;
    } else if (width >= 900) {
      // Large Tablet
      columns = 4;
      ratio = 1.30;
    } else if (width >= 600) {
      // Tablet / Fold unfolded
      columns = 3;
      ratio = 1.10;
    } else if (width >= 360) {
      // Most phones
      columns = 2;
      ratio = 1.08;
    } else {
      // Very narrow phones (Galaxy Fold cover, etc.)
      columns = 2;
      ratio = 0.95;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: children.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: ratio,
      ),
      itemBuilder: (_, index) => children[index],
    );
  }
}
