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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    classTableState = ClassTableState.of(context)!.controllers;
    classTableState.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    classTableState.removeListener(() => setState(() {}));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClassTableState.of(context)!.controllers.haveClass
        ? ContentClassTablePage()
        : EmptyClassTablePage();
  }
}
