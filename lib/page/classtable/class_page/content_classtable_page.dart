// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:watermeter/repository/translation_key.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show ImageFilter;

import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/pda_service/custom_class.dart';
import 'package:watermeter/page/classtable/class_add/class_add_window.dart';
import 'package:watermeter/page/classtable/class_page/class_change_list.dart';
import 'package:watermeter/page/classtable/class_page/classtable_error_button.dart';
import 'package:watermeter/page/classtable/class_page/classtable_status_hint.dart';
import 'package:watermeter/page/classtable/class_table_view/class_table_sheet.dart';
import 'package:watermeter/page/classtable/class_table_view/frosted_header_slice.dart';
import 'package:watermeter/page/classtable/class_table_view/glass_blur.dart';
import 'package:watermeter/page/classtable/model/style_config/glass_style_config.dart';
import 'package:watermeter/page/classtable/model/classtable_constant.dart';
import 'package:watermeter/page/classtable/model/classtable_widget_state.dart';
import 'package:watermeter/page/classtable/classtable_scope.dart';
import 'package:watermeter/page/classtable/class_page/not_arranged_class_list.dart';
import 'package:watermeter/page/classtable/class_page/week_choice_view.dart';
import 'package:watermeter/page/classtable/class_page/week_selection_highlight.dart';
import 'package:watermeter/page/public_widget/toast.dart';

class ContentClassTablePage extends StatefulWidget {
  const ContentClassTablePage({super.key});

  @override
  State<StatefulWidget> createState() => _ContentClassTablePageState();
}

class _ContentClassTablePageState extends State<ContentClassTablePage> {
  /// Check whether listener is pushed...
  //bool isPushedListener = false;

  /// A lock of the week choice row.
  /// When locked, choiceWeek cannot be changed.
  bool isTopRowLocked = false;

  /// The backdrop this page's frosted controls share.
  ///
  /// Held here rather than left to [BackdropGroup]'s own default: that default mints a fresh
  /// [BackdropKey] every time the widget is built, so every rebuild of this page would re-key the
  /// group, and re-keying it marks every grouped filter as needing a repaint.
  final BackdropKey _backdropKey = BackdropKey();

  /// Classtable pageView controller.
  late PageController pageControl;

  /// Week choice row controller.
  ///
  /// A plain scroll controller rather than a page controller: the week row scrolls continuously so
  /// it can be dragged freely, instead of snapping from one week button to the next.
  late ScrollController rowControl;

  /// Set while [ClasstableWidgetState.chosenWeek] changes because the table itself was dragged.
  ///
  /// Such a change waits until the page settles, so the week row does not rebuild during the drag.
  bool _chosenWeekFromTable = false;

  /// Set while the week row's highlight is waiting for the pages to come to rest before it redraws.
  ///
  /// A week change redraws the week row and every week page with it, which is easily a frame's worth
  /// of work. Doing that in the middle of a drag is what made the table itself stutter, so it waits
  /// until the pages are still, where the very same work costs nothing anyone can see.
  bool _weekRowRefreshPending = false;

  /// Whether a frame callback is already watching for the pages to stop.
  bool _settleWatchScheduled = false;

  /// The page offset the watch last saw, which is how it tells "still moving" from "stopped".
  double _lastPagePixels = 0;

  /// The week on show. Published as a listenable so the week bar's highlight can follow it
  /// without the bar being rebuilt on the last frame of a swipe.
  final ValueNotifier<int> _chosenWeek = ValueNotifier<int>(0);

  late ClasstableWidgetState classTableState;
  bool _isBound = false;

  /// Whether the week bar is tucked into the app bar.
  ///
  /// Pinned is the default, so the stored flag is the opposite of it and an unset preference reads
  /// back as `false`.
  late bool _weekBarCollapsed;

  /// Whether the collapsed bar is currently opened over the table. Only meaningful while collapsed.
  bool _weekBarExpanded = false;

  /// Whether the collapsed floating bar is fully off-stage to stop rendering and layout completely.
  late bool _weekBarOffstage;

