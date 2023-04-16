import 'package:flutter/material.dart';

class FilterMapItem extends StatelessWidget {
  final String title;
  final Widget child;
  const FilterMapItem({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 17),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          title,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 5),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child:
                Padding(padding: const EdgeInsets.only(left: 10), child: child))
      ])
    ]);
  }
}
