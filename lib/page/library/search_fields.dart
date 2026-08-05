// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/library_controller.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/page/library/search_book_constant.dart';

typedef _SearchOption = LibrarySearchOption;

class BookSearchQuery {
  final bool isAdvanced;
  final String keyword;
  final String searchField;
  final String matchMode;
  final String? documentType;
  final String? resourceType;
  final int? campusId;
  final int? locationId;
  final String? countryCode;
  final String? languageCode;
  final bool? onlyOnShelf;
  final String publishBegin;
  final String publishEnd;

  const BookSearchQuery._({
    required this.isAdvanced,
    required this.keyword,
    required this.searchField,
    this.matchMode = "2",
    this.documentType,
    this.resourceType,
    this.campusId,
    this.locationId,
    this.countryCode,
    this.languageCode,
    this.onlyOnShelf,
    this.publishBegin = "",
    this.publishEnd = "",
  });

  const BookSearchQuery.normal({
    required String keyword,
    required String searchField,
  }) : this._(isAdvanced: false, keyword: keyword, searchField: searchField);

  const BookSearchQuery.advanced({
    required String keyword,
    required String searchField,
    required String matchMode,
    String? documentType,
    String? resourceType,
    int? campusId,
    int? locationId,
    String? countryCode,
    String? languageCode,
    bool? onlyOnShelf,
    String publishBegin = "",
    String publishEnd = "",
  }) : this._(
         isAdvanced: true,
         keyword: keyword,
         searchField: searchField,
         matchMode: matchMode,
         documentType: documentType,
         resourceType: resourceType,
         campusId: campusId,
         locationId: locationId,
         countryCode: countryCode,
         languageCode: languageCode,
         onlyOnShelf: onlyOnShelf,
         publishBegin: publishBegin,
         publishEnd: publishEnd,
       );
}

class SearchFields extends StatefulWidget {
  final ValueChanged<BookSearchQuery> onSearch;

  const SearchFields({super.key, required this.onSearch});

  @override
  State<SearchFields> createState() => _SearchFieldsState();
}

class _SearchFieldsState extends State<SearchFields> {
  final OverlayPortalController _overlayController = OverlayPortalController();
  final LayerLink _layerLink = LayerLink();

  String _searchField = "keyWord";
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
  bool _showAdvancedOptions = false;

