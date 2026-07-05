// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'library.g.dart';

@JsonSerializable()
class BorrowData {
  final int lendDay;
  final int locationId;
  final int loanId;
  final int renewTimes;
  final int recallTimes;
  final String loanDate;
  final String? renewDate;
  final String normReturnDate;
  final String? returnDate;
  final String loanType;
  final String locationName;
  final String itemLibCode;
  final String itemLibName;
  final String loanDeskName;
  final String title;
  final String author;
  final String publisher;
  final String isbn;
  final String isbn10;
  final String isbn13;
  final String publishYear;
  final String? titles;
  final String barcode;
  String? imageUrl;

  BorrowData({
    required this.lendDay,
    required this.locationId,
    required this.loanId,
    required this.renewTimes,
    required this.recallTimes,
    required this.loanDate,
    required this.renewDate,
    required this.normReturnDate,
    required this.returnDate,
    required this.loanType,
    required this.locationName,
    required this.itemLibCode,
    required this.itemLibName,
    required this.loanDeskName,
    required this.title,
    required this.author,
    required this.publisher,
    required this.isbn,
    required this.isbn10,
    required this.isbn13,
    required this.publishYear,
    required this.titles,
    required this.barcode,
    this.imageUrl,
  });

  DateTime get loanDateTime => DateTime.parse(loanDate.replaceAll('/', '-'));

  DateTime get normReturnDateTime =>
      DateTime.parse(normReturnDate.replaceAll('/', '-'));

  factory BorrowData.fromJson(Map<String, dynamic> json) =>
      _$BorrowDataFromJson(json);

  factory BorrowData.fromOpacJson(Map<String, dynamic> json) {
    final normReturnDate = _stringValue(json['normReturnDate']);
    final dueDate = _parseLibraryDate(normReturnDate);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    return BorrowData(
      lendDay: dueDate.difference(todayDate).inDays,
      locationId: _intValue(json['locationId']),
      loanId: _intValue(json['loanId']),
      renewTimes: _intValue(json['renewTimes']),
      recallTimes: _intValue(json['recallTimes']),
      loanDate: _stringValue(json['loanDate']),
      renewDate: _nullableStringValue(json['renewDate']),
      normReturnDate: normReturnDate,
      returnDate: _nullableStringValue(json['returnDate']),
      loanType: _stringValue(json['loanType']),
      locationName: _stringValue(json['locationName']),
      itemLibCode: _stringValue(json['curLibCode'] ?? json['itemLibCode']),
      itemLibName: _stringValue(json['curLibName'] ?? json['itemLibName']),
      loanDeskName: _stringValue(json['loanDeskName']),
      title: _stringValue(json['title']),
      author: _stringValue(json['author']),
      publisher: _stringValue(json['publisher']),
      isbn: _stringValue(json['isbn']),
      isbn10: _stringValue(json['isbn10']),
      isbn13: _stringValue(json['isbn13']),
      publishYear: _stringValue(json['publishYear']),
      titles: _nullableStringValue(json['titles']),
      barcode: _stringValue(json['barcode'] ?? json['propNo']),
    );
  }

  Map<String, dynamic> toJson() => _$BorrowDataToJson(this);
}

int _intValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

String _stringValue(Object? value) => value?.toString() ?? "";

String? _nullableStringValue(Object? value) => value?.toString();

DateTime _parseLibraryDate(String value) {
  if (value.isEmpty) {
    return DateTime.now();
  }
  return DateTime.parse(value.replaceAll('/', '-').split(' ').first);
}

@JsonSerializable()
class BookInfo {
  final String? author;
  final String? subject;
  final String? isbn;
  final String? description;
  final String bookName;
  final List<EBookItem>? eitems;
  final String? barCode;
  final String? bookLibCode;
  final int docNumber;
  final String? publishYear;
  final String? series;
  final String? publisherHouse;
  final String? groupCode;
  final List<String>? callNos;
  final List<String?>? barCodes;
  final List<String>? searchCode;
  final List<BookLocation>? items;
  final int? availableCount;
  final int? storageCount;
  String? imageUrl;

  BookInfo({
    this.author,
    this.subject,
    this.isbn,
    this.description,
    required this.bookName,
    this.eitems,
    this.barCode,
    this.bookLibCode,
    required this.docNumber,
    this.publishYear,
    this.series,
    this.publisherHouse,
    this.groupCode,
    this.callNos,
    this.searchCode,
    required this.barCodes,
    this.items,
    this.availableCount,
    this.storageCount,
    this.imageUrl,
  });

  factory BookInfo.fromJson(Map<String, dynamic> json) =>
      _$BookInfoFromJson(json);

