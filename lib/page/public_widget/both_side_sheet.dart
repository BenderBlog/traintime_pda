// Copyright 2024 BenderBlog Rodriguez.
// SPDX-License-Identifier: MIT

import 'package:flutter/material.dart';

class BothSideSheet extends StatefulWidget {
  final Widget child;
  final String title;
  final double divider;

  const BothSideSheet({
    super.key,
    required this.child,
    required this.title,
    this.divider = 480.0,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    required String title,
    double divider = 480.0,
  }) =>
      showGeneralDialog<T>(
        barrierDismissible: true,
        context: context,
        useRootNavigator: false,
        pageBuilder: (context, animation1, animation2) {
          return BothSideSheet(
            title: title,
            divider: divider,
            child: child,
          );
        },
        barrierLabel: title,
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween(
              begin: MediaQuery.of(context).size.width < divider
                  ? const Offset(0.0, 1.0)
                  : const Offset(1.0, 0.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation),
            child: child,
          );
        },
      );

  @override
  State<BothSideSheet> createState() => _BothSideSheetState();
}

class _BothSideSheetState extends State<BothSideSheet> {
  /// We only change the height, to simulate showModalBottomSheet
  late double heightForVertical;

  @override
  void didChangeDependencies() {
    heightForVertical = MediaQuery.of(context).size.height * 0.8;
    super.didChangeDependencies();
  }

  BorderRadius radius(context) => BorderRadius.only(
        topLeft: const Radius.circular(16),
        bottomLeft: !(MediaQuery.of(context).size.width < widget.divider)
            ? const Radius.circular(16)
            : Radius.zero,
        topRight: MediaQuery.of(context).size.width < widget.divider
            ? const Radius.circular(16)
            : Radius.zero,
        bottomRight: Radius.zero,
      );

  double get width => MediaQuery.of(context).size.width < widget.divider
      ? MediaQuery.of(context).size.width
      : MediaQuery.of(context).size.width * 0.4 < 360
          ? 360
          : MediaQuery.of(context).size.width * 0.4;

  Widget get onTop => MediaQuery.of(context).size.width < widget.divider
      ? GestureDetector(
          onVerticalDragUpdate: (DragUpdateDetails details) {
            setState(() {
              heightForVertical = MediaQuery.of(context).size.height -
                  details.globalPosition.dy;
              if (heightForVertical <
                  MediaQuery.of(context).size.height * 0.4) {
                Navigator.pop(context);
              }
            });
          },
          child: SizedBox(
            height: 30,
            width: double.infinity,
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Container(
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                ),
                Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.4),
                  ),
                )
              ],
            ),
          ),
        )
      : SizedBox(
          height: kToolbarHeight,
          width: double.infinity,
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
              ),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        );

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: MediaQuery.of(context).size.width < widget.divider
          ? Alignment.bottomCenter
          : Alignment.centerRight,
      child: Container(
        width: width,
        height: MediaQuery.of(context).size.width < widget.divider
            ? heightForVertical
            : double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: radius(context),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal:
                MediaQuery.of(context).size.width < widget.divider ? 15 : 10,
            vertical:
                MediaQuery.of(context).size.width < widget.divider ? 0 : 10,
          ),
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: MediaQuery.of(context).size.width < widget.divider
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(20),
                    child: onTop,
                  )
                : PreferredSize(
                    preferredSize: const Size.fromHeight(kToolbarHeight),
                    child: onTop,
                  ),
            body: widget.child,
          ),
        ),
      ),
    );
  }
}
