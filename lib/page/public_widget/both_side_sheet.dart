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
  }) => showGeneralDialog<T>(
    barrierDismissible: true,
    context: context,
    barrierColor: Colors.black54,
    useRootNavigator: false,
    pageBuilder: (context, animation1, animation2) {
      return BothSideSheet(title: title, divider: divider, child: child);
    },
    barrierLabel: title,
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final isNarrow = MediaQuery.of(context).size.width < divider;
      final beginOffset = isNarrow
          ? const Offset(0.0, 1.0)
          : const Offset(1.0, 0.0);

      return SlideTransition(
        position: Tween(
          begin: beginOffset,
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation),
        child: child,
      );
    },
  );

  @override
  @override
  State<BothSideSheet> createState() => _BothSideSheetState();
}

class _BothSideSheetState extends State<BothSideSheet>
    with SingleTickerProviderStateMixin {
  double? _initialMobileHeight;

  double? _currentHeight;

  late AnimationController _animationController;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animationController.addListener(() {
      setState(() {
        _currentHeight = _heightAnimation.value;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initialMobileHeight = MediaQuery.of(context).size.height * 0.8;
    _currentHeight ??= _initialMobileHeight;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onDragStart() {
    _animationController.stop();
  }

  void _onDragUpdate(double globalPositionY) {
    setState(() {
      double newHeight = MediaQuery.of(context).size.height - globalPositionY;
      _currentHeight = newHeight.clamp(0.0, _initialMobileHeight!);
    });
  }

  void _onDragEnd(double? primaryVelocity) {
    final screenHeight = MediaQuery.of(context).size.height;
    final dismissThreshold = screenHeight * 0.4;

    final velocity = primaryVelocity ?? 0;
    if (_currentHeight! < dismissThreshold || velocity > 500) {
      Navigator.pop(context);
    } else {
      _heightAnimation =
          Tween<double>(
            begin: _currentHeight,
            end: _initialMobileHeight,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutBack,
            ),
          );
      _animationController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < widget.divider;

    final desktopWidth = (screenWidth * 0.4).clamp(360.0, double.infinity);

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      bottomLeft: !isNarrow ? const Radius.circular(16) : Radius.zero,
      topRight: isNarrow ? const Radius.circular(16) : Radius.zero,
    );

    return Align(
      alignment: isNarrow ? Alignment.bottomCenter : Alignment.centerRight,
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: borderRadius,
        elevation: 8,
        child: Container(
          width: isNarrow ? screenWidth : desktopWidth,
          height: isNarrow ? _currentHeight : double.infinity,
          decoration: BoxDecoration(borderRadius: borderRadius),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: isNarrow
                ? _MobileLayoutBuilder(
                    onDragStart: _onDragStart,
                    onDragUpdate: _onDragUpdate,
                    onDragEnd: _onDragEnd,
                    child: widget.child,
                  )
                : _DesktopLayoutBuilder(
                    title: widget.title,
                    child: widget.child,
                  ),
          ),
        ),
      ),
    );
  }
}

class _MobileDragHandleBuilder extends StatelessWidget {
  final VoidCallback onDragStart;
  final ValueChanged<double> onDragUpdate;
  final ValueChanged<double?> onDragEnd;

  const _MobileDragHandleBuilder({
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: (_) => onDragStart(),
      onVerticalDragUpdate: (details) =>
          onDragUpdate(details.globalPosition.dy),
      onVerticalDragEnd: (details) => onDragEnd(details.primaryVelocity),
      child: SizedBox(
        height: 30,
        width: double.infinity,
        child: Center(
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopToolbarBuilder extends StatelessWidget {
  final String title;

  const _DesktopToolbarBuilder({required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          ),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _MobileLayoutBuilder extends StatelessWidget {
  final VoidCallback onDragStart;
  final ValueChanged<double> onDragUpdate;
  final ValueChanged<double?> onDragEnd;
  final Widget child;

  const _MobileLayoutBuilder({
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MobileDragHandleBuilder(
          onDragStart: onDragStart,
          onDragUpdate: onDragUpdate,
          onDragEnd: onDragEnd,
        ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 16),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

class _DesktopLayoutBuilder extends StatelessWidget {
  final String title;
  final Widget child;

  const _DesktopLayoutBuilder({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      left: false,
      child: Column(
        children: [
          _DesktopToolbarBuilder(title: title),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: true,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 16),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
