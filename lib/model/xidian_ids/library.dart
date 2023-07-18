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
