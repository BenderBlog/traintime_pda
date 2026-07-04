// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/library_controller.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/page/library/book_detail_card.dart';
import 'package:watermeter/page/library/borrow_confirm_dialog.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/xidian_ids/library_session.dart';

class ScanBorrowWindow extends StatefulWidget {
  final BookInfo? expectedBook;

  const ScanBorrowWindow({super.key, this.expectedBook});

  @override
  State<ScanBorrowWindow> createState() => _ScanBorrowWindowState();
}

class _ScanBorrowWindowState extends State<ScanBorrowWindow> {
  final QRCodeDartScanController _scannerController =
      QRCodeDartScanController();
  final LibrarySession _session = LibrarySession();

  bool _flashOn = false;
  bool _handlingScan = false;
  bool _loadingBook = false;
  bool _submitting = false;
  String? _barcode;
  BookInfo? _bookInfo;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleCapture(Result result) async {
    if (_handlingScan) return;

    final barcode = result.text.trim();
    if (barcode.isEmpty) return;

    _handlingScan = true;
    await _scannerController.stopScan();
    if (!mounted) return;

    setState(() {
      _barcode = barcode;
      _bookInfo = null;
      _loadingBook = true;
    });

    try {
      final book = await _session.getScannedBorrowBook(barcode);
      if (!mounted) return;
      setState(() {
        _bookInfo = book;
      });
      showToast(context: context, msg: _borrowStatusFor(context, book).message);
    } catch (e, s) {
      log.handle(e, s, "[ScanBorrowWindow][_handleCapture] Failed.");
      if (!mounted) return;
      showToast(context: context, msg: _exceptionMsg(e));
      await _resumeScan();
    } finally {
      if (mounted) {
        setState(() {
          _loadingBook = false;
        });
      }
    }
  }

  String _exceptionMsg(Object e) {
    if (e is LibraryOperationException && e.i18nKey != null) {
      return FlutterI18n.translate(context, e.i18nKey!);
    }
    if (e is NotFetchLibraryException && e.i18nKey != null) {
      return FlutterI18n.translate(context, e.i18nKey!);
    }
    return e.toString();
  }

  Future<void> _resumeScan() async {
    setState(() {
      _barcode = null;
      _bookInfo = null;
      _handlingScan = false;
      _loadingBook = false;
      _submitting = false;
    });
    await _scannerController.startScan();
  }

  BookLocation? _findLocationByBarcode(BookInfo bookInfo, String barcode) {
    final items = bookInfo.items;
    final normalizedBarcode = barcode.trim();
    if (items == null || normalizedBarcode.isEmpty) return null;

    for (final item in items) {
      if (item.barCode?.trim() == normalizedBarcode) {
        return item;
      }
    }
    return null;
  }

  BookLocation? _firstBorrowableLocation(BookInfo bookInfo) {
    final items = bookInfo.items;
    if (items == null) return null;

    for (final item in items) {
      if (_isBorrowable(item)) {
        return item;
      }
    }
    return null;
  }

  bool _isBorrowable(BookLocation location) =>
      location.processType == "在架" && (location.barCode?.isNotEmpty ?? false);

  bool _matchesExpectedBook(BookInfo bookInfo) {
    final expectedBook = widget.expectedBook;
    if (expectedBook == null) return true;
    if (expectedBook.docNumber == bookInfo.docNumber) return true;

    final expectedIsbn = expectedBook.isbn?.trim();
    final scannedIsbn = bookInfo.isbn?.trim();
    if (expectedIsbn != null &&
        expectedIsbn.isNotEmpty &&
        scannedIsbn != null &&
        scannedIsbn.isNotEmpty &&
        expectedIsbn == scannedIsbn &&
        expectedBook.bookName == bookInfo.bookName) {
      return true;
    }

    return false;
  }

  String _firstSearchCode(BookInfo bookInfo) {
    final searchCodes = bookInfo.searchCode;
    if (searchCodes == null) return "";

    for (final searchCode in searchCodes) {
      if (searchCode.isNotEmpty) return searchCode;
    }
    return "";
  }

  String _locationLabel(BuildContext context, BookLocation? location) =>
      location?.locationName ??
      FlutterI18n.translate(context, "library.not_provided");

