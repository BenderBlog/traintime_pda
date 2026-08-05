// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Library session.

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pool/pool.dart';
import 'package:watermeter/repository/ids_session/slider_captcha_client.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/model/xidian_ids/library.dart';
import 'package:watermeter/repository/ids_session/ids_session.dart';

class LibrarySession extends IDSSession {
  static const String _opacBaseUrl = "https://mfindxidian.libsp.cn";
  static const String _opacJwtHeader = "jwtOpacAuth";
  static const String _defaultGroupCode = "200755";
  static const String _opacLoginTarget =
      "https://tyrzfw.chaoxing.com/auth/xidian/cas/init?"
      "isLogout=0&refer=https%3A%2F%2Fmfindxidian.libsp.cn"
      "%2Ffind%2Fsso%2Flogin%2Fxidian%2F1";

  static int userId = 0;
  static String token = "";
  static String groupCode = "";

  /*
    Note 1:
      Scan to borrow book and transfer borrow book will not supported, 
      since I am not an official app, these function may lead me trouble:-P

      All I want to tell you, is the loanBook.html and borrow.html, that's it.
      And why Wechat's library app allows to scan the picture?

    Note 2:
      Search the book's info does not require login.
      You can use it in SPM class...
  */

  Options get _opacOptions => Options(
    contentType: "application/json;charset=utf-8",
    headers: {
      HttpHeaders.cookieHeader: "jwt=$token; jwtHeader=$_opacJwtHeader",
      HttpHeaders.refererHeader: "$_opacBaseUrl/",
      HttpHeaders.hostHeader: "mfindxidian.libsp.cn",
      "groupCode": groupCode.isEmpty ? _defaultGroupCode : groupCode,
      "mappingPath": "",
      _opacJwtHeader: token,
    },
  );

  Future<LibrarySearchFilterOptions> searchFilterOptions() async {
    final fallback = LibrarySearchFilterOptions.fallback();
    try {
      final results = await Future.wait([
        _searchFieldOptions(),
        _conditionOptions(),
        _locationOptions(),
      ]);
      final conditions =
          results[1]
              as ({
                List<LibrarySearchOption> documentTypes,
                List<LibrarySearchOption> countries,
                List<LibrarySearchOption> languages,
              });
      return LibrarySearchFilterOptions(
        searchFields: results[0] as List<LibrarySearchOption>,
        documentTypes: conditions.documentTypes,
        resourceTypes: fallback.resourceTypes,
        campuses: fallback.campuses,
        locations: results[2] as List<LibrarySearchOption>,
        countries: conditions.countries,
        languages: conditions.languages,
        years: fallback.years,
      );
    } catch (e, s) {
      log.handle(e, s, "[LibrarySession] Fetch search filter options failed");
      return fallback;
    }
  }

  Future<List<LibrarySearchOption>> _searchFieldOptions() async {
    final response = await dioNoOfflineCheck.get(
      "$_opacBaseUrl/find/groupResource/getFindOpacSearchFieldParaList",
      options: _opacOptions,
    );
    final data = response.data["data"];
    if (data is! List) {
      return LibrarySearchFilterOptions.fallback().searchFields;
    }

    final options = <LibrarySearchOption>[
      const LibrarySearchOption("keyWord", "任意词", "任意"),
    ];
    for (final item in data.whereType<Map>()) {
      final label = item["searchField"]?.toString() ?? "";
      final value = _searchFieldValue(label);
      if (label.isNotEmpty && value.isNotEmpty) {
        options.add(
          LibrarySearchOption(value, label, _searchFieldShort(label)),
        );
      }
    }
    return options;
  }

  Future<
    ({
      List<LibrarySearchOption> documentTypes,
      List<LibrarySearchOption> countries,
      List<LibrarySearchOption> languages,
    })
  >
  _conditionOptions() async {
    final response = await dioNoOfflineCheck.get(
      "$_opacBaseUrl/find/category/getConditionList",
      options: _opacOptions,
    );
    final data = response.data["data"];
    if (data is! Map) {
      final fallback = LibrarySearchFilterOptions.fallback();
      return (
        documentTypes: fallback.documentTypes,
        countries: fallback.countries,
        languages: fallback.languages,
      );
    }

    return (
      documentTypes: _codedOptions(data["documentTypeList"]),
      countries: _codedOptions(data["countryList"]),
      languages: _codedOptions(data["languageList"]),
    );
  }

