import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';

class ClassDetailState extends InheritedWidget {
  final int currentWeek;
  final List<TimeArrangement> information;
  final List<ClassDetail> classDetail;

  const ClassDetailState({
    super.key,
    required this.currentWeek,
    required this.information,
    required this.classDetail,
    required super.child,
  });

  static ClassDetailState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ClassDetailState>();
  }

  @override
  bool updateShouldNotify(covariant ClassDetailState oldWidget) {
    return false;
  }
}