  String _unavailableReason(BookLocation location) {
    final processType = location.processType.trim();
    if (processType.isNotEmpty && processType != "在架") {
      return processType;
    }

    final noBorrowMessages = location.noBorrowMessages?.trim();
    if (noBorrowMessages != null && noBorrowMessages.isNotEmpty) {
      return noBorrowMessages;
    }

    final borrowStatus = location.borrowStatus?.trim();
    if (borrowStatus != null && borrowStatus.isNotEmpty) {
      return borrowStatus;
    }

    return location.circAttr;
  }

  _ScanBorrowStatus _borrowStatusFor(BuildContext context, BookInfo bookInfo) {
    final expectedBook = widget.expectedBook;
    if (expectedBook != null && !_matchesExpectedBook(bookInfo)) {
      return _ScanBorrowStatus(
        canBorrow: false,
        location: null,
        message: FlutterI18n.translate(
          context,
          "library.scan_expected_book_mismatch",
          translationParams: {
            "expected": expectedBook.bookName,
            "actual": bookInfo.bookName,
          },
        ),
      );
    }

    final barcode = _barcode?.trim() ?? "";
    final scannedLocation = _findLocationByBarcode(bookInfo, barcode);

    if (scannedLocation != null) {
      if (_isBorrowable(scannedLocation)) {
        return _ScanBorrowStatus(
          canBorrow: true,
          location: scannedLocation,
          message: FlutterI18n.translate(
            context,
            "library.scan_borrow_available",
            translationParams: {
              "location": _locationLabel(context, scannedLocation),
            },
          ),
        );
      }

      return _ScanBorrowStatus(
        canBorrow: false,
        location: scannedLocation,
        message: FlutterI18n.translate(
          context,
          "library.scan_borrow_unavailable",
          translationParams: {"status": _unavailableReason(scannedLocation)},
        ),
      );
    }

    final borrowableLocation = _firstBorrowableLocation(bookInfo);
    if (borrowableLocation != null) {
      return _ScanBorrowStatus(
        canBorrow: true,
        location: null,
        message: FlutterI18n.translate(
          context,
          "library.scan_borrow_fallback",
        ),
      );
    }

    return _ScanBorrowStatus(
      canBorrow: false,
      location: null,
      message: FlutterI18n.translate(context, "library.scan_borrow_no_copy"),
    );
  }

  Future<void> _submitBorrow() async {
    final barcode = _barcode;
    final bookInfo = _bookInfo;
    if (barcode == null || bookInfo == null || _submitting) return;

    final borrowStatus = _borrowStatusFor(context, bookInfo);
    if (!borrowStatus.canBorrow) {
      showToast(context: context, msg: borrowStatus.message);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => BorrowConfirmDialog(
        coverUrl: bookInfo.imageUrl,
        bookName: bookInfo.bookName,
        locationName: borrowStatus.location?.locationName,
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _submitting = true;
    });
    showToast(
      context: context,
      msg: FlutterI18n.translate(context, "library.borrow_submitting_notice"),
    );

    try {
      final message = await _session.borrowBook(
        barcode: barcode,
        bookInfo: bookInfo,
        searchCode:
            borrowStatus.location?.searchCode ?? _firstSearchCode(bookInfo),
      );
      if (!mounted) return;
      showToast(context: context, msg: message);
      await LibraryController.i.reloadBorrowList();
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e, s) {
      log.handle(e, s, "[ScanBorrowWindow][_submitBorrow] Failed.");
      if (!mounted) return;
      showToast(context: context, msg: _exceptionMsg(e));
      setState(() {
        _submitting = false;
      });
    }
  }

