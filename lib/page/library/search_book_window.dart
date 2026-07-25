// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/public_widget/both_side_sheet.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/repository/xidian_ids/library_session.dart'
    as search_book;
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/page/library/book_detail_card.dart';
import 'package:watermeter/page/library/book_info_card.dart';

const double _searchPanelMaxWidth = 760;
const double _resultCardMaxWidth = 360;

enum SearchPanelMode { normal, advanced }

typedef _SearchOption = search_book.LibrarySearchOption;

class SearchBookWindow extends StatefulWidget {
  const SearchBookWindow({super.key});

  @override
  State<SearchBookWindow> createState() => _SearchBookWindowState();
}

class _SearchBookWindowState extends State<SearchBookWindow>
    with AutomaticKeepAliveClientMixin {
  late final PagingController<int, BookInfo> _pagingController =
      PagingController<int, BookInfo>(
        getNextPageKey: (state) =>
            state.lastPageIsEmpty ? null : state.nextIntPageKey,

        fetchPage: _fetchPage,
      );

  bool _useAdvancedSearch = false;
  String _normalSearch = "";
  String _advancedSearch = "";
  String _normalSearchField = "keyWord";
  String _advancedSearchField = "keyWord";
  String _advancedMatchMode = "2";
  String _documentType = "";
  String _resourceType = "";
  String _campusId = "";
  String _locationId = "";
  String _countryCode = "";
  String _languageCode = "";
  String _publishBegin = "";
  String _publishEnd = "";
  bool _onlyOnShelf = false;
  SearchPanelMode _searchMode = SearchPanelMode.normal;
  bool _hasSearched = false;
  bool _advancedPanelCollapsed = false;
  late final Future<search_book.LibrarySearchFilterOptions>
  _filterOptionsFuture = search_book.LibrarySession().searchFilterOptions();

  @override
  bool get wantKeepAlive => true;

  late final TextEditingController _normalTextController =
      TextEditingController.fromValue(TextEditingValue(text: _normalSearch));
  late final TextEditingController _advancedTextController =
      TextEditingController.fromValue(TextEditingValue(text: _advancedSearch));

  @override
  void dispose() {
    _normalTextController.dispose();
    _advancedTextController.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  Future<List<BookInfo>> _fetchPage(int pageKey) {
    final session = search_book.LibrarySession();
    if (_useAdvancedSearch) {
      return session.advancedSearchBook(
        _advancedSearch,
        pageKey,
        searchField: _advancedSearchField,
        matchMode: _advancedMatchMode,
        docCode: _emptyToNull(_documentType),
        resourceType: _emptyToNull(_resourceType),
        campusId: _intFilter(_campusId),
        locationId: _intFilter(_locationId),
        countryCode: _emptyToNull(_countryCode),
        langCode: _emptyToNull(_languageCode),
        onlyOnShelf: _onlyOnShelf ? true : null,
        publishBegin: _publishBegin,
        publishEnd: _publishEnd,
      );
    }
    return session.searchBook(
      _normalSearch,
      pageKey,
      searchField: _normalSearchField,
    );
  }

  void _submitNormalSearch() {
    FocusScope.of(context).unfocus();
    setState(() {
      _useAdvancedSearch = false;
      _normalSearch = _normalTextController.text.trim();
      _hasSearched = true;
    });
    _pagingController.refresh();
  }

  String? _emptyToNull(String value) => value.isEmpty ? null : value;

  int? _intFilter(String value) => value.isEmpty ? null : int.tryParse(value);

  void _resetAdvancedSearch() {
    setState(() {
      _advancedSearch = "";
      _advancedTextController.clear();
      _advancedSearchField = "keyWord";
      _advancedMatchMode = "2";
      _documentType = "";
      _resourceType = "";
      _campusId = "";
      _locationId = "";
      _countryCode = "";
      _languageCode = "";
      _publishBegin = "";
      _publishEnd = "";
      _onlyOnShelf = false;
    });
  }

  void _submitAdvancedSearch() {
    FocusScope.of(context).unfocus();
    setState(() {
      _useAdvancedSearch = true;
      _advancedSearch = _advancedTextController.text.trim();
      _hasSearched = true;
    });
    _pagingController.refresh();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Column(
        children: [
          _buildSearchArea(context)
              .padding(horizontal: 8, vertical: 4)
              .constrained(maxWidth: _searchPanelMaxWidth),
          if (_hasSearched) _buildResultList().expanded(),
        ],
      ),
    );
  }

  Widget _buildResultList() {
    return PagingListener(
      controller: _pagingController,
      builder: (context, state, fetchNextPage) => LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = (constraints.maxWidth ~/ _resultCardMaxWidth).clamp(1, 6);
          return PagedMasonryGridView<int, BookInfo>.count(
            state: state,
            fetchNextPage: fetchNextPage,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            builderDelegate: PagedChildBuilderDelegate<BookInfo>(
              itemBuilder: (context, item, index) =>
                  GestureDetector(
                        child: BookInfoCard(toUse: item),
                        onTap: () => _openBookDetail(item),
                      )
                      .padding(horizontal: 12, vertical: 2)
                      .width(double.infinity)
                      .constrained(width: _resultCardMaxWidth)
                      .center(),
              firstPageProgressIndicatorBuilder: (context) =>
                  const Center(child: CircularProgressIndicator()),
              firstPageErrorIndicatorBuilder: (context) => ReloadWidget(
                function: () async => _pagingController.refresh(),
                errorStatus: _pagingController.error,
              ),
              noItemsFoundIndicatorBuilder: (context) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search, size: 96.0),
                      const SizedBox(height: 16),
                      Text(
                        FlutterI18n.translate(context, "library.no_result"),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              noMoreItemsIndicatorBuilder: (context) =>
                  [
                        Icon(Icons.sentiment_very_satisfied, size: 32),
                        SizedBox(width: 8),
                        Text(
                          "That's all folks!",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ]
                      .toRow(mainAxisAlignment: MainAxisAlignment.center)
                      .padding(vertical: 12)
                      .center(),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openBookDetail(BookInfo item) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await BothSideSheet.show(
      context: context,
      title: FlutterI18n.translate(context, "library.book_detail"),
      child: BookDetailCard(toUse: item),
    );
  }

  Widget _buildSearchArea(BuildContext context) {
    return FutureBuilder<search_book.LibrarySearchFilterOptions>(
      future: _filterOptionsFuture,
      builder: (context, snapshot) {
        final options =
            snapshot.data ?? search_book.LibrarySearchFilterOptions.fallback();
        return _SearchBlock(
          header: _buildSearchModeSwitch(context),
          collapsed:
              _searchMode == SearchPanelMode.advanced &&
              _advancedPanelCollapsed,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (_searchMode == SearchPanelMode.advanced) {
                return _buildAdvancedSearchFields(
                  context,
                  constraints.maxWidth,
                  options,
                );
              }
              return _buildNormalSearchFields(
                context,
                constraints.maxWidth,
                options,
              );
            },
          ),
        );
      },
    );
  }

  List<_SearchOption> _matchModeOptions(BuildContext context) => [
    search_book.LibrarySearchOption(
      "1",
      FlutterI18n.translate(context, "library.match_exact"),
      "精确",
    ),
    search_book.LibrarySearchOption(
      "2",
      FlutterI18n.translate(context, "library.match_fuzzy"),
      "模糊",
    ),
    search_book.LibrarySearchOption(
      "3",
      FlutterI18n.translate(context, "library.match_prefix"),
      "前方",
    ),
  ];

  Widget _buildSearchFieldDropdown({
    required BuildContext context,
    required String value,
    required List<_SearchOption> options,
    required ValueChanged<String> onChanged,
    int selectedMaxLines = 2,
  }) {
    return _buildOptionDropdown(
      context,
      label: FlutterI18n.translate(context, "library.search_field_title"),
      value: value,
      options: options,
      selectedMaxLines: selectedMaxLines,
      onChanged: onChanged,
    );
  }

  Widget _buildSearchModeSwitch(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        ToggleButtons(
          isSelected: [
            _searchMode == SearchPanelMode.normal,
            _searchMode == SearchPanelMode.advanced,
          ],
          borderRadius: BorderRadius.circular(10),
          constraints: const BoxConstraints.tightFor(width: 76, height: 34),
          selectedColor: colorScheme.onPrimary,
          fillColor: colorScheme.primary,
          color: colorScheme.primary,
          onPressed: (index) {
            setState(() {
              _searchMode = index == 0
                  ? SearchPanelMode.normal
                  : SearchPanelMode.advanced;
            });
          },
          children: [
            Text(FlutterI18n.translate(context, "library.normal_search")),
            Text(FlutterI18n.translate(context, "library.advanced_search")),
          ],
        ),
        const Spacer(),
        if (_searchMode == SearchPanelMode.advanced)
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => setState(
              () => _advancedPanelCollapsed = !_advancedPanelCollapsed,
            ),
            icon: Icon(
              _advancedPanelCollapsed
                  ? Icons.keyboard_arrow_down
                  : Icons.keyboard_arrow_up,
            ),
            tooltip: _advancedPanelCollapsed ? "展开条件" : "收起条件",
          ),
      ],
    );
  }

  Widget _buildAdvancedSearchInput(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _advancedTextController,
            decoration: _inputDecoration(
              context,
              FlutterI18n.translate(context, "library.search_here"),
              prefixIcon: Icons.manage_search,
            ),
            onFieldSubmitted: (_) => _submitAdvancedSearch(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: _submitAdvancedSearch,
          icon: const Icon(Icons.manage_search),
          tooltip: FlutterI18n.translate(context, "library.search"),
        ),
      ],
    );
  }

  Widget _buildNormalSearchFields(
    BuildContext context,
    double maxWidth,
    search_book.LibrarySearchFilterOptions options,
  ) {
    return Row(
      children: [
        SizedBox(
          width: maxWidth < 430 ? 128 : 152,
          child: _buildSearchFieldDropdown(
            context: context,
            value: _normalSearchField,
            options: options.searchFields,
            selectedMaxLines: 1,
            onChanged: (value) => setState(() => _normalSearchField = value),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: _normalTextController,
            decoration: _inputDecoration(
              context,
              FlutterI18n.translate(context, "library.search_here"),
              prefixIcon: Icons.search,
            ),
            onFieldSubmitted: (_) => _submitNormalSearch(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: _submitNormalSearch,
          icon: const Icon(Icons.search),
          tooltip: FlutterI18n.translate(context, "library.search"),
        ),
      ],
    );
  }

  Widget _buildAdvancedSearchFields(
    BuildContext context,
    double maxWidth,
    search_book.LibrarySearchFilterOptions options,
  ) {
    return [
      _SearchFields(
        maxWidth: maxWidth,
        columnCount: 2,
        children: [
          _buildSearchFieldDropdown(
            context: context,
            value: _advancedSearchField,
            options: options.searchFields,
            onChanged: (value) => setState(() => _advancedSearchField = value),
          ),
          _buildOptionDropdown(
            context,
            label: FlutterI18n.translate(context, "library.match_mode"),
            value: _advancedMatchMode,
            options: _matchModeOptions(context),
            onChanged: (value) => setState(() => _advancedMatchMode = value),
          ),
          _buildOptionDropdown(
            context,
            label: "资料类型",
            value: _documentType,
            options: options.documentTypes,
            onChanged: (value) => setState(() => _documentType = value),
          ),
          _buildOptionDropdown(
            context,
            label: "资源类型",
            value: _resourceType,
            options: options.resourceTypes,
            onChanged: (value) => setState(() => _resourceType = value),
          ),
          _buildOptionDropdown(
            context,
            label: "校区",
            value: _campusId,
            options: options.campuses,
            onChanged: (value) => setState(() => _campusId = value),
          ),
          _buildOptionDropdown(
            context,
            label: "馆藏地",
            value: _locationId,
            options: options.locations,
            onChanged: (value) => setState(() => _locationId = value),
          ),
          _buildOptionDropdown(
            context,
            label: "国别",
            value: _countryCode,
            options: options.countries,
            onChanged: (value) => setState(() => _countryCode = value),
          ),
          _buildOptionDropdown(
            context,
            label: "语种",
            value: _languageCode,
            options: options.languages,
            onChanged: (value) => setState(() => _languageCode = value),
          ),
          _buildOptionDropdown(
            context,
            label: "出版起始年",
            value: _publishBegin,
            options: options.years,
            onChanged: (value) => setState(() => _publishBegin = value),
          ),
          _buildOptionDropdown(
            context,
            label: "出版结束年",
            value: _publishEnd,
            options: options.years,
            onChanged: (value) => setState(() => _publishEnd = value),
          ),
          CheckboxListTile(
            value: _onlyOnShelf,
            dense: true,
            visualDensity: VisualDensity.compact,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text("仅看在架", overflow: TextOverflow.ellipsis),
            onChanged: (value) => setState(() => _onlyOnShelf = value ?? false),
          ),
          OutlinedButton.icon(
            onPressed: _resetAdvancedSearch,
            icon: const Icon(Icons.clear),
            label: const Text("清除"),
          ).height(56),
        ],
      ),
      const SizedBox(height: 8),
      _buildAdvancedSearchInput(context),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.stretch);
  }

  Widget _buildOptionDropdown(
    BuildContext context, {
    required String label,
    required String value,
    required List<_SearchOption> options,
    int selectedMaxLines = 2,
    required ValueChanged<String> onChanged,
  }) {
    final selected = options.firstWhere(
      (option) => option.value == value,
      orElse: () => options.first,
    );
    return _OptionPickerField(
      label: label,
      value: selected.label,
      maxLines: selectedMaxLines,
      onTap: () async {
        final selectedValue = await showModalBottomSheet<String>(
          context: context,
          showDragHandle: true,
          builder: (context) => _OptionPickerSheet(
            title: label,
            selectedValue: value,
            options: options,
          ),
        );
        if (selectedValue != null) {
          onChanged(selectedValue);
        }
      },
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context,
    String label, {
    IconData? prefixIcon,
  }) => InputDecoration(
    labelText: label,
    isDense: true,
    prefixIcon: prefixIcon == null
        ? null
        : Icon(prefixIcon, color: Theme.of(context).colorScheme.primary),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  );
}

class _SearchBlock extends StatelessWidget {
  final Widget header;
  final Widget child;
  final bool collapsed;

  const _SearchBlock({
    required this.header,
    required this.child,
    this.collapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    return [
          header,
          if (!collapsed) ...[const SizedBox(height: 8), child],
        ]
        .toColumn(crossAxisAlignment: CrossAxisAlignment.stretch)
        .padding(horizontal: 10, vertical: 8)
        .card(elevation: 0);
  }
}

class _OptionPickerField extends StatelessWidget {
  final String label;
  final String value;
  final int maxLines;
  final VoidCallback onTap;

  const _OptionPickerField({
    required this.label,
    required this.value,
    this.maxLines = 2,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          value,
          maxLines: maxLines,
          overflow: TextOverflow.fade,
          softWrap: maxLines > 1,
        ),
      ),
    );
  }
}

class _OptionPickerSheet extends StatelessWidget {
  final String title;
  final String selectedValue;
  final List<_SearchOption> options;

  const _OptionPickerSheet({
    required this.title,
    required this.selectedValue,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  final selected = option.value == selectedValue;
                  return ListTile(
                    dense: true,
                    title: Text(option.label, softWrap: true),
                    trailing: selected ? const Icon(Icons.check) : null,
                    onTap: () => Navigator.of(context).pop(option.value),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchFields extends StatelessWidget {
  final double maxWidth;
  final int? columnCount;
  final List<Widget> children;

  const _SearchFields({
    required this.maxWidth,
    this.columnCount,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final columns =
        columnCount ??
        (maxWidth >= 760
            ? 3
            : maxWidth >= 520
            ? 2
            : 1);
    final fieldWidth = (maxWidth - 8 * (columns - 1)) / columns;
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children
          .map((child) => SizedBox(width: fieldWidth, child: child))
          .toList(),
    );
  }
}
