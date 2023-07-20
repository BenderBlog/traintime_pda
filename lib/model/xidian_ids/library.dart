// ignore_for_file: non_constant_identifier_names

/*
The library class.
Copyright 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

import 'package:json_annotation/json_annotation.dart';

part 'library.g.dart';

@JsonSerializable()
class BorrowData {
  final String bookName;
  final String libraryCode;
  final String author;
  final String publishingHouse;
  final String isbn;
  final String docNumber;
  final int lendDay;
  final String loan_date;
  final String loan_time;
  final String searchCode;
  final String due_date;
  final String due_time;
  final String barNumber;

  const BorrowData({
    required this.bookName,
    required this.libraryCode,
    required this.author,
    required this.publishingHouse,
    required this.isbn,
    required this.docNumber,
    required this.lendDay,
    required this.loan_date,
    required this.loan_time,
    required this.searchCode,
    required this.due_date,
    required this.due_time,
    required this.barNumber,
  });

  DateTime get borrowTime => DateTime(
        int.parse(loan_date.substring(0, 4)),
        int.parse(loan_date.substring(4, 6)),
        int.parse(loan_date.substring(6, 8)),
        int.parse(loan_time.split(":").first),
        int.parse(loan_time.split(":").last),
      );

  DateTime get dueTime => DateTime(
        int.parse(due_date.substring(0, 4)),
        int.parse(due_date.substring(4, 6)),
        int.parse(due_date.substring(6, 8)),
        int.parse(due_time.split(":").first),
        int.parse(due_time.split(":").last),
        59,
      );

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
  final int bookNumber;
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
  final String recKey;
  final String libraryCode;
  final String branch_library_code;
  final String bookAddressCode;
  final String branch_library_name;
  final String bookAddress;
  final String state;
  final String bookstatus;
  final int borrowStatus;
  final String noBorrowingReason;
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