  /// The height the week bar takes, either in the page or floating.
  double get _weekBarHeight => MediaQuery.sizeOf(context).height >= 500
      ? topRowHeightBig
      : topRowHeightSmall;

  /// Rebuilds and repositions the week row once the pages have stopped moving.
  void _watchPageSettle(double pixels) {
    _lastPagePixels = pixels;
    if (_settleWatchScheduled) {
      return;
    }
    _settleWatchScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback(_onSettleWatchFrame);
  }

  void _onSettleWatchFrame(Duration _) {
    _settleWatchScheduled = false;
    if (!mounted || !_weekRowRefreshPending) {
      return;
    }
    if (pageControl.hasClients) {
      final double pixels = pageControl.position.pixels;
      if ((pixels - _lastPagePixels).abs() > 0.01) {
        /// Still moving: look again on the next frame.
        _watchPageSettle(pixels);
        return;
      }
    }
    _weekRowRefreshPending = false;
    final double? offset = _weekRowOffset(
      classTableState.chosenWeek.toDouble(),
    );
    if (offset != null) {
      rowControl.jumpTo(offset);
    }
  }

  /// The week row offset that shows the week [weeks] weeks into the semester.
  ///
  /// Null while the row cannot be measured yet.
  double? _weekRowOffset(double weeks) {
    if (!rowControl.hasClients) {
      return null;
    }
    final ScrollPosition rowPosition = rowControl.position;
    if (!rowPosition.hasContentDimensions) {
      return null;
    }
    return (weeks * weekChoiceItemExtent)
        .clamp(rowPosition.minScrollExtent, rowPosition.maxScrollExtent)
        .toDouble();
  }

  /// Keeps the week row on the same week as the table while the table moves.
  ///
  /// One table page is one week and one row item is one week, so the row's offset is the page's
  /// progress in weeks times [weekChoiceItemExtent]. Following the page frame by frame is what gives
  /// the row its easing: it rides the page's own animation curve when the week is picked elsewhere,
  /// and it stays under the finger when the table itself is dragged.
  void _syncWeekRowToTable() {
    /// While the page is running a week change picked elsewhere, the row is left where it is so the
    /// highlight can visibly slide from the old week to the new one. Only the table's own drag moves
    /// the row along. Also skip when the week bar is collapsed and hidden.
    if (isTopRowLocked || !_weekBarVisible) {
      return;
    }
    if (!pageControl.hasClients) {
      return;
    }
    final ScrollPosition pagePosition = pageControl.position;
    if (!pagePosition.hasViewportDimension ||
        pagePosition.viewportDimension <= 0) {
      return;
    }
    final double? offset = _weekRowOffset(
      pagePosition.pixels / pagePosition.viewportDimension,
    );
    if (offset != null) {
      final bool needsJump =
          !rowControl.hasClients ||
          !rowControl.position.hasPixels ||
          (rowControl.offset - offset).abs() > 0.01;
      if (needsJump) {
        rowControl.jumpTo(offset);
      }
    }
  }

  void _switchPage() {
    if (!mounted) {
      return;
    }

    /// First thing, whatever else happens: the highlight follows this directly.
    _chosenWeek.value = classTableState.chosenWeek;

    /// A week picked by dragging the table is already moving on screen. Defer the week row update
    /// until the page settles so the drag does not rebuild the overview buttons on every page tick.
    if (_chosenWeekFromTable) {
      _weekRowRefreshPending = true;
      if (!_settleWatchScheduled &&
          pageControl.hasClients &&
          pageControl.position.hasPixels) {
        _watchPageSettle(pageControl.position.pixels);
      }
      return;
    }

    setState(() => isTopRowLocked = true);

    /// The highlight slides to the chosen week on its own, so the row is only nudged when that week
    /// would otherwise be off screen. Watching the page scroll is paused for the duration (see
    /// [_syncWeekRowToTable]), which is what lets the highlight be seen moving.
    _revealWeekRow(classTableState.chosenWeek);

    /// The page is animated independently; the row ends up on the same week either way.
    pageControl
        .animateToPage(
          classTableState.chosenWeek,
          curve: Curves.easeInOutCubic,
          duration: const Duration(milliseconds: changePageTime),
        )
        .then((value) {
          if (!mounted) {
            return;
          }

          /// The row can be scrolled on its own, so make sure the chosen week is at least in view
          /// once the page has landed. When it already is, this does nothing.
          _revealWeekRow(classTableState.chosenWeek);
          isTopRowLocked = false;
        });
  }

