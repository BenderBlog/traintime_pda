// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:material_ui/material_ui.dart';

class AnimatedIconButton extends StatefulWidget {
  const AnimatedIconButton({
    super.key,
    required this.onPressed,
    required this.init,
    required this.triggered,
    this.tooltip,
    this.iconSize,
    this.animateDuration = const Duration(milliseconds: 200),
    this.restoreDuration = const Duration(seconds: 2),
  });

  final VoidCallback onPressed;
  final IconData init;
  final IconData triggered;
  final Duration animateDuration;
  final Duration restoreDuration;
  final String? tooltip;
  final double? iconSize;

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton> {
  bool _triggered = false;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleTap() async {
    widget.onPressed();

    _resetTimer?.cancel();
    setState(() => _triggered = true);
    _resetTimer = Timer(widget.restoreDuration, () {
      if (mounted) setState(() => _triggered = false);
    });
  }

  @override
  Widget build(BuildContext context) => IconButton(
    iconSize: widget.iconSize,
    tooltip: widget.tooltip,
    onPressed: _handleTap,
    icon: AnimatedSwitcher(
      duration: widget.animateDuration,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: Icon(
        _triggered ? widget.triggered : widget.init,
        key: ValueKey(_triggered),
      ),
    ),
  );
}
