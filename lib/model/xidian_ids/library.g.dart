// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BorrowData _$BorrowDataFromJson(Map<String, dynamic> json) => BorrowData(
      bookName: json['bookName'] as String,
      libraryCode: json['libraryCode'] as String,
      author: json['author'] as String,
      publishingHouse: json['publishingHouse'] as String,
      isbn: json['isbn'] as String,
      docNumber: json['docNumber'] as String,
      lendDay: json['lendDay'] as int,
      loan_date: json['loan_date'] as String,
      loan_time: json['loan_time'] as String,
      searchCode: json['searchCode'] as String,
      due_date: json['due_date'] as String,
      due_time: json['due_time'] as String,
      barNumber: json['barNumber'] as String,
    );

Map<String, dynamic> _$BorrowDataToJson(BorrowData instance) =>
    <String, dynamic>{
      'bookName': instance.bookName,
      'libraryCode': instance.libraryCode,
      'author': instance.author,
      'publishingHouse': instance.publishingHouse,
      'isbn': instance.isbn,
      'docNumber': instance.docNumber,
      'lendDay': instance.lendDay,
      'loan_date': instance.loan_date,
      'loan_time': instance.loan_time,
      'searchCode': instance.searchCode,
      'due_date': instance.due_date,
      'due_time': instance.due_time,
      'barNumber': instance.barNumber,
    };
