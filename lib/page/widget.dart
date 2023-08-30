// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Useful weights to simplify watermeter programming.

import 'package:flutter/material.dart';
import 'package:watermeter/page/sliver_grid_deligate_with_fixed_height.dart';

/// Check the width
bool isPhone(context) => MediaQuery.of(context).size.width < 480;
bool isDesktop(context) => MediaQuery.of(context).size.width > 840;
const double sheetMaxWidth = 600;

/// Something related to the box.
const double widthOfSquare = 30.0;
const double roundRadius = 10;

/// Use it to show the small items.
class TagsBoxes extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const TagsBoxes({
    Key? key,
    required this.text,
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(9)),
      ),
      child: Text(
        text,
        textScaleFactor: 0.9,
        style: TextStyle(color: textColor),
      ),
    );
  }
}

/// A listview widget. First is the type, second is the list...
Widget dataList<T, W extends Widget>(List<T> a, W Function(T toUse) init,
        {ScrollPhysics? physics}) =>
    ListView.separated(
      physics: physics,
      itemCount: a.length,
      itemBuilder: (context, index) {
        return init(a[index]);
      },
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 3),
      padding: const EdgeInsets.symmetric(
        horizontal: 12.5,
        vertical: 9.0,
      ),
    );

/// A grid with fixHeight
Widget fixHeightGrid({
  required double height,
  required double maxCrossAxisExtent,
  required List<Widget> children,
}) =>
    GridView(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedHeight(
        height: height,
        maxCrossAxisExtent: maxCrossAxisExtent,
      ),
      children: children,
    );

/// Colors for the class information card.
const colorList = [
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.lightBlue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.yellow,
  Colors.orange,
  Colors.deepOrange,
  Colors.brown,
];

/// App Color patten.
/// Copied from https://github.com/flutter/samples/blob/main/material_3_demo/lib/constants.dart

enum ColorSeed {
  blue('天空蓝', Colors.blue),
  indigo('贵族蓝', Colors.indigo),
  deepPurple('基佬紫', Colors.deepPurple),
  green('早苗绿', Colors.green),
  orange('果粒橙', Colors.orange),
  pink('少女粉', Colors.pink);

  const ColorSeed(this.label, this.color);
  final String label;
  final Color color;
}

/// Colors for class information card which not in this week.
const uselessColor = Colors.grey;

Widget informationWithIcon(IconData icon, String text, context) => Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(text),
        ),
      ],
    );

/// Switch page with animation.
Route createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

/// Used with a card inside a card.
class InfoDetailBox extends StatelessWidget {
  final Widget child;
  const InfoDetailBox({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: child,
      ),
    );
  }
}

/// A reload widget/page
class ReloadWidget extends StatelessWidget {
  final void Function() function;
  const ReloadWidget({super.key, required this.function});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Ouch! 发生错误啦",
            style: TextStyle(fontSize: 16),
          ),
          FilledButton(
            onPressed: function,
            child: const Text("点我刷新"),
          ),
        ],
      ),
    );
  }
}
