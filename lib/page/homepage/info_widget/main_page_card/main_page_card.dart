import 'package:flutter/material.dart';

class MainPageCard extends StatelessWidget {
  final bool isLong;
  final List<Widget> children;
  final IconData icon;
  final String text;
  final double? height;
  const MainPageCard({
    super.key,
    required this.isLong,
    this.height,
    required this.icon,
    required this.text,
    required this.children,
  }) : assert(
          (!isLong) || (isLong && height != null),
          "If you want to use a long main page card, "
          "a height must be told in order to use AspectRatio,"
          "to avoid no bound exception.",
        );

  @override
  Widget build(BuildContext context) {
    Widget card = Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    textBaseline: TextBaseline.alphabetic,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            ...children,
          ],
        ),
      ),
    );

    return Container(
      padding: isLong
          ? EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.025)
          : null,
      child: height != null
          ? AspectRatio(
              aspectRatio: MediaQuery.of(context).size.width / height!,
              child: card,
            )
          : card,
    );
  }
}