  Future<void> _toggleFlash() async {
    await _scannerController.toggleFlash();
    if (!mounted) return;
    setState(() {
      _flashOn = _scannerController.isFlashOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "library.scan_borrow")),
        actions: [
          IconButton(
            icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleFlash,
            tooltip: FlutterI18n.translate(context, "library.toggle_flash"),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: QRCodeDartScanView(
              controller: _scannerController,
              resolutionPreset: QRCodeDartScanResolutionPreset.veryHigh,
              imageDecodeOrientation: ImageDecodeOrientation.portrait,
              intervalScan: const Duration(milliseconds: 400),
              onCapture: _handleCapture,
              child: const ColoredBox(color: Colors.black),
            ),
          ),
          Positioned.fill(child: IgnorePointer(child: _ScanOverlay())),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: SafeArea(child: _buildBottomPanel(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_loadingBook) {
      return Card(
        child: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(FlutterI18n.translate(context, "library.loading_scanned_book")),
        ].toRow().padding(all: 16),
      );
    }

    final bookInfo = _bookInfo;
    if (bookInfo == null) {
      return Card(
        color: colorScheme.surface.withValues(alpha: 0.94),
        child: [
          Icon(MingCuteIcons.mgc_barcode_line, color: colorScheme.primary),
          const SizedBox(width: 12),
          [
            Text(
              widget.expectedBook == null
                  ? FlutterI18n.translate(context, "library.scan_book_barcode")
                  : FlutterI18n.translate(
                      context,
                      "library.scan_expected_book_barcode",
                      translationParams: {
                        "book": widget.expectedBook!.bookName,
                      },
                    ),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              FlutterI18n.translate(context, "library.scan_barcode_help"),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ].toColumn(crossAxisAlignment: CrossAxisAlignment.stretch).expanded(),
        ].toRow().padding(all: 16),
      );
    }

    final borrowStatus = _borrowStatusFor(context, bookInfo);
    return Card(
      color: colorScheme.surface.withValues(alpha: 0.97),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.64,
        child:
            [
                  Text(
                    FlutterI18n.translate(context, "library.scan_book_found"),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  _buildBorrowStatusBanner(context, borrowStatus),
                  const SizedBox(height: 12),
                  BookDetailCard(
                    toUse: bookInfo,
                    showBorrowAction: false,
                  ).expanded(),
                  const SizedBox(height: 12),
                  [
                    OutlinedButton(
                      onPressed: _submitting ? null : _resumeScan,
                      child: Text(
                        FlutterI18n.translate(context, "library.rescan"),
                      ),
                    ).expanded(),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _submitting || !borrowStatus.canBorrow
                          ? null
                          : _submitBorrow,
                      child: _submitting
                          ? [
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                FlutterI18n.translate(
                                  context,
                                  "library.borrowing_book",
                                ),
                              ),
                            ].toRow(mainAxisAlignment: MainAxisAlignment.center)
                          : Text(
                              FlutterI18n.translate(
                                context,
                                "library.confirm_borrow",
                              ),
                            ),
                    ).expanded(),
                  ].toRow(),
                ]
                .toColumn(crossAxisAlignment: CrossAxisAlignment.stretch)
                .padding(all: 16),
      ),
    );
  }

  Widget _buildBorrowStatusBanner(
    BuildContext context,
    _ScanBorrowStatus borrowStatus,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = borrowStatus.canBorrow
        ? Colors.green.shade900
        : colorScheme.onErrorContainer;
    final background = borrowStatus.canBorrow
        ? Colors.green.shade100
        : colorScheme.errorContainer;
    final barcode = _barcode ?? "";

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: [
        Icon(
          borrowStatus.canBorrow ? Icons.check_circle : Icons.info,
          color: foreground,
        ),
        const SizedBox(width: 10),
        [
          Text(
            borrowStatus.message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (barcode.isNotEmpty)
            Text(
              FlutterI18n.translate(
                context,
                "library.scanned_barcode",
                translationParams: {"barcode": barcode},
              ),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: foreground),
            ),
        ].toColumn(crossAxisAlignment: CrossAxisAlignment.stretch).expanded(),
      ].toRow(),
    );
  }
}

class _ScanBorrowStatus {
  final bool canBorrow;
  final BookLocation? location;
  final String message;

  const _ScanBorrowStatus({
    required this.canBorrow,
    required this.location,
    required this.message,
  });
}

class _ScanOverlay extends StatefulWidget {
  @override
  State<_ScanOverlay> createState() => _ScanOverlayState();
}

class _ScanOverlayState extends State<_ScanOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
            ),
          ),
        ),
        Center(
          child: SizedBox(
            width: (MediaQuery.sizeOf(context).width - 48)
                .clamp(280.0, 420.0)
                .toDouble(),
            height: 170,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) => Align(
                      alignment: Alignment(
                        0,
                        -0.92 + _animationController.value * 1.84,
                      ),
                      child: child,
                    ),
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary.withValues(alpha: 0.0),
                            colorScheme.primary.withValues(alpha: 0.95),
                            colorScheme.primary.withValues(alpha: 0.0),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.55),
                            blurRadius: 14,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: colorScheme.primary, width: 3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
