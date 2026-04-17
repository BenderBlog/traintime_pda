import 'package:flutter/material.dart';
import 'package:watermeter/page/classtable/class_page/content_classtable_page.dart';
import 'package:watermeter/page/classtable/class_page/empty_classtable_page.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';

class ClassTablePage extends StatefulWidget {
  const ClassTablePage({super.key});

  @override
  State<ClassTablePage> createState() => _ClassTablePageState();
}

class _ClassTablePageState extends State<ClassTablePage> {
  late ClassTableWidgetState classTableState;
  ClassTableWidgetState? _attachedClassTableState;

  void _reload() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextClassTableState = ClassTableState.of(context)!.controllers;

    if (_attachedClassTableState != nextClassTableState) {
      _attachedClassTableState?.removeListener(_reload);
      _attachedClassTableState = nextClassTableState;
      _attachedClassTableState!.addListener(_reload);
    }

    classTableState = nextClassTableState;
  }

  @override
  void dispose() {
    _attachedClassTableState?.removeListener(_reload);
    classTableState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClassTableState.of(context)!.controllers.haveClass
        ? ContentClassTablePage()
        : EmptyClassTablePage();
  }
}
