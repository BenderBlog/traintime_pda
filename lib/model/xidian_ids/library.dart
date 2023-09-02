// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'library.g.dart';

@JsonSerializable()
class BorrowData {
  final String title;
  final String author;
  final String publisher;
  final String isbn;
  final String itemLibCode;
  final int lendDay;
  final String loanDate;
  final String renewDate;
  final String normReturnDate;
  final String loanType;
  final String barcode;

  const BorrowData({
    required this.title,
    required this.author,
    required this.publisher,
    required this.isbn,
    required this.itemLibCode,
    required this.lendDay,
    required this.loanDate,
    required this.renewDate,
    required this.normReturnDate,
    required this.loanType,
    required this.barcode,
  });

  factory BorrowData.fromJson(Map<String, dynamic> json) =>
      _$BorrowDataFromJson(json);

  Map<String, dynamic> toJson() => _$BorrowDataToJson(this);
}

@JsonSerializable()
class BookInfo {
  final String? author;
  final String? subject;
  final String? searchCode;
  final String? isbn;
  final String? description;
  final String bookName;
  final List<EBookItem>? eitems;
  final String? barCode;
  final String bookLibCode;
  final int docNumber;
  final String? publishYear;
  final String? series;
  final String? publisherHouse;
  final String? groupCode;
  final List<String>? callNos;
  final List<String>? barCodes;
  final List<BookLocation>? items;

  const BookInfo({
    this.author,
    this.subject,
    this.searchCode,
    this.isbn,
    this.description,
    required this.bookName,
    this.eitems,
    this.barCode,
    required this.bookLibCode,
    required this.docNumber,
    this.publishYear,
    this.series,
    this.publisherHouse,
    this.groupCode,
    this.callNos,
    required this.barCodes,
    this.items,
  });

  factory BookInfo.fromJson(Map<String, dynamic> json) =>
      _$BookInfoFromJson(json);

  Map<String, dynamic> toJson() => _$BookInfoToJson(this);
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
