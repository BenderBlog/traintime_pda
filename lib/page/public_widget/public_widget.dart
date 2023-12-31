// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Useful weights to simplify watermeter programming.

import 'package:flutter/material.dart';

/// Check the width
bool isPhone(context) => MediaQuery.of(context).size.width > 480;
bool isDesktop(context) => MediaQuery.of(context).size.width > 840;
const double sheetMaxWidth = 600;

/// Use it to show the small items.
class TagsBoxes extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;

  const TagsBoxes({
    Key? key,
    required this.text,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.all(Radius.circular(9)),
      ),
      child: Text(
        text,
        textScaleFactor: MediaQuery.of(context).textScaleFactor * 0.9,
        style: TextStyle(
          color: textColor ??
              (Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Colors.black),
        ),
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
