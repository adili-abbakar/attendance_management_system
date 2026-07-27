import 'package:flutter/material.dart';

class CourseGrid extends StatelessWidget {
  const CourseGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    late final int columns;
    late final double ratio;

    if (width >= 1200) {
      // Desktop
      columns = 4;
      ratio = .95;
    } else if (width >= 900) {
      // Large Tablet / Laptop
      columns = 3;
      ratio = .90;
    } else if (width >= 600) {
      // Tablet
      columns = 2;
      ratio = .88;
    } else {
      // Phone
      columns = 1;
      ratio = 0.85;
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
