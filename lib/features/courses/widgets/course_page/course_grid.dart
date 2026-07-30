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
      ratio = 1.08;
    } else if (width >= 900) {
      // Large Tablet / Laptop
      columns = 3;
      ratio = 1.02;
    } else if (width >= 600) {
      // Tablet
      columns = 2;
      ratio = 0.98;
    } else {
      // Phone
      columns = 1;
      ratio = 0.94;
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
