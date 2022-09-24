/*
Useful weights to simplify watermeter program.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'package:flutter/material.dart';

/// Something related to the box.
const double widthOfSquare = 30.0;
const double roundRadius = 10;

/// Use it as a larger box.
class ShadowBox extends StatelessWidget {
  final Widget child;
  final double padding;
  final Color backgroundColor;

  const ShadowBox({
    Key? key,
    required this.child,
    this.padding = 10.0,
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(roundRadius),
      ),
      child: child,
    );
  }
}

/// Use it to show the small items.
class TagsBoxes extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const TagsBoxes(
      {Key? key,
      required this.text,
      this.backgroundColor = Colors.blue,
      this.textColor = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(9)),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor),
        textScaleFactor: 0.9,
      ),
    );
  }
}

/// Use it at the top of each page.
class TitleLine extends StatelessWidget {
  final Widget child;

  const TitleLine({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            spreadRadius: 0.1,
            color: Colors.black.withOpacity(0.2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: child,
      ),
    );
  }
}

/// An input widget.
Widget inputField({
  required String text,
  required Icon icon,
  required TextEditingController controller,
  bool isPassword = false,
  bool isAutoFocus = false,
}) =>
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: widthOfSquare),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(roundRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: TextField(
            autofocus: isAutoFocus,
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              border: InputBorder.none,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              hintText: text,
            ),
          ),
        ),
      ),
    );
