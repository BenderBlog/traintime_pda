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
  final String docNumber;
  final String bookName;
  final String? author;
  final String publisherHouse;
  final String? price;
  final String? searchCode;
  final String? base_code;
  final String? description;
  final String? bookItems;
  final int? bookNumber;
  final String base;
  final String? isbn;
  final String? publicationDate;

  const BookInfo({
    required this.docNumber,
    required this.bookName,
    required this.author,
    required this.publisherHouse,
    required this.price,
    required this.searchCode,
    required this.base_code,
    required this.description,
    required this.bookItems,
    required this.bookNumber,
    required this.base,
    required this.isbn,
    required this.publicationDate,
  });

  factory BookInfo.fromJson(Map<String, dynamic> json) =>
      _$BookInfoFromJson(json);

  Map<String, dynamic> toJson() => _$BookInfoToJson(this);
}

@JsonSerializable()
class BookLocation {
  final String barCode;
  final String? recKey;
  final String libraryCode;
  final String branch_library_code;
  final String bookAddressCode;
  final String branch_library_name;
  final String bookAddress;
  final String state;
  final String bookstatus;
  final int borrowStatus;
  final String? noBorrowingReason;
  final String canHold;

  const BookLocation({
    required this.barCode,
    required this.recKey,
    required this.libraryCode,
    required this.branch_library_code,
    required this.bookAddressCode,
    required this.branch_library_name,
    required this.bookAddress,
    required this.state,
    required this.bookstatus,
    required this.borrowStatus,
    required this.noBorrowingReason,
    required this.canHold,
  });

  factory BookLocation.fromJson(Map<String, dynamic> json) =>
      _$BookLocationFromJson(json);

  Map<String, dynamic> toJson() => _$BookLocationToJson(this);
}