  Future<List<LibrarySearchOption>> _locationOptions() async {
    final response = await dioNoOfflineCheck.post(
      "$_opacBaseUrl/find/location/list",
      data: {
        "locationName": "",
        "campusIds": [],
        "locationTypeCodes": [],
        "entrust": 0,
        "subscribe": 0,
        "page": 1,
        "rows": 2000,
      },
      options: _opacOptions,
    );
    final data = response.data["data"];
    final rawList = data is Map ? data["donateList"] : null;
    if (rawList is! List) {
      return LibrarySearchFilterOptions.fallback().locations;
    }

    final options = <LibrarySearchOption>[const LibrarySearchOption("", "全部")];
    for (final item in rawList.whereType<Map>()) {
      final id = item["locationId"]?.toString() ?? "";
      final name = item["locationName"]?.toString() ?? "";
      if (id.isNotEmpty && name.isNotEmpty) {
        options.add(LibrarySearchOption(id, name));
      }
    }
    return options;
  }

  List<LibrarySearchOption> _codedOptions(Object? value) {
    final options = <LibrarySearchOption>[const LibrarySearchOption("", "全部")];
    if (value is! List) return options;
    for (final item in value.whereType<Map>()) {
      final code = item["code"]?.toString() ?? "";
      final name = item["name"]?.toString() ?? "";
      if (code.isNotEmpty && name.isNotEmpty) {
        options.add(LibrarySearchOption(code, name));
      }
    }
    return options;
  }

  String _searchFieldValue(String label) =>
      const {
        "题名": "title",
        "责任者": "author",
        "主题": "subject",
        "标准号": "isbn",
        "分类号": "kindNo",
        "索书号": "callNo",
        "出版社": "publisher",
        "摘要": "abstract",
        "条码号": "barcode",
        "工具号": "toolNumber",
      }[label] ??
      "";

  String _searchFieldShort(String label) =>
      const {
        "任意词": "任意",
        "责任者": "责任者",
        "标准号": "标准号",
        "分类号": "分类",
        "索书号": "索书",
        "条码号": "条码",
        "工具号": "工具",
      }[label] ??
      label;

  Future<List<BookInfo>> searchBook(
    String searchWord,
    int page, {
    String searchField = "keyWord",
  }) async {
    if (searchWord.isEmpty) return [];
    final rawData = await _fetchOpacSearchResult(
      "$_opacBaseUrl/find/unify/search",
      _opacSearchBody(
        searchWord: searchWord,
        searchField: searchField,
        page: page,
      )..addAll({"searchItems": null, "indexSearch": 1}),
    );
    return _buildBookInfoList(rawData);
  }

  Future<List<BookInfo>> advancedSearchBook(
    String searchWord,
    int page, {
    String searchField = "keyWord",
    String matchMode = "2",
    String? docCode,
    String? resourceType,
    int? campusId,
    int? locationId,
    String? countryCode,
    String? langCode,
    bool? onlyOnShelf,
    String? publishBegin,
    String? publishEnd,
  }) async {
    final rawData = await _fetchOpacSearchResult(
      "$_opacBaseUrl/find/unify/advancedSearch",
      _opacSearchBody(
        searchWord: "",
        searchField: searchField,
        matchMode: matchMode,
        page: page,
        docCode: docCode,
        resourceType: resourceType,
        campusId: campusId,
        locationId: locationId,
        countryCode: countryCode,
        langCode: langCode,
        onlyOnShelf: onlyOnShelf,
        publishBegin: _emptyToNull(publishBegin),
        publishEnd: _emptyToNull(publishEnd),
      )..addAll({
        "searchItems": [
          {
            "oper": null,
            "searchField": searchField,
            "matchMode": matchMode,
            "searchFieldContent": searchWord,
          },
        ],
        "searchFieldList": null,
      }),
    );
    return _buildBookInfoList(rawData);
  }