  late final Future<LibrarySearchFilterOptions> _filterOptionsFuture =
      LibraryController.i.session.searchFilterOptions();
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LibrarySearchFilterOptions>(
          future: _filterOptionsFuture,
          builder: (context, snapshot) {
            final options =
                snapshot.data ?? LibrarySearchFilterOptions.fallback();
            return LayoutBuilder(
              builder: (context, constraints) => OverlayPortal(
                controller: _overlayController,
                overlayChildBuilder: (context) => CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  targetAnchor: Alignment.bottomLeft,
                  followerAnchor: Alignment.topLeft,
                  offset: const Offset(0, -1),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: constraints.maxWidth,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: 8,
                            right: 8,
                            bottom: 0,
                            height: 8,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.shadow
                                        .withValues(alpha: 0.18),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Material(
                            elevation: 0,
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerLow,
                            surfaceTintColor: Colors.transparent,
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(12),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.sizeOf(context).height * 0.7,
                              ),
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                child: LayoutBuilder(
                                  builder: (context, overlayConstraints) =>
                                      _buildAdvancedSearchFields(
                                        context,
                                        overlayConstraints.maxWidth,
                                        options,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                child: CompositedTransformTarget(
                  link: _layerLink,
                  child: _SearchBlock(
                    expanded: _showAdvancedOptions,
                    child: LayoutBuilder(
                      builder: (context, searchConstraints) =>
                          [
                            _buildBaseSearchFields(
                              context,
                              searchConstraints.maxWidth,
                              options,
                            ),
                            const SizedBox(height: 8),
                            _buildSearchActions(context),
                          ].toColumn(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                          ),
                    ),
                  ),
                ),
              ),
            );
          },
        )
        .padding(horizontal: 8, vertical: 4)
        .constrained(maxWidth: searchPanelMaxWidth)
        .center();
  }

  void _submitSearch() {
    FocusScope.of(context).unfocus();
    final keyword = _textController.text.trim();
    if (_hasAdvancedFilters) {
      widget.onSearch(
        BookSearchQuery.advanced(
          keyword: keyword,
          searchField: _searchField,
          matchMode: _advancedMatchMode,
          documentType: _emptyToNull(_documentType),
          resourceType: _emptyToNull(_resourceType),
          campusId: _intFilter(_campusId),
          locationId: _intFilter(_locationId),
          countryCode: _emptyToNull(_countryCode),
          languageCode: _emptyToNull(_languageCode),
          onlyOnShelf: _onlyOnShelf ? true : null,
          publishBegin: _publishBegin,
          publishEnd: _publishEnd,
        ),
      );
      return;
    }
    widget.onSearch(
      BookSearchQuery.normal(keyword: keyword, searchField: _searchField),
    );
  }

  bool get _hasAdvancedFilters =>
      _advancedMatchMode != "2" ||
      _documentType.isNotEmpty ||
      _resourceType.isNotEmpty ||
      _campusId.isNotEmpty ||
      _locationId.isNotEmpty ||
      _countryCode.isNotEmpty ||
      _languageCode.isNotEmpty ||
      _publishBegin.isNotEmpty ||
      _publishEnd.isNotEmpty ||
      _onlyOnShelf;

  void _resetAdvancedSearch() {
    setState(() {
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

  void _toggleAdvancedOptions() {
    setState(() => _showAdvancedOptions = !_showAdvancedOptions);
    if (_showAdvancedOptions) {
      _overlayController.show();
    } else {
      _overlayController.hide();
    }
  }

  String? _emptyToNull(String value) => value.isEmpty ? null : value;

  int? _intFilter(String value) => value.isEmpty ? null : int.tryParse(value);

  List<_SearchOption> _matchModeOptions(BuildContext context) => [
    LibrarySearchOption(
      "1",
      FlutterI18n.translate(context, "library.match_exact"),
      "精确",
    ),
    LibrarySearchOption(
      "2",
      FlutterI18n.translate(context, "library.match_fuzzy"),
      "模糊",
    ),
    LibrarySearchOption(
      "3",
      FlutterI18n.translate(context, "library.match_prefix"),
      "前方",
    ),
  ];

  Widget _buildBaseSearchFields(
    BuildContext context,
    double maxWidth,
    LibrarySearchFilterOptions options,
  ) {
    return Row(
      children: [
        SizedBox(
          width: maxWidth < 430 ? 128 : 152,
          child: _buildSearchFieldDropdown(
            context: context,
            value: _searchField,
            options: options.searchFields,
            selectedMaxLines: 1,
            onChanged: (value) => setState(() => _searchField = value),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: _textController,
            decoration: _inputDecoration(
              context,
              FlutterI18n.translate(context, "library.search_here"),
              prefixIcon: Icons.search,
            ),
            onFieldSubmitted: (_) => _submitSearch(),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedSearchFields(
    BuildContext context,
    double maxWidth,
    LibrarySearchFilterOptions options,
  ) {
    return [
      _SearchFieldGrid(
        maxWidth: maxWidth,
        columnCount: maxWidth >= 520 ? 2 : 1,
        children: [
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
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: CheckboxListTile(
                    value: _onlyOnShelf,
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text("仅看在架", overflow: TextOverflow.ellipsis),
                    onChanged: (value) =>
                        setState(() => _onlyOnShelf = value ?? false),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _resetAdvancedSearch,
                  icon: const Icon(Icons.clear),
                  label: const Text("清除"),
                ),
              ),
            ],
          ),
        ],
      ),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.stretch);
  }

  Widget _buildSearchActions(BuildContext context) {
    return Row(
      children: [
        TextButton.icon(
          onPressed: _toggleAdvancedOptions,
          icon: Icon(
            _showAdvancedOptions
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
          ),
          label: Text(_showAdvancedOptions ? "收起搜索选项" : "更多搜索选项"),
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed: _submitSearch,
          icon: const Icon(Icons.manage_search),
          label: Text(FlutterI18n.translate(context, "library.search")),
        ),
      ],
    );
  }

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
        if (selectedValue != null) onChanged(selectedValue);
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

class _SearchFieldGrid extends StatelessWidget {
  final double maxWidth;
  final int? columnCount;
  final List<Widget> children;

  const _SearchFieldGrid({
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

class _SearchBlock extends StatelessWidget {
  final Widget child;
  final bool expanded;

  const _SearchBlock({required this.child, required this.expanded});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: expanded
            ? const BorderRadius.vertical(top: Radius.circular(12))
            : BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: child,
      ),
    );
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