  factory BookInfo.fromOpacJson(Map<String, dynamic> json) {
    final callNos = _stringList(json['callNo']);
    final barCodes = _nullableStringList(
      json['barCodes'] ?? json['barcode'] ?? json['propNo'],
    );
    return BookInfo(
      author: _nullableStringValue(json['author']),
      subject: _nullableStringValue(json['subjectWord']),
      isbn: _nullableStringValue(json['isbn']),
      description: _nullableStringValue(json['adstract'] ?? json['ddAbstract']),
      bookName: _stringValue(json['title']),
      barCode: _nullableStringValue(json['barcode'] ?? json['propNo']),
      docNumber: _intValue(json['recordId']),
      publishYear: _nullableStringValue(json['publishYear'] ?? json['year']),
      publisherHouse: _nullableStringValue(json['publisher']),
      groupCode: _nullableStringValue(json['groupCode']),
      callNos: callNos,
      searchCode: callNos,
      barCodes: barCodes,
      availableCount: _nullableIntValue(
        json['onShelfCountI'] ?? json['canBrrowCountI'] ?? json['onShelfNum'],
      ),
      storageCount: _nullableIntValue(
        json['groupPhysicalCount'] ?? json['physicalCount'],
      ),
    );
  }

  Map<String, dynamic> toJson() => _$BookInfoToJson(this);

  int? get canBeBorrowed {
    if (availableCount != null) {
      return availableCount;
    }
    if (items == null) {
      return null;
    }
    int toReturn = 0;
    for (var i in items!) {
      if (i.processType == "在架") toReturn += 1;
    }
    return toReturn;
  }

  int? get totalStorage {
    if (storageCount != null) {
      return storageCount;
    }
    return items?.length;
  }

  bool get hasBarCodes {
    if (barCodes == null || barCodes!.isEmpty) {
      return false;
    }
    return barCodes!.any((e) => e != null && e.isNotEmpty);
  }

  String get searchCodeStr {
    if (searchCode == null || searchCode!.isEmpty) {
      return "未提供";
    }
    return searchCode!.first;
  }

  String get barCodesStr {
    if (barCodes == null || barCodes!.isEmpty) {
      return "未提供";
    }
    for (final code in barCodes!) {
      if (code != null && code.isNotEmpty) {
        return code;
      }
    }
    return "未提供";
  }
}

int? _nullableIntValue(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

List<String>? _stringList(Object? value) {
  if (value == null) return null;
  if (value is List) {
    return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }
  final text = value.toString();
  return text.isEmpty ? null : [text];
}

List<String?>? _nullableStringList(Object? value) {
  if (value == null) return null;
  if (value is List) {
    return value.map((e) => e?.toString()).toList();
  }
  final text = value.toString();
  return text.isEmpty ? null : [text];
}

@JsonSerializable()
class BookLocation {
  final String? yearVol;
  final String? locationName;
  final String searchCode;
  final String? campus;
  final String? inDate;
  final String? barCode;
  final int itemId;
  final String circAttr;
  final String? locationId;
  final String processType;
  final String curLocationId;
  final String? propNo;
  final String? borrowStatus;
  final String? noBorrowMessages;

  const BookLocation({
    this.yearVol,
    this.locationName,
    required this.searchCode,
    this.campus,
    this.inDate,
    this.barCode,
    required this.itemId,
    required this.circAttr,
    this.locationId,
    required this.processType,
    required this.curLocationId,
    required this.propNo,
    required this.borrowStatus,
    this.noBorrowMessages,
  });

  factory BookLocation.fromJson(Map<String, dynamic> json) =>
      _$BookLocationFromJson(json);

  factory BookLocation.fromOpacJson(Map<String, dynamic> json) {
    final locationName = _stringValue(
      json['realLocationName'] ?? json['locationName'],
    );
    final shelfName = _stringValue(json['urlName']);
    final displayLocation = shelfName.isEmpty
        ? locationName
        : "$locationName $shelfName";

    return BookLocation(
      yearVol: _nullableStringValue(json['vol'] ?? json['yearVol']),
      locationName: displayLocation.isEmpty ? null : displayLocation,
      searchCode: _stringValue(json['callNo']),
      campus: _nullableStringValue(json['campus']),
      inDate: _nullableStringValue(json['inDate']),
      barCode: _nullableStringValue(json['barcode'] ?? json['propNo']),
      itemId: _intValue(json['itemId']),
      circAttr: _stringValue(json['circAttr']),
      locationId: _nullableStringValue(json['locationId']),
      processType: _stringValue(json['processType']),
      curLocationId: _stringValue(json['curLocationId']),
      propNo: _nullableStringValue(json['propNo']),
      borrowStatus: _nullableStringValue(json['borrowStatus']),
      noBorrowMessages: _nullableStringValue(json['noBorrowMessages']),
    );
  }

  Map<String, dynamic> toJson() => _$BookLocationToJson(this);
}

@JsonSerializable()
class EBookItem {
  final int itemId;
  final int packageId;
  final String? elecResourceUrl;
  final String? packageName;
  final int type;
  final int collectionId;
  final String? dbVender;
  final String url;
  final String collectionName;

  const EBookItem({
    required this.itemId,
    required this.packageId,
    this.elecResourceUrl,
    this.packageName,
    required this.type,
    required this.collectionId,
    this.dbVender,
    required this.url,
    required this.collectionName,
  });

  factory EBookItem.fromJson(Map<String, dynamic> json) =>
      _$EBookItemFromJson(json);

  Map<String, dynamic> toJson() => _$EBookItemToJson(this);
}
