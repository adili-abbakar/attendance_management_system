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
      ratio = 1.3;
    } else if (width >= 900) {
      // Large tablet
      columns = 3;
      ratio = 1.1;
    } else if (width >= 600) {
      // Tablet
      columns = 3;
      ratio = 0.95;
    } else if (width >= 300) {
      // Phones
      columns = 2;
      ratio = 0.75;
    } else {
      // Phones
      columns = 1;
      ratio = 0.75;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: children.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: ratio,
      ),
      itemBuilder: (_, index) => children[index],
    );
  }
}
