// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR MIT

// Useful weights to simplify watermeter programming.

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';

/// Check the width
bool isPhone(context) => MediaQuery.of(context).size.width < 480;
bool isDesktop(context) => MediaQuery.of(context).size.width > 840;
const double sheetMaxWidth = 480;

/// Use it to show the small items.
class TagsBoxes extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;

  const TagsBoxes({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.all(Radius.circular(9)),
      ),
      child: Text(
        text,
        textScaler: const TextScaler.linear(0.9),
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
class DataList<T> extends StatelessWidget {
  final List<T> list;
  final Widget Function(T toUse) initFormula;
  final ScrollPhysics? physics;
  const DataList({
    super.key,
    required this.list,
    required this.initFormula,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: physics,
      itemCount: list.length,
      itemBuilder: (context, index) {
        return initFormula(list[index]);
      },
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 4),
      padding: const EdgeInsets.symmetric(
        horizontal: 12.5,
        vertical: 9.0,
      ),
    ).safeArea();
  }
}

class InformationWithIcon extends StatelessWidget {
  final IconData icon;
  final String text;
  const InformationWithIcon({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(text),
        ),
      ],
    );
  }
}

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
  const InfoDetailBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
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
  // Stands for Exception...
  final Object? errorStatus;
  final String? buttonName;
  const ReloadWidget({
    super.key,
    required this.function,
    this.buttonName,
    this.errorStatus,
  });

  @override
  Widget build(BuildContext context) {
    return [
      Text(
        "${FlutterI18n.translate(context, "error_detected")}\n"
        "${errorStatus != null ? errorStatus.toString() : ""}",
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
      FilledButton(
        onPressed: function,
        child: Text(buttonName ??
            FlutterI18n.translate(
              context,
              "click_to_refresh",
            )),
      ),
    ]
        .toColumn(mainAxisAlignment: MainAxisAlignment.center)
        .center()
        .padding(horizontal: 20)
        .constrained(maxWidth: 600);
  }
}
