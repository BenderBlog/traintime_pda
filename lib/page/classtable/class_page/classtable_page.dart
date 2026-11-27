import 'package:material_ui/material_ui.dart';
import 'package:watermeter/page/classtable/class_page/content_classtable_page.dart';
import 'package:watermeter/page/classtable/class_page/empty_classtable_page.dart';
import 'package:watermeter/page/classtable/classtable_scope.dart';

/// Switches between the table and the "no classes yet" page.
///
/// Reading the scope here is what makes the switch happen: the page is rebuilt whenever the table's
/// snapshot changes, so no listener of its own is needed.
class ClassTablePage extends StatelessWidget {
  const ClassTablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ClasstableScope.of(context).haveClass
        ? const ContentClassTablePage()
        : const EmptyClassTablePage();
  }
}
