import 'package:watermeter/generated/translations.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:watermeter/page/classtable/class_page/classtable_error_button.dart';
import 'package:watermeter/page/classtable/class_page/classtable_status_hint.dart';
import 'package:watermeter/page/exam/exam_info_window.dart';
import 'package:watermeter/page/experiment/experiment_window.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/translation_key.dart';

class EmptyClassTablePage extends StatelessWidget {
  const EmptyClassTablePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = ClassTableState.of(context)!.controllers;
    final hasError =
        state.errorWithoutCacheSources.isNotEmpty ||
        state.errorWithCacheSources.isNotEmpty;
    final hasExamArrangement = state.hasExamArrangement;
    final hasExperimentArrangement = state.hasExperimentArrangement;
    final emptyMessageKey = hasExamArrangement && hasExperimentArrangement
        ? "classtable.empty_state.with_exam_and_experiment"
        : hasExamArrangement
        ? "classtable.empty_state.with_exam"
        : hasExperimentArrangement
        ? "classtable.empty_state.with_experiment"
        : "classtable.empty_state.no_course";

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.classtable.pageTitle),
        actions: [
          ClassTableStatusHint(
            loadingSources: state.loadingSources,
            cacheSources: state.cacheSources,
            cacheExplained: hasError,
          ),
          const ClassTableErrorButton(),
        ],
      ),
      body: EmptyListView(
        type: EmptyListViewType.rolling,
        text: context.t.resolveKey(
          emptyMessageKey,
          params: {
            "semester_code": ClassTableState.of(
              context,
            )!.controllers.semesterCode,
          },
        ),
        buttons: [
          if (hasExamArrangement)
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ExamInfoWindow()),
              ),
              icon: const Icon(Icons.assignment_outlined),
              label: Text(context.t.classtable.emptyAction.viewExam),
            ),
          if (hasExperimentArrangement)
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ExperimentWindow(),
                ),
              ),
              icon: const Icon(Icons.science_outlined),
              label: Text(context.t.classtable.emptyAction.viewExperiment),
            ),
          TextButton.icon(
            onPressed: () async {
              showToast(
                context: context,
                msg: context.t.classtable.refreshClasstable.ready,
              );
              await ClassTableState.of(
                context,
              )!.controllers.updateClasstable(context).then((data) {
                if (context.mounted) {
                  showToast(
                    context: context,
                    msg: context.t.classtable.refreshClasstable.success,
                  );
                }
              });
            },
            icon: const Icon(Icons.update),
            label: Text(context.t.classtable.popupMenu.refreshClasstable),
          ),
        ],
      ).expanded(),
    );
  }
}
