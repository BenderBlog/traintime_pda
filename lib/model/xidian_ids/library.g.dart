// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BorrowData _$BorrowDataFromJson(Map<String, dynamic> json) => BorrowData(
      title: json['title'] as String,
      author: json['author'] as String,
      publisher: json['publisher'] as String,
      isbn: json['isbn'] as String,
      itemLibCode: json['itemLibCode'] as String,
      lendDay: json['lendDay'] as int,
      loanDate: json['loanDate'] as String,
      renewDate: json['renewDate'] as String,
      normReturnDate: json['normReturnDate'] as String,
      loanType: json['loanType'] as String,
      barcode: json['barcode'] as String,
    );

Map<String, dynamic> _$BorrowDataToJson(BorrowData instance) =>
    <String, dynamic>{
      'title': instance.title,
      'author': instance.author,
      'publisher': instance.publisher,
      'isbn': instance.isbn,
      'itemLibCode': instance.itemLibCode,
      'lendDay': instance.lendDay,
      'loanDate': instance.loanDate,
      'renewDate': instance.renewDate,
      'normReturnDate': instance.normReturnDate,
      'loanType': instance.loanType,
      'barCode': instance.barcode,
    };

BookInfo _$BookInfoFromJson(Map<String, dynamic> json) => BookInfo(
      docNumber: json['docNumber'] as String,
      bookName: json['bookName'] as String,
      author: json['author'] as String?,
      publisherHouse: json['publisherHouse'] as String,
      price: json['price'] as String?,
      searchCode: json['searchCode'] as String?,
      base_code: json['base_code'] as String?,
      description: json['description'] as String?,
      bookItems: json['bookItems'] as String?,
      bookNumber: json['bookNumber'] as int?,
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
      recKey: json['recKey'] as String?,
      libraryCode: json['libraryCode'] as String,
      branch_library_code: json['branch_library_code'] as String,
      bookAddressCode: json['bookAddressCode'] as String,
      branch_library_name: json['branch_library_name'] as String,
      bookAddress: json['bookAddress'] as String,
      state: json['state'] as String,
      bookstatus: json['bookstatus'] as String,
      borrowStatus: json['borrowStatus'] as int,
      noBorrowingReason: json['noBorrowingReason'] as String?,
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
