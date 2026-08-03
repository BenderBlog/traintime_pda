// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BorrowData _$BorrowDataFromJson(Map<String, dynamic> json) => BorrowData(
  locationId: _intValue(json['locationId']),
  loanId: _intValue(json['loanId']),
  renewTimes: _intValue(json['renewTimes']),
  recallTimes: _intValue(json['recallTimes']),
  loanDate: _stringValue(json['loanDate']),
  renewDate: _nullableStringValue(json['renewDate']),
  normReturnDate: _stringValue(json['normReturnDate']),
  returnDate: _nullableStringValue(json['returnDate']),
  loanType: _stringValue(json['loanType']),
  locationName: _stringValue(json['locationName']),
  curLibCode: _stringValue(json['curLibCode']),
  curLibName: _stringValue(json['curLibName']),
  loanDeskName: _stringValue(json['loanDeskName']),
  title: _stringValue(json['title']),
  author: _stringValue(json['author']),
  publisher: _stringValue(json['publisher']),
  isbn: _stringValue(json['isbn']),
  isbn10: _stringValue(json['isbn10']),
  isbn13: _stringValue(json['isbn13']),
  publishYear: _stringValue(json['publishYear']),
  titles: _nullableStringValue(json['titles']),
  propNo: _stringValue(json['propNo']),
  recordId: _intValue(json['recordId']),
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$BorrowDataToJson(BorrowData instance) =>
    <String, dynamic>{
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
      'curLibCode': instance.curLibCode,
      'curLibName': instance.curLibName,
      'loanDeskName': instance.loanDeskName,
      'title': instance.title,
      'author': instance.author,
      'publisher': instance.publisher,
      'isbn': instance.isbn,
      'isbn10': instance.isbn10,
      'isbn13': instance.isbn13,
      'publishYear': instance.publishYear,
      'titles': instance.titles,
      'propNo': instance.propNo,
      'recordId': instance.recordId,
      'imageUrl': instance.imageUrl,
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
  availableCount: (json['availableCount'] as num?)?.toInt(),
  storageCount: (json['storageCount'] as num?)?.toInt(),
  imageUrl: json['imageUrl'] as String?,
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
  'availableCount': instance.availableCount,
  'storageCount': instance.storageCount,
  'imageUrl': instance.imageUrl,
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
