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
  double? _viewportFraction;
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

  void chooseWeek(int index) {
    if (!isTopRowLocked) {
      state.chosenWeek = index;
    }
  }

  void onPageChanged(int value) {
    if (!isTopRowLocked) {
      state.chosenWeek = value;
    }
  }

  void _switchPage() {
    if (!isMounted() || !_hasControllers) {
      return;
    }
    if (!rowController.hasClients || !pageController.hasClients) {
      isTopRowLocked = false;
      notifyListeners();
      return;
    }
    isTopRowLocked = true;
    notifyListeners();
    Future.wait([
      rowController.animateToPage(
        state.chosenWeek,
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: changePageTime),
      ),
      pageController.animateToPage(
        state.chosenWeek,
        curve: Curves.easeInOutCubic,
        duration: const Duration(milliseconds: changePageTime),
      ),
    ]).then((value) {
      if (isMounted()) {
        isTopRowLocked = false;
        notifyListeners();
      }
    });
  }
}
