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

  void _reload() => setState(() {});

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    classTableState = ClassTableState.of(context)!.controllers;
    classTableState.addListener(_reload);
  }

  @override
  void dispose() {
    classTableState.removeListener(_reload);
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
