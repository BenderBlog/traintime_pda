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

BookInfo _$BookInfoFromJson(Map<String, dynamic> json) => BookInfo(
      docNumber: json['docNumber'] as String,
      bookName: json['bookName'] as String,
      author: json['author'] as String,
      publisherHouse: json['publisherHouse'] as String,
      price: json['price'] as String?,
      searchCode: json['searchCode'] as String?,
      base_code: json['base_code'] as String?,
      description: json['description'] as String?,
      bookItems: json['bookItems'] as String?,
      bookNumber: json['bookNumber'] as int,
      base: json['base'] as String,
      isbn: json['isbn'] as String?,
      publicationDate: json['publicationDate'] as String?,
    );

Map<String, dynamic> _$BookInfoToJson(BookInfo instance) => <String, dynamic>{
      'docNumber': instance.docNumber,
      'bookName': instance.bookName,
      'author': instance.author,
      'publisherHouse': instance.publisherHouse,
      'price': instance.price,
      'searchCode': instance.searchCode,
      'base_code': instance.base_code,
      'description': instance.description,
      'bookItems': instance.bookItems,
      'bookNumber': instance.bookNumber,
      'base': instance.base,
      'isbn': instance.isbn,
      'publicationDate': instance.publicationDate,
    };

BookLocation _$BookLocationFromJson(Map<String, dynamic> json) => BookLocation(
      barCode: json['barCode'] as String,
      recKey: json['recKey'] as String,
      libraryCode: json['libraryCode'] as String,
      branch_library_code: json['branch_library_code'] as String,
      bookAddressCode: json['bookAddressCode'] as String,
      branch_library_name: json['branch_library_name'] as String,
      bookAddress: json['bookAddress'] as String,
      state: json['state'] as String,
      bookstatus: json['bookstatus'] as String,
      borrowStatus: json['borrowStatus'] as int,
      noBorrowingReason: json['noBorrowingReason'] as String,
      canHold: json['canHold'] as String,
    );

Map<String, dynamic> _$BookLocationToJson(BookLocation instance) =>
    <String, dynamic>{
      'barCode': instance.barCode,
      'recKey': instance.recKey,
      'libraryCode': instance.libraryCode,
      'branch_library_code': instance.branch_library_code,
      'bookAddressCode': instance.bookAddressCode,
      'branch_library_name': instance.branch_library_name,
      'bookAddress': instance.bookAddress,
      'state': instance.state,
      'bookstatus': instance.bookstatus,
      'borrowStatus': instance.borrowStatus,
      'noBorrowingReason': instance.noBorrowingReason,
      'canHold': instance.canHold,
    };
