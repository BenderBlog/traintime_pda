import 'package:flutter/material.dart';
import 'package:watermeter/page/classtable/class_page/content_classtable_page.dart';
import 'package:watermeter/page/classtable/class_page/empty_classtable_page.dart';
import 'package:watermeter/page/classtable/classtable_launch_target.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';

class ClassTablePage extends StatefulWidget {
  final ClassTableLaunchTarget? launchTarget;
  const ClassTablePage({super.key, this.launchTarget});

  @override
  State<ClassTablePage> createState() => _ClassTablePageState();
}

class _ClassTablePageState extends State<ClassTablePage> {
  late ClassTableWidgetState classTableState;
  bool _isListening = false;

  void _reload() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isListening) {
      classTableState = ClassTableState.of(context)!.controllers;
      classTableState.addListener(_reload);
      _isListening = true;
    }
  }

  @override
  void dispose() {
    classTableState.removeListener(_reload);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return classTableState.haveClass
        ? ContentClassTablePage(launchTarget: widget.launchTarget)
        : const EmptyClassTablePage();
  }
}
