import 'package:flutter/material.dart';

class LevelGrid extends StatelessWidget {
  const LevelGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    late final int columns;
    late final double ratio;

    if (width >= 1200) {
      columns = 4;
      ratio = 1.9;
    } else if (width >= 900) {
      columns = 3;
      ratio = 1.7;
    } else if (width >= 600) {
      columns = 2;
      ratio = 1.5;
    } else {
      columns = 1;
      ratio = 2.1;
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
