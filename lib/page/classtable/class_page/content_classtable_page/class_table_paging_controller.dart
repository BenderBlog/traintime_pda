// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

part of '../content_classtable_page.dart';

class ClassTablePagingController extends ChangeNotifier {
  final bool Function() isMounted;

  ClassTablePagingController({required this.isMounted});

  late PageController pageController;
  late PageController rowController;
  ClassTableWidgetState? _state;
  double? _viewportWidth;
  double? _viewportFraction;
  int? _lastAnimatedWeek;
  int _animationToken = 0;
  bool _skipNextContentPageAnimation = false;
  bool _hasControllers = false;
  bool isTopRowLocked = false;

  ClassTableWidgetState get state => _state!;

  void bind({
    required ClassTableWidgetState state,
    required double viewportWidth,
  }) {
    final stateChanged = _state != state;
    if (stateChanged) {
      _state?.removeListener(_switchPage);
      _state = state;
      _state!.addListener(_switchPage);
    }

    final viewportFraction =
        (weekButtonWidth + 2 * weekButtonHorizontalPadding) / viewportWidth;
    if (!stateChanged &&
        _hasControllers &&
        _viewportFraction == viewportFraction) {
      return;
    }

    _viewportWidth = viewportWidth;
    if (_hasControllers) {
      pageController.dispose();
      rowController.dispose();
    }

    pageController = PageController(
      initialPage: state.chosenWeek,
      keepPage: true,
    );
    rowController = PageController(
      initialPage: state.chosenWeek,
      viewportFraction: viewportFraction,
      keepPage: true,
    );
    _viewportFraction = viewportFraction;
    _lastAnimatedWeek = state.chosenWeek;
    _animationToken++;
    _setTopRowLocked(false);
    _hasControllers = true;
  }

  @override
  void dispose() {
    _state?.removeListener(_switchPage);
    if (_hasControllers) {
      pageController.dispose();
      rowController.dispose();
    }
    super.dispose();
  }

  double _centeredWeekOffset(int week) {
    final viewportWidth = _viewportWidth;
    if (viewportWidth == null) {
      return rowController.position.pixels;
    }

    final itemWidth = weekButtonWidth + 2 * weekButtonHorizontalPadding;
    final rawOffset = week * itemWidth - (viewportWidth - itemWidth) / 2;
    final maxOffset = rowController.position.maxScrollExtent;
    return rawOffset.clamp(0.0, maxOffset).toDouble();
  }

  void chooseWeek(int index) {
    if (state.chosenWeek == index) {
      return;
    }
    state.chosenWeek = index;
  }

  void chooseWeekAt(double viewportX) {
    if (!rowController.hasClients) {
      return;
    }

    final itemWidth = weekButtonWidth + 2 * weekButtonHorizontalPadding;
    final index = ((rowController.position.pixels + viewportX) / itemWidth)
        .floor()
        .clamp(0, state.semesterLength - 1);
    chooseWeek(index);
  }

  void onPageChanged(int value) {
    if (isTopRowLocked || state.chosenWeek == value) {
      return;
    }
    _skipNextContentPageAnimation = true;
    state.chosenWeek = value;
  }

  void _setTopRowLocked(bool value) {
    if (isTopRowLocked == value) {
      return;
    }
    isTopRowLocked = value;
    notifyListeners();
  }

  void _switchPage() {
    if (!isMounted() || !_hasControllers) {
      return;
    }
    final targetWeek = state.chosenWeek;
    if (_lastAnimatedWeek == targetWeek) {
      return;
    }
    if (!rowController.hasClients || !pageController.hasClients) {
      _setTopRowLocked(false);
      return;
    }

    _lastAnimatedWeek = targetWeek;
    final animationToken = ++_animationToken;
    final skipContentPageAnimation = _skipNextContentPageAnimation;
    _skipNextContentPageAnimation = false;
    _setTopRowLocked(true);

    final animations = <Future<void>>[
      rowController.animateTo(
        _centeredWeekOffset(targetWeek),
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: changePageTime),
      ),
    ];

    final contentPage = pageController.page;
    if (!skipContentPageAnimation &&
        (contentPage == null || (contentPage - targetWeek).abs() > 0.01)) {
      animations.add(
        pageController.animateToPage(
          targetWeek,
          curve: Curves.easeInOutCubic,
          duration: const Duration(milliseconds: changePageTime),
        ),
      );
    }

    Future.wait(animations).whenComplete(() {
      if (isMounted() && animationToken == _animationToken) {
        _setTopRowLocked(false);
      }
    });
  }
}
