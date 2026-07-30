import 'package:flutter/material.dart';

class AcademicSessionGrid extends StatelessWidget {
  const AcademicSessionGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    late final int columns;
    late final double ratio;

    if (width >= 1200) {
      // Desktop
      columns = 4;
      ratio = 2.1;
    } else if (width >= 900) {
      // Large tablet
      columns = 3;
      ratio = 1.9;
    } else if (width >= 600) {
      // Tablet
      columns = 2;
      ratio = 1.7;
    } else {
      // Phones
      columns = 1;
      ratio = 2.35;
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
