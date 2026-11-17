// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/generated/translations.g.dart';
import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';
import 'package:watermeter/page/classtable/class_table_view/class_table_sheet.dart';
import 'package:watermeter/page/classtable/class_table_view/glass_blur.dart';
import 'package:watermeter/page/classtable/classtable_scope.dart';
import 'package:watermeter/page/classtable/data/preview_classtable_source.dart';
import 'package:watermeter/page/classtable/model/classtable_constant.dart';
import 'package:watermeter/page/classtable/model/classtable_widget_state.dart';

class ClassTablePreview extends StatefulWidget {
  final bool loadStylePreferences;
  final bool enableVerticalScrolling;
  final double? backgroundBlur;

  const ClassTablePreview({
    super.key,
    this.loadStylePreferences = true,
    this.enableVerticalScrolling = false,
    this.backgroundBlur,
  });

  @override
  State<ClassTablePreview> createState() => _ClassTablePreviewState();
}

class _ClassTablePreviewState extends State<ClassTablePreview> {
  late final ClasstableWidgetState _state = ClasstableWidgetState(
    source: PreviewClasstableDataSource(),
    loadStyleSettings: widget.loadStylePreferences,
  );

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  Widget _backgroundLayer(BuildContext context) {
    final image = _state.decorationImage;
    if (image == null) {
      return const SizedBox.shrink();
    }

    final blur = (widget.backgroundBlur ?? _state.backgroundBlur)
        .clamp(0.0, maxClassTableBackgroundBlur)
        .toDouble();

    Widget layer = Image.file(
      image,
      key: ValueKey("${image.path}:${_state.decorationImageRevision}"),
      fit: BoxFit.cover,
      gaplessPlayback: true,
      opacity: AlwaysStoppedAnimation<double>(
        Theme.of(context).brightness == Brightness.dark ? 0.4 : 1.0,
      ),
    );

    if (blur > 0) {
      layer = ClipRect(
        child: Transform.scale(
          scale: 1 + blur / 50,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: blur,
              sigmaY: blur,
              tileMode: TileMode.clamp,
            ),
            child: layer,
          ),
        ),
      );
    }

    return Positioned.fill(child: layer);
  }

  @override
  Widget build(BuildContext context) {
    return ClasstableScope(
      state: _state,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _backgroundLayer(context),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.75),
                ),
                padding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
                constraints: const BoxConstraints(minWidth: double.infinity),
                child: Text(
                  context.t.setting.fontSizePage.previewTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Expanded(
                /// Allow blur here so this sample reflects the glass setting live. Its synthetic
                /// timetable is small enough to keep the preview responsive.
                ///
                /// Clamping rather than bouncing, as upstream had it: the sample is a pane
                /// inside a page that already scrolls, so a pull here would fight the page.
                child: GlassBlurScope(
                  enabled: true,
                  child: ClassTableSheet(
                    singleIndex: _state.currentWeek,

                    /// When the sample is not given a viewport of its own it expands to the
                    /// table's full height and the settings page around it scrolls, so the
                    /// last periods of the day are reachable in the sample too.
                    enableVerticalScrolling: widget.enableVerticalScrolling,
                    verticalPhysics: const ClampingScrollPhysics(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