  /// Brings [week]'s button into view, if it is not there already.
  ///
  /// Deliberately not an alignment: when the week is already on screen the row is left exactly where
  /// it is, so picking a neighbouring week slides the highlight across rather than dragging the whole
  /// row along with it. The row only moves when the new week would otherwise be off screen.
  void _revealWeekRow(int week) {
    if (!rowControl.hasClients) {
      return;
    }
    final ScrollPosition rowPosition = rowControl.position;
    if (!rowPosition.hasContentDimensions) {
      return;
    }
    const double edgePadding = 12.0;
    final double left = week * weekChoiceItemExtent;
    final double right = left + weekChoiceItemExtent;
    final double offset = rowControl.offset;
    double? target;
    if (left - edgePadding < offset) {
      target = left - edgePadding;
    } else if (right + edgePadding > offset + rowPosition.viewportDimension) {
      target = right + edgePadding - rowPosition.viewportDimension;
    }
    if (target == null) {
      return;
    }
    rowControl.animateTo(
      target
          .clamp(rowPosition.minScrollExtent, rowPosition.maxScrollExtent)
          .toDouble(),
      curve: Curves.easeInOutCubic,
      duration: const Duration(milliseconds: changePageTime),
    );
  }

  @override
  void dispose() {
    classTableState.weekNavigationNotifier.removeListener(_switchPage);
    pageControl.removeListener(_syncWeekRowToTable);
    _chosenWeek.dispose();
    pageControl.dispose();
    rowControl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (!_isBound) {
      classTableState = ClasstableScope.read(context);
      _weekBarCollapsed = classTableState.weekBarCollapsed;
      _weekBarOffstage = _weekBarCollapsed;

      /// Week navigation (tap or swipe) is handled separately so the class card pages — which do
      /// not depend on the chosen week at all — are not rebuilt mid-gesture.
      classTableState.weekNavigationNotifier.addListener(_switchPage);

      /// Created once: rebuilding them on every dependency change would reset the row's scroll
      /// position and leak the previous controllers.
      pageControl = PageController(
        initialPage: classTableState.chosenWeek,
        keepPage: true,
      );
      rowControl = ScrollController(
        initialScrollOffset: classTableState.chosenWeek * weekChoiceItemExtent,
      );
      _chosenWeek.value = classTableState.chosenWeek;

      /// The table drives the week row while it moves, which is what gives the row its easing: it
      /// rides the page's own animation curve instead of jumping once the page has arrived.
      pageControl.addListener(_syncWeekRowToTable);

      _isBound = true;
    }

    /// Init the background.
    super.didChangeDependencies();
    precacheImage(
      const AssetImage("assets/art/pda_classtable_empty.webp"),
      context,
    );
    final image = classTableState.decorationImage;
    if (image != null) {
      precacheImage(FileImage(image), context);
    }
  }