  Future<String> bookCover(String title, String isbn, int docNumber) =>
      dioNoOfflineCheck
          .post(
            "$_opacBaseUrl/find/unify/getPItemAndOnShelfCountAndDuxiuImageUrl",
            data: {"title": title, "isbn": isbn, "recordId": docNumber},
            options: _opacOptions,
          )
          .then((value) {
            final data = value.data["data"];
            if (data is! Map) return "";
            return data["duxiuImageUrl"]?.toString() ?? "";
          });

  Future<List<BookLocation>> bookLocations(int recordId) async {
    if (recordId <= 0) return [];

    final response = await dioNoOfflineCheck.post(
      "$_opacBaseUrl/find/physical/groupitems",
      data: {
        "page": 1,
        "rows": 200,
        "entrance": null,
        "recordId": recordId.toString(),
        "isUnify": true,
      },
      options: _opacOptions,
    );

    final data = response.data["data"];
    final rawList = data is Map ? data["list"] : null;
    if (rawList is! List) return [];

    return rawList
        .whereType<Map>()
        .map((e) => BookLocation.fromOpacJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Map<String, dynamic> _opacSearchBody({
    required String searchWord,
    required String searchField,
    String matchMode = "2",
    required int page,
    String? docCode,
    String? resourceType,
    int? campusId,
    int? locationId,
    String? countryCode,
    String? langCode,
    bool? onlyOnShelf,
    String? publishBegin,
    String? publishEnd,
  }) => {
    "docCode": [docCode],
    "litCode": [],
    "searchFieldContent": searchWord,
    "searchField": searchField,
    "matchMode": matchMode,
    "resourceType": _stringArray(resourceType),
    "subject": [],
    "discode1": [],
    "publisher": [],
    "locationId": _intArray(locationId),
    "collectionName": [],
    "author": [],
    "langCode": _stringArray(langCode),
    "countryCode": _stringArray(countryCode),
    "publishBegin": publishBegin,
    "publishEnd": publishEnd,
    "coreInclude": [],
    "ddType": [],
    "verifyStatus": [],
    "group": [],
    "sortField": "relevance",
    "sortClause": "desc",
    "page": page,
    "rows": 10,
    "onlyOnShelf": onlyOnShelf,
    "campusId": _intArray(campusId),
    "curLocationId": [],
    "eCollectionIds": [],
    "kindNo": [],
    "libCode": [],
    "neweCollectionIds": [],
    "newCoreInclude": [],
    "customSub": [],
    "customSub0": [],
  };

  Future<List<Map<String, dynamic>>> _fetchOpacSearchResult(
    String url,
    Map<String, dynamic> body,
  ) => dioNoOfflineCheck.post(url, data: body, options: _opacOptions).then((
    value,
  ) {
    final data = value.data["data"];
    final searchResult = data is Map ? data["searchResult"] : null;
    if (searchResult is! List) {
      return <Map<String, dynamic>>[];
    }
    return searchResult
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  });

  List<BookInfo> _buildBookInfoList(List<Map<String, dynamic>> rawData) =>
      rawData.map(BookInfo.fromOpacJson).toList();

  String? _emptyToNull(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }

  List<String> _stringArray(String? value) =>
      value == null || value.isEmpty ? [] : [value];

  List<int> _intArray(int? value) => value == null ? [] : [value];

  Future<String> renew(BorrowData toUse) async {
    try {
      if (token.isEmpty) {
        await initSession();
      }

      final response = await dioNoOfflineCheck.post(
        "$_opacBaseUrl/find/lendbook/reNew",
        data: {
          "loanIds": [toUse.loanId],
        },
        options: _opacOptions,
      );
      final body = response.data;
      final data = body["data"];
      final result = data is Map ? data["result"] : null;
      final success = data is Map ? data["success"] : null;

      if (success is num && success > 0) {
        final newDate = result is Map && result.values.isNotEmpty
            ? result.values.first.toString()
            : "";
        return newDate.isEmpty ? "续借成功" : "续借成功，新还书日期：$newDate";
      }

      if (result is Map && result.values.isNotEmpty) {
        return result.values.join("\n");
      }
      return body["message"]?.toString().isNotEmpty == true
          ? body["message"].toString()
          : "续借失败";
    } catch (e, s) {
      log.handle(e, s);
      return "获取过程遇到错误";
    }
  }

  Future<List<BorrowData>> getBorrowList() async {
    log.info(
      "[LibrarySession][getBorrowList] "
      "Getting borrow list",
    );

    if (token.isEmpty) {
      await initSession();
    }

    final List<Map<String, dynamic>> rawData = await dioNoOfflineCheck
        .post(
          "$_opacBaseUrl/find/loanInfo/loanList",
          data: {
            "page": 1,
            "rows": 999,
            "searchType": 1,
            "searchContent": "",
            "sortType": 0,
            "startDate": null,
            "endDate": null,
          },
          options: _opacOptions,
        )
        .then((value) {
          final data = value.data["data"];
          if (data is! Map || data["searchResult"] == null) {
            throw NotFetchLibraryException(
              message: "Unexpected borrow list response: ${value.data}",
            );
          }
          final searchResult = data["searchResult"];
          if (searchResult is! List) {
            throw NotFetchLibraryException(
              message: "Unexpected borrow list payload: ${value.data}",
            );
          }
          return searchResult.cast<Map<String, dynamic>>();
        });

    List<BorrowData> toAppend = [];
    final pool = Pool(5);
    await Future.wait([
      ...rawData.map(
        (rawItem) => pool.withResource(() async {
          final e = BorrowData.fromJson(rawItem);
          e.imageUrl = e.recordId > 0
              ? await bookCover(e.title, e.isbn, e.recordId)
              : "";
          toAppend.add(e);
        }),
      ),
    ]);

    toAppend.sort(
      (a, b) =>
          a.normReturnDateTime.millisecondsSinceEpoch -
          b.normReturnDateTime.millisecondsSinceEpoch,
    );

    return toAppend;
  }

  Future<void> initSession() async {
    log.info("[LibrarySession][initSession] Initalizing Library Session");
    try {
      token = "";
      groupCode = "";
      userId = 0;

      final location = await checkAndLogin(
        target: _opacLoginTarget,
        sliderCaptcha: (String cookieStr) =>
            SliderCaptchaClientProvider(cookie: cookieStr).solve(),
      );

      await _resolveOpacLogin(location);
      if (token.isEmpty) {
        throw NotFetchLibraryException(message: "Can not find OPAC JWT.");
      }

      _loadJwtInfo(token);
      await _warmUpOpacSession();
    } catch (e, s) {
      log.handle(e, s);
      throw NotFetchLibraryException(message: e.toString());
    }
  }

  Future<void> _resolveOpacLogin(String firstLocation) async {
    String location = firstLocation;
    for (int i = 0; i < IDSSession.maxAuthRedirects; i++) {
      location = (await resolveIDSReAuthIfNeeded(
        Uri.parse(location),
        service: _opacLoginTarget,
      )).toString();
      _throwIfWechatLocation(location);
      _tryLoadJwtFromLocation(location);
      if (token.isNotEmpty) return;

      final response = await dioNoOfflineCheck.get(location);
      log.info('[LibrarySession][initSession] Following login redirect.');
      final nextLocation = response.headers[HttpHeaders.locationHeader]?[0];
      if (nextLocation != null) {
        location = _resolveLocation(location, nextLocation);
        _throwIfWechatLocation(location);
        continue;
      }

      final next = await _tryChaoxingCasLogin(response.data.toString());
      if (next == null) {
        return;
      }
      location = next;
    }
    throw const LoginFailedException(msg: '图书馆认证跳转次数超过 30 次');
  }

  Future<String?> _tryChaoxingCasLogin(String html) async {
    final data = RegExp(
      r'data: "(?<data>.*)",',
    ).firstMatch(html)?.namedGroup("data");
    final time = RegExp(
      r'time: (?<time>[0-9]*),',
    ).firstMatch(html)?.namedGroup("time");
    final enc = RegExp(
      r'enc: "(?<enc>.*)",',
    ).firstMatch(html)?.namedGroup("enc");
    final name = RegExp(
      r'displayName: "(?<name>.*)",',
    ).firstMatch(html)?.namedGroup("name");
    final userRole = RegExp(
      r'userRole: (?<userRole>[0-9]{1}),',
    ).firstMatch(html)?.namedGroup("userRole");

    if ([data, time, enc, name, userRole].any((element) => element == null)) {
      return null;
    }

    final isSuccess = await dioNoOfflineCheck
        .get(
          "https://tyrzfw.chaoxing.com/auth/xidian/cas/login",
          queryParameters: {
            "data": data,
            "time": time,
            "enc": enc,
            "displayName": name,
            "userRole": userRole,
            "group1": null,
            "mobilePhone": null,
          },
        )
        .then((value) {
          if (value.data is String) {
            return jsonDecode(value.data);
          }
          return value.data;
        });

    if (isSuccess is! Map || isSuccess["status"] != true) {
      throw NotFetchLibraryException(
        message: "Chaoxing CAS login failed: $isSuccess",
      );
    }

    final response = await dioNoOfflineCheck.get(
      "$_opacBaseUrl/find/sso/login/xidian/1",
      queryParameters: {"data": data, "time": time, "enc": enc},
    );
    return response.headers[HttpHeaders.locationHeader]?[0];
  }

  void _throwIfWechatLocation(String location) {
    final uri = Uri.parse(location);
    final host = uri.host.toLowerCase();
    if (host == "open.weixin.qq.com" ||
        host == "wx.chaoxing.com" ||
        uri.path.toLowerCase().contains("/weixin/")) {
      throw NotFetchLibraryException(
        message: "Wechat auth redirect is not allowed: $location",
      );
    }
  }

  void _tryLoadJwtFromLocation(String location) {
    final uri = Uri.parse(location);
    token = uri.queryParameters["jwt"] ?? token;

    final fragment = uri.fragment;
    final queryIndex = fragment.indexOf("?");
    if (token.isEmpty && queryIndex >= 0) {
      token =
          Uri.splitQueryString(fragment.substring(queryIndex + 1))["jwt"] ?? "";
    }
  }

  void _loadJwtInfo(String jwt) {
    final parts = jwt.split(".");
    if (parts.length < 2) return;

    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );
    if (payload is! Map<String, dynamic>) return;

    userId = int.tryParse(payload["sub"]?.toString() ?? "") ?? 0;
    groupCode = payload["groupCode"]?.toString() ?? _defaultGroupCode;
  }

  Future<void> _warmUpOpacSession() async {
    try {
      await dioNoOfflineCheck.get(
        "$_opacBaseUrl/oga/userinfo",
        queryParameters: {"jwtHeader": _opacJwtHeader, "jwt": token},
        options: _opacOptions,
      );
    } catch (e, s) {
      log.handle(e, s, "[LibrarySession] Warm up user info failed");
    }

    final fetchedGroupCode = await dioNoOfflineCheck
        .post(
          "$_opacBaseUrl/find/homePage/getGroupCode",
          data: {"mappingPath": ""},
          options: _opacOptions,
        )
        .then((value) => value.data["data"]?["groupCode"]?.toString())
        .onError<Object>((e, s) {
          log.handle(e, s, "[LibrarySession] Fetch group code failed");
          return null;
        });
    groupCode = fetchedGroupCode ?? groupCode;
  }

  String _resolveLocation(String currentLocation, String location) {
    final uri = Uri.parse(location);
    if (uri.hasScheme) return location;
    return Uri.parse(currentLocation).resolve(location).toString();
  }
}

class NotFetchLibraryException implements Exception {
  final String message;
  NotFetchLibraryException({this.message = "Error detected."});
}
