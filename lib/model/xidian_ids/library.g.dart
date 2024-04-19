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
      renewDate: json['renewDate'] as String?,
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
      docNumber: json['docNumber'] as int,
      publishYear: json['publishYear'] as String?,
      series: json['series'] as String?,
      publisherHouse: json['publisherHouse'] as String?,
      groupCode: json['groupCode'] as String?,
      callNos:
          (json['callNos'] as List<dynamic>?)?.map((e) => e as String).toList(),
      barCodes: (json['barCodes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
          // 此处在网络不好的时候会出现e为null的情况，此时会在控制台扔出报错，后续需要充分测试
      searchCode: (json['searchCode'] as List<dynamic>?)
          ?.map((e)=>e as String)
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
      itemId: json['itemId'] as int,
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
      itemId: json['itemId'] as int,
      packageId: json['packageId'] as int,
      elecResourceUrl: json['elecResourceUrl'] as String?,
      packageName: json['packageName'] as String?,
      type: json['type'] as int,
      collectionId: json['collectionId'] as int,
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
