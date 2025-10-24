// Copyright 2025 Hazuki Keatsu and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

/// A prominent alert banner that displays a loading indicator and message.
///
/// This widget creates a horizontal bar with an error container background color
/// to draw user attention. It's typically used to inform users that they're
/// viewing cached data while fresh data is being loaded in the background.
///
/// The banner includes:
/// - A text message (with medium weight font)
/// - A circular progress indicator on the right
/// - Error container color scheme for high visibility
///
/// Example usage:
/// ```dart
/// LoadingAlerter(
///   isLoading: controller.status == Status.fetching,
///   hint: "You are viewing cached data, updating in background...",
/// )
/// ```
///
/// When [isLoading] is false, the widget renders as an empty [SizedBox.shrink].
class LoadingAlerter extends StatefulWidget {
  const LoadingAlerter({
    super.key,
    required this.isLoading,
    required this.hint,
    this.showOverlay = true,
    this.opacity = 0.3,
  });

  /// Whether to display the loading alert banner.
  ///
  /// When false, the widget collapses to an empty [SizedBox.shrink].
  /// When true, displays the full alert banner with loading indicator.
  final bool isLoading;

  /// The message text to display in the alert banner.
  ///
  /// This should briefly explain what's happening, such as:
  /// - "Loading cached data, updating in background..."
  /// - "Fetching latest information..."
  /// - "You are viewing cached data, please wait for refresh..."
  final String hint;

  /// Whether to show a semi-transparent overlay to dim the background.
  ///
  /// When true, displays a dark overlay behind the alert banner to draw
  /// more attention to the loading state. Defaults to true.
  final bool showOverlay;

  /// The opacity of the overlay when [showOverlay] is true.
  ///
  /// Ranges from 0.0 (fully transparent) to 1.0 (fully opaque).
  final double opacity;

  @override
  State<LoadingAlerter> createState() => _LoadingAlerterState();
}

class _LoadingAlerterState extends State<LoadingAlerter>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  bool _shouldShow = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: widget.opacity,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut, 
    ));
    
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        setState(() {
          _shouldShow = false;
        });
      }
    });
    
    if (widget.isLoading) {
      _shouldShow = true;
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(LoadingAlerter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        setState(() {
          _shouldShow = true;
        });
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
    if (widget.opacity != oldWidget.opacity) {
      _opacityAnimation = Tween<double>(
        begin: 0.0,
        end: widget.opacity,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShow) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
  
    final alertBar = Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: SizedBox(
          height: kTextTabBarHeight,
          child: Container(
            decoration: DecoratedBox(decoration: BoxDecoration(
              color: colorScheme.errorContainer,
            )).decoration,
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.hint,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!widget.showOverlay) {
      return alertBar;
    }

    // When showOverlay is true, this widget must be used in a Stack
    // to properly overlay the entire parent area
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _opacityAnimation,
              builder: (context, child) {
                return Container(
                  color: Colors.black.withAlpha((_opacityAnimation.value * 255).toInt()),
                );
              },
            ),
          ),
        ),
        alertBar,
      ],
    );
  }
}
