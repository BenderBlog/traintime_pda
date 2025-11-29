// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BorrowData _$BorrowDataFromJson(Map<String, dynamic> json) => BorrowData(
  lendDay: (json['lendDay'] as num).toInt(),
  locationId: (json['locationId'] as num).toInt(),
  loanId: (json['loanId'] as num).toInt(),
  renewTimes: (json['renewTimes'] as num).toInt(),
  recallTimes: (json['recallTimes'] as num).toInt(),
  loanDate: json['loanDate'] as String,
  renewDate: json['renewDate'] as String?,
  normReturnDate: json['normReturnDate'] as String,
  returnDate: json['returnDate'] as String?,
  loanType: json['loanType'] as String,
  locationName: json['locationName'] as String,
  itemLibCode: json['itemLibCode'] as String,
  itemLibName: json['itemLibName'] as String,
  loanDeskName: json['loanDeskName'] as String,
  title: json['title'] as String,
  author: json['author'] as String,
  publisher: json['publisher'] as String,
  isbn: json['isbn'] as String,
  isbn10: json['isbn10'] as String,
  isbn13: json['isbn13'] as String,
  publishYear: json['publishYear'] as String,
  titles: json['titles'] as String?,
  barcode: json['barcode'] as String,
);

Map<String, dynamic> _$BorrowDataToJson(BorrowData instance) =>
    <String, dynamic>{
      'lendDay': instance.lendDay,
      'locationId': instance.locationId,
      'loanId': instance.loanId,
      'renewTimes': instance.renewTimes,
      'recallTimes': instance.recallTimes,
      'loanDate': instance.loanDate,
      'renewDate': instance.renewDate,
      'normReturnDate': instance.normReturnDate,
      'returnDate': instance.returnDate,
      'loanType': instance.loanType,
      'locationName': instance.locationName,
      'itemLibCode': instance.itemLibCode,
      'itemLibName': instance.itemLibName,
      'loanDeskName': instance.loanDeskName,
      'title': instance.title,
      'author': instance.author,
      'publisher': instance.publisher,
      'isbn': instance.isbn,
      'isbn10': instance.isbn10,
      'isbn13': instance.isbn13,
      'publishYear': instance.publishYear,
      'titles': instance.titles,
      'barcode': instance.barcode,
    };

BookInfo _$BookInfoFromJson(Map<String, dynamic> json) => BookInfo(
  author: json['author'] as String?,
  subject: json['subject'] as String?,
  isbn: json['isbn'] as String?,
  description: json['description'] as String?,
  bookName: json['bookName'] as String,
  eitems: (json['eitems'] as List<dynamic>?)
      ?.map((e) => EBookItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  barCode: json['barCode'] as String?,
  bookLibCode: json['bookLibCode'] as String?,
  docNumber: (json['docNumber'] as num).toInt(),
  publishYear: json['publishYear'] as String?,
  series: json['series'] as String?,
  publisherHouse: json['publisherHouse'] as String?,
  groupCode: json['groupCode'] as String?,
  callNos: (json['callNos'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  searchCode: (json['searchCode'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  barCodes: (json['barCodes'] as List<dynamic>?)
      ?.map((e) => e as String?)
      .toList(),
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => BookLocation.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BookInfoToJson(BookInfo instance) => <String, dynamic>{
  'author': instance.author,
  'subject': instance.subject,
  'isbn': instance.isbn,
  'description': instance.description,
  'bookName': instance.bookName,
  'eitems': instance.eitems,
  'barCode': instance.barCode,
  'bookLibCode': instance.bookLibCode,
  'docNumber': instance.docNumber,
  'publishYear': instance.publishYear,
  'series': instance.series,
  'publisherHouse': instance.publisherHouse,
  'groupCode': instance.groupCode,
  'callNos': instance.callNos,
  'barCodes': instance.barCodes,
  'searchCode': instance.searchCode,
  'items': instance.items,
};

BookLocation _$BookLocationFromJson(Map<String, dynamic> json) => BookLocation(
  yearVol: json['yearVol'] as String?,
  locationName: json['locationName'] as String?,
  searchCode: json['searchCode'] as String,
  campus: json['campus'] as String?,
  inDate: json['inDate'] as String?,
  barCode: json['barCode'] as String?,
  itemId: (json['itemId'] as num).toInt(),
  circAttr: json['circAttr'] as String,
  locationId: json['locationId'] as String?,
  processType: json['processType'] as String,
  curLocationId: json['curLocationId'] as String,
  propNo: json['propNo'] as String?,
  borrowStatus: json['borrowStatus'] as String?,
  noBorrowMessages: json['noBorrowMessages'] as String?,
);

Map<String, dynamic> _$BookLocationToJson(BookLocation instance) =>
    <String, dynamic>{
      'yearVol': instance.yearVol,
      'locationName': instance.locationName,
      'searchCode': instance.searchCode,
      'campus': instance.campus,
      'inDate': instance.inDate,
      'barCode': instance.barCode,
      'itemId': instance.itemId,
      'circAttr': instance.circAttr,
      'locationId': instance.locationId,
      'processType': instance.processType,
      'curLocationId': instance.curLocationId,
      'propNo': instance.propNo,
      'borrowStatus': instance.borrowStatus,
      'noBorrowMessages': instance.noBorrowMessages,
    };

EBookItem _$EBookItemFromJson(Map<String, dynamic> json) => EBookItem(
  itemId: (json['itemId'] as num).toInt(),
  packageId: (json['packageId'] as num).toInt(),
  elecResourceUrl: json['elecResourceUrl'] as String?,
  packageName: json['packageName'] as String?,
  type: (json['type'] as num).toInt(),
  collectionId: (json['collectionId'] as num).toInt(),
  dbVender: json['dbVender'] as String?,
  url: json['url'] as String,
  collectionName: json['collectionName'] as String,
);

Map<String, dynamic> _$EBookItemToJson(EBookItem instance) => <String, dynamic>{
  'itemId': instance.itemId,
  'packageId': instance.packageId,
  'elecResourceUrl': instance.elecResourceUrl,
  'packageName': instance.packageName,
  'type': instance.type,
  'collectionId': instance.collectionId,
  'dbVender': instance.dbVender,
  'url': instance.url,
  'collectionName': instance.collectionName,
};