  /// The user defined background image, confined to the timetable area below the fixed header.
  ///
  /// The fixed header area above extracts and blurs the very top edge of the wallpaper to create
  /// an ambient frosted background. The actual, sharp wallpaper begins right at the timetable's
  /// top edge ([tableTop]), leaving character portraits and artwork fully unobstructed in the
  /// content area.
  Widget _backgroundLayer(BuildContext context, double appBarHeight) {
    final image = classTableState.decorationImage;
    if (image == null) {
      return const Positioned.fill(
        key: ValueKey('class_table_background_layer_empty'),
        child: SizedBox.shrink(),
      );
    }

    final viewport = MediaQuery.sizeOf(context);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = (math.max(viewport.width, viewport.height) * pixelRatio)
        .round()
        .clamp(1, 2560)
        .toInt();
    final imageRevision = classTableState.decorationImageRevision ?? '0';

    final double blur = classTableState.backgroundBlur;

    Widget layer = Image.file(
      image,
      key: ValueKey<String>("${image.path}:$imageRevision"),
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      cacheWidth: cacheWidth,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
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

    final double tableTop =
        appBarHeight + (_weekBarCollapsed ? 0 : _weekBarHeight);

    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          /// 1. The sharp wallpaper, confined to the timetable area below the fixed header.
          AnimatedPositioned(
            key: const ValueKey('class_table_background_layer'),
            left: 0,
            right: 0,
            top: tableTop,
            bottom: 0,
            duration: weekBarDockDuration,
            curve: Curves.easeOutCubic,
            child: ClipRect(child: layer),
          ),

          /// 2. The ambient top-edge stretch & blur, feathering 30dp into the timetable wallpaper.
          /// Strictly kept at the bottom-most background layer behind all UI controls and banners.
          AnimatedPositioned(
            key: const ValueKey('class_table_header_ambient_blur'),
            left: 0,
            right: 0,
            top: 0,
            height: tableTop + frostedHeaderFeatherHeight,
            duration: weekBarDockDuration,
            curve: Curves.easeOutCubic,
            child: IgnorePointer(
              child: FrostedHeaderSlice(
                headerHeight: tableTop,
                featherHeight: frostedHeaderFeatherHeight,
                sigma: GlassStyleConfig.appBarSigma,
                tintColor: Theme.of(context).colorScheme.surfaceContainerHigh
                    .withValues(alpha: weekBarSurfaceAlpha),
                imageFile: image,
                imageRevision: imageRevision,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The room the class table keeps after its last period, for the bottom of the display.
  ///
  /// The sheet scrolls down to its very last row, and the bottom of the screen is where the system
  /// navigation bar and the rounded corners of the display are. Neither becomes a margin around the
  /// table — it stays borderless and reaches the edges — so the room is handed to the sheet and
  /// spent as a blank stretch at the end of the time line.
  ///
  /// Sizing it is a question of how far the corner reaches *inwards* at the height of the lowest
  /// thing the table draws down there: the current time capsule and the time labels of the last
  /// period, which sit along the left edge [timeLineInset] in from the screen. A corner of radius
  /// `r` only cuts away what is farther out than `r - sqrt(r² - (r - inset)²)` above the bottom at
  /// that inset, so that height is exactly the room needed — no more, which is why the whole radius
  /// is not used. The system bar may ask for more on its own, and the sheet already keeps
  /// [classTableSheetEndGap] of it.
  double _sheetBottomClearance(BuildContext context) {
    /// `viewPadding` keeps the real size of the system bars, while `padding` gives up the bottom one
    /// as soon as the keyboard is around — and the table still must not crawl under the navigation
    /// bar in that case.
    final viewPadding = MediaQuery.viewPaddingOf(context);

    /// The radii come from [MediaQuery.displayCornerRadiiOf], which the platform fills in on
    /// Android 12 and later and leaves null everywhere else. Reading them there also means this page
    /// is rebuilt whenever they change, so the window does not have to be watched by hand.
    final corners = MediaQuery.displayCornerRadiiOf(context);
    final double radius = math.max(
      corners?.bottomLeft.y ?? 0,
      corners?.bottomRight.y ?? 0,
    );

    /// Where the curve passes the inset of that content: at the corner's own radius the curve has
    /// already left that inset behind, so nothing is cut away there.
    final double cornerReach = radius <= timeLineInset
        ? 0
        : radius -
              math.sqrt(
                radius * radius -
                    (radius - timeLineInset) * (radius - timeLineInset),
              );

    return math.max(
      0,
      math.max(viewPadding.bottom, cornerReach) - classTableSheetEndGap,
    );
  }

  /// A row shows a series of buttons about the classtable's index.
  ///
  /// This is at the top of the classtable. It contains a series of
  /// buttons which shows the week index, as well as an overview in a 5x5 dot gridview.
  ///
  /// When user click on the button, the pageview will show the class table of the
  /// week the button suggested.
  Widget _weekRow() {
    return ClipRect(
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          overscroll: false,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            /// The highlight sits behind the buttons, sliding from week to week.
            Positioned.fill(
              child: IgnorePointer(
                child: WeekSelectionHighlight(
                  week: _chosenWeek,
                  rowControl: rowControl,
                ),
              ),
            ),
            ListView.builder(
              controller: rowControl,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemExtent: weekChoiceItemExtent,
              itemCount: classTableState.semesterLength,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: weekButtonHorizontalPadding,
                  ),
                  child: Card(
                    /// Transparent: the highlight is the box behind the row, not a tint per button.
                    color: Colors.transparent,
                    elevation: 0.0,
                    child: InkWell(
                      /// The following themes are the same as the Material 3 Card Radius.
                      borderRadius: const BorderRadius.all(
                        Radius.circular(weekChoiceCardRadius),
                      ),
                      onTap: () {
                        if (isTopRowLocked == false) {
                          classTableState.chosenWeek = index;
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: WeekChoiceView(index: index),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Whether the bar is showing at all.
  ///
  /// Pinned means always; collapsed means only while the user has it open.
  bool get _weekBarVisible => !_weekBarCollapsed || _weekBarExpanded;

  /// Whether the bar floats over the table rather than sitting in the page.
  ///
  /// This is what the two modes animate between: floating is inset, rounded and shadowed, docked is
  /// flush with the app bar and takes its own strip.
  bool get _weekBarFloating => _weekBarCollapsed;

  /// The scrolling week buttons with the pin toggle at the end.
  ///
  /// One widget for both modes, so the two can animate into each other instead of being swapped.
  Widget _weekBarContents() {
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 4),
      child: Row(
        children: [
          Expanded(child: _weekRow()),
          _pinToggle(),
        ],
      ),
    );
  }

  /// Pins the bar, or tucks it back into the app bar.
  Widget _pinToggle() {
    return IconButton(
      onPressed: _toggleWeekBarPinned,
      icon: Icon(
        _weekBarCollapsed ? Icons.push_pin_outlined : Icons.push_pin,
        size: 18,
      ),
      tooltip: (_weekBarCollapsed
          ? context.t.classtable.weekBar.pin
          : context.t.classtable.weekBar.unpin),
    );
  }

  /// The mode is a preference, so it is remembered.
  void _toggleWeekBarPinned() {
    final bool collapsed = !_weekBarCollapsed;
    classTableState.setWeekBarCollapsed(collapsed);
    setState(() {
      _weekBarCollapsed = collapsed;
      _weekBarExpanded = false;
      if (!collapsed) {
        _weekBarOffstage = false;
      }
    });
  }

  /// What the collapsed bar reduces to in the app bar: the week number, as a rounded chip.
  Widget _weekChip() {
    return ValueListenableBuilder<int>(
      key: const ValueKey('week_chip'),
      valueListenable: _chosenWeek,
      builder: (context, chosenWeek, _) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: Theme.of(context).colorScheme.surfaceContainerHigh
                  .withValues(alpha: timeLineSurfaceAlpha),
              borderRadius: BorderRadius.circular(timeLineRadius),
              child: InkWell(
                borderRadius: BorderRadius.circular(timeLineRadius),
                onTap: () {
                  setState(() {
                    if (!_weekBarExpanded) {
                      _weekBarOffstage = false;
                    }
                    _weekBarExpanded = !_weekBarExpanded;
                  });
                },
                child: Container(
                  height: 32,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    context.t.classtable.weekTitle(
                      week: (chosenWeek + 1).toString(),
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ClasstableScope.of(context);

    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double appBarHeight = statusBarHeight + kToolbarHeight;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(context.t.classtable.pageTitle),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        actions: [
          ClassTableStatusHint(loadingSources: state.loadingSources),
          const ClassTableErrorButton(),

          /// While collapsed, the week number is all that is left of the bar.
          AnimatedSwitcher(
            duration: weekBarPopDuration,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axis: Axis.horizontal,
                child: Center(child: child),
              ),
            ),
            child: _weekBarCollapsed
                ? _weekChip()
                : const SizedBox.shrink(key: ValueKey('week_chip_empty')),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
              PopupMenuItem<String>(
                value: 'A',
                child: Text(context.t.classtable.popupMenu.notArranged),
              ),
              PopupMenuItem<String>(
                value: 'B',
                child: Text(context.t.classtable.popupMenu.classChanged),
              ),
              PopupMenuItem<String>(
                value: 'C',
                child: Text(context.t.classtable.popupMenu.addClass),
              ),
              PopupMenuItem<String>(
                value: 'D',
                child: Text(context.t.classtable.popupMenu.generateIcal),
              ),
              PopupMenuItem<String>(
                value: 'H',
                child: Text(context.t.classtable.popupMenu.outputToSystem),
              ),
              PopupMenuItem<String>(
                value: 'I',
                child: Text(context.t.classtable.popupMenu.refreshClasstable),
              ),
            ],
            onSelected: (String action) async {
              switch (action) {
                case 'A':
                  var notArranged = ClasstableScope.read(context).notArranged;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return NotArrangedClassList(notArranged: notArranged);
                      },
                    ),
                  );
                  break;
                case 'B':
                  var classChange = ClasstableScope.read(context).classChange;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return ClassChangeList(classChanges: classChange);
                      },
                    ),
                  );
                  break;
                case 'C':
                  dynamic data = await Navigator.of(context).push<dynamic>(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return ClassAddWindow(state: classTableState);
                      },
                    ),
                  );
                  if (context.mounted && data != null) {
                    if (data is CustomClass) {
                      await ClasstableScope.read(context).addCustomClass(data);
                    }
                  }
                  break;
                case 'D':
                  try {
                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          context
                              .t
                              .classtable
                              .partnerClasstable
                              .shareDialog
                              .title,
                        ),
                        content: Text(
                          context
                              .t
                              .classtable
                              .partnerClasstable
                              .shareDialog
                              .content,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(context.t.common.confirm),
                          ),
                        ],
                      ),
                    );
                    if (context.mounted) {
                      String fileName =
                          "classtable-"
                          "${DateFormat("yyyyMMddTHHmmss").format(DateTime.now())}-"
                          "${classTableState.semesterCode}"
                          ".ics";
                      //  if (Platform.isLinux ||
                      //      Platform.isMacOS ||
                      //      Platform.isWindows) {
                      await FilePicker.saveFile(
                        dialogTitle: context
                            .t
                            .classtable
                            .partnerClasstable
                            .saveDialog
                            .title,
                        fileName: fileName,
                        allowedExtensions: ["ics"],
                        bytes: Uint8List.fromList(
                          utf8.encode(classTableState.iCalenderStr),
                        ),
                        windowsOptions: WindowsOptions(lockParentWindow: true),
                        linuxOptions: LinuxOptions(lockParentWindow: true),
                      );
                      //  } else {
                      //    String tempPath = await getTemporaryDirectory().then(
                      //      (value) => value.path,
                      //    );
                      //    File file = File("$tempPath/$fileName");
                      //    if (!(await file.exists())) {
                      //      await file.create();
                      //    }
                      //    await file.writeAsString(classTableState.iCalenderStr);
                      //   await SharePlus.instance.share(
                      //    ShareParams(
                      //        files: [XFile("$tempPath/$fileName")],
                      //        sharePositionOrigin:
                      //            box!.localToGlobal(Offset.zero) & box.size,
                      //     ),
                      //  );

                      //    await file.delete();
                    }
                    //}
                    if (context.mounted) {
                      showToast(
                        context: context,
                        msg: context
                            .t
                            .classtable
                            .partnerClasstable
                            .saveDialog
                            .successMessage,
                      );
                    }
                  } on FileSystemException {
                    if (context.mounted) {
                      showToast(
                        context: context,
                        msg: context
                            .t
                            .classtable
                            .partnerClasstable
                            .saveDialog
                            .failureMessage,
                      );
                    }
                  }
                  break;
                case 'H':
                  await classTableState
                      .outputToCalendar(() async {
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              context
                                  .t
                                  .classtable
                                  .outputToSystem
                                  .requestAllTitle,
                            ),
                            content: Text(
                              context.t.classtable.outputToSystem.requestAll,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text(context.t.common.confirm),
                              ),
                            ],
                          ),
                        );
                      })
                      .then((data) {
                        if (context.mounted) {
                          showToast(
                            context: context,
                            msg: context.t.resolveKey(
                              data
                                  ? "classtable.output_to_system.success"
                                  : "classtable.output_to_system.failure",
                            ),
                          );
                        }
                      });
                case 'I':
                  bool isAccepted =
                      await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text(context.t.setting.classRefreshTitle),
                          content: Text(context.t.setting.classRefreshContent),
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onPrimary,
                              ),
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(context.t.common.cancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(context.t.common.confirm),
                            ),
                          ],
                        ),
                      ) ??
                      false;
                  if (context.mounted && isAccepted) {
                    await classTableState.updateClasstable();
                    if (context.mounted) {
                      showToast(
                        context: context,
                        msg: context.t.classtable.refreshClasstable.success,
                      );
                    }
                  }
                  break;
              }
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          /// The wallpaper, confined to the timetable area below the fixed header.
          _backgroundLayer(context, appBarHeight),

          /// The page. While the bar floats it starts at the top and the bar covers it; once the bar
          /// is pinned it slides down to leave the bar a strip of its own.
          AnimatedPositioned(
            left: 0,
            right: 0,
            top: appBarHeight + (_weekBarCollapsed ? 0 : _weekBarHeight),
            bottom: 0,
            duration: weekBarDockDuration,
            curve: Curves.easeOutCubic,
            child: NotificationListener<ScrollNotification>(
              /// Dragging the table puts the floating bar away, so it does not sit on top of a
              /// table the user is trying to reach.
              ///
              /// Only a drag counts. Picking a week from the bar itself pages the table over an
              /// animation, and that is not a reason to close the bar the user is working in: it
              /// stays out until they put it away themselves.
              onNotification: (ScrollNotification notification) {
                final bool dragStarted =
                    notification is ScrollStartNotification &&
                    notification.dragDetails != null;
                if (dragStarted && _weekBarCollapsed && _weekBarExpanded) {
                  setState(() => _weekBarExpanded = false);
                }
                return false;
              },

              /// Controls that opt into grouping share one blur of the backdrop: the status banner
              /// and the class cards. Panels with their own independent blur (such as the date row
              /// and time line) maintain their own blur caches.
              child: BackdropGroup(
                backdropKey: _backdropKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ClassTableSheet(
                      singleIndex: classTableState.chosenWeek,
                      pageControl: pageControl,
                      semesterLength: classTableState.semesterLength,
                      onPageChanged: _onPageChanged,
                      bottomClearance: _sheetBottomClearance(context),
                    ).expanded(),
                  ],
                ),
              ),
            ),
          ),

          /// Tapping anywhere else puts the floating bar away.
          ///
          /// Kept mounted even while closed and merely ignored, because a conditionally present
          /// sibling shifts the bar along the Stack's children list: Flutter would then treat the bar
          /// as a brand new element and the implicit animations below would jump straight to their
          /// new values instead of running.
          ///
          /// `translucent`, not `opaque`: opaque would swallow the drag as well as the tap and leave
          /// the table unscrollable while the bar is open. Being hit first still lets this layer win
          /// the tap, so a tap on a class card does not open it.
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !(_weekBarCollapsed && _weekBarExpanded),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => setState(() => _weekBarExpanded = false),
              ),
            ),
          ),

          /// The unified frosted header glass behind the navigation bar and docked week bar.
          ///
          /// Sized strictly to the docked header height so that cards scrolling up pass underneath it,
          /// while remaining completely clear of the content and banners below. Ambient edge blur
          /// feathering is handled separately at the bottom-most background layer.
          ///
          /// When the week bar is floating or tucked away, this layer seamlessly sizes to [appBarHeight],
          /// continuing to provide the frosted backdrop for the navigation bar alone, while the
          /// floating week bar carries its own independent floating frosted capsule below.
          AnimatedPositioned(
            left: 0,
            right: 0,
            top: 0,
            height: appBarHeight + (!_weekBarCollapsed ? _weekBarHeight : 0),
            duration: weekBarDockDuration,
            curve: Curves.easeOutCubic,
            child: IgnorePointer(
              child: GlassBlur(
                sigma: GlassStyleConfig.appBarSigma,
                child: ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh
                      .withValues(alpha: weekBarSurfaceAlpha),
                ),
              ),
            ),
          ),

          /// The bar itself, one element for both modes.
          ///
          /// Collapsed it is inset, rounded and shadowed so it reads as floating over the table;
          /// pinned it grows to the full width, squares off and drops its shadow as it docks. The
          /// page above follows a slightly longer curve, so the bar visibly settles first and the
          /// table then takes its place.
          AnimatedPositioned(
            left: _weekBarFloating ? timeLineInset : 0,
            right: _weekBarFloating ? timeLineInset : 0,
            top: appBarHeight + (_weekBarFloating ? timeLineInset : 0),
            height: _weekBarHeight,
            duration: weekBarPopDuration,
            curve: _weekBarVisible
                ? Curves.easeOutCubic
                : Curves.easeInOutCubic,
            child: Offstage(
              offstage: _weekBarOffstage,
              child: IgnorePointer(
                ignoring: !_weekBarVisible,
                child: ClipRect(
                  clipper: const _WeekBarTopClipper(),
                  child: AnimatedSlide(
                    offset: _weekBarVisible
                        ? Offset.zero
                        : const Offset(0, -1.35),
                    duration: weekBarPopDuration,
                    curve: _weekBarVisible
                        ? Curves.easeOutCubic
                        : Curves.easeInOutCubic,
                    onEnd: () {
                      if (!_weekBarVisible && mounted) {
                        setState(() => _weekBarOffstage = true);
                      }
                    },
                    child: AnimatedContainer(
                      duration: weekBarPopDuration,
                      curve: _weekBarVisible
                          ? Curves.easeOutCubic
                          : Curves.easeInOutCubic,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          _weekBarFloating ? timeLineRadius : 0,
                        ),
                        boxShadow: _weekBarFloating
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: timeLineShadowAlpha,
                                  ),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Stack(
                        children: [
                          if (_weekBarFloating)
                            Positioned.fill(
                              child: GlassBlur(
                                borderRadius: BorderRadius.circular(
                                  timeLineRadius,
                                ),
                                sigma: GlassStyleConfig.weekBarSigma,
                                child: ColoredBox(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHigh
                                      .withValues(alpha: weekBarSurfaceAlpha),
                                ),
                              ),
                            ),

                          /// Taps on the bar's own body keep it open: putting it away is for taps
                          /// outside it. Translucent rather than opaque, so a drag that starts on
                          /// the bar still reaches the table underneath.
                          Positioned.fill(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {},
                            ),
                          ),
                          _weekBarContents(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Keeps [classTableState.chosenWeek] in step with the week pages.
  void _onPageChanged(int value) {
    /// When [pageControl.animateTo] triggered,
    /// page view will try to refresh the [chosenWeek] everytime the page
    /// view changed into a new page. Because animateTo will load every page
    /// it passed.
    ///
    /// So that's the [isTopRowLocked] is used for. When week choice row is
    /// locked, it will not refresh the [chosenWeek]. And when [chosenWeek]
    /// is equal to the current page, unlock the [isTopRowLocked].
    if (isTopRowLocked == false) {
      /// Flagged so [_switchPage] leaves the table to finish its own gesture instead of animating
      /// a page the user is still dragging. The row is repositioned after the page settles.
      _chosenWeekFromTable = true;
      try {
        classTableState.chosenWeek = value;
      } finally {
        _chosenWeekFromTable = false;
      }
    }
  }
}

/// Clips the week bar strictly at top: 0 to prevent any portion of it or its shadow
/// from bleeding behind the frosted AppBar during slide animations, while leaving
/// left, right, and bottom unclipped so its drop shadow remains intact.
class _WeekBarTopClipper extends CustomClipper<Rect> {
  const _WeekBarTopClipper();

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(-24, 0, size.width + 24, size.height + 24);
  }

  @override
  bool shouldReclip(covariant _WeekBarTopClipper oldClipper) => false;
}
