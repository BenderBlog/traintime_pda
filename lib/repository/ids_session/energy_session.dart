// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Get payment, specifically your owe.

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:encrypter_plus/encrypter_plus.dart' as encrypt;
import 'package:intl/intl.dart';
import 'package:time/time.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/not_school_network_exception.dart';
import 'package:watermeter/model/xidian_ids/energy.dart';
import 'package:watermeter/repository/ids_session/slider_captcha_client.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_client.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/ids_session/ids_session.dart';

/// New energy management system
/// Online since 2026-4-22
/// Can be only be accessed through school net
class EnergySession extends IDSSession {
  static const _energyInfo = "EnergyInfo.json";
  static final File _fileCache = File("${supportPath.path}/$_energyInfo");

  static const _electricityHistory = "ElectricityHistory.json";
  static final File _fileHistory = File(
    "${supportPath.path}/$_electricityHistory",
  );

  bool get isCacheExist => _fileCache.existsSync();

  FetchResult<EnergyInfo>? getCache() {
    if (!isCacheExist) return null;
    log.info("[EneregySession][cache] Checking out cache.");
    try {
      final cache = EnergyInfo.fromJson(
        jsonDecode(_fileCache.readAsStringSync()),
      );
      return FetchResult.cache(
        fetchTime: _fileCache.lastModifiedSync(),
        data: cache,
      );
    } catch (e, s) {
      log.handle(e, s);
      return null;
    }
  }

  void saveCache(EnergyInfo info) {
    if (!isCacheExist) {
      _fileCache.createSync(recursive: true);
    }
    _fileCache.writeAsStringSync(jsonEncode(info.toJson()));
  }

  void deleteCache() {
    if (_fileCache.existsSync()) {
      _fileCache.deleteSync();
    }
  }

  List<ElectricityHistoryInfo> getElectricityHistory() {
    var list = <ElectricityHistoryInfo>[];

    if (!_fileHistory.existsSync()) {
      _fileHistory.createSync(recursive: true);
      return list;
    }

    try {
      String rawHistory = _fileHistory.readAsStringSync();
      List<ElectricityHistoryInfo> toAdd = jsonDecode(rawHistory)
          .map<ElectricityHistoryInfo>(
            (data) => ElectricityHistoryInfo.fromJson(data),
          )
          .toList();
      list.addAll(toAdd);
      list.sort((a, b) => a.fetchDay.compareTo(b.fetchDay));
    } catch (e, s) {
      log.handle(e, s);
    }

    return list;
  }

  void saveElectricityHistory(List<ElectricityHistoryInfo> history) {
    if (!_fileHistory.existsSync()) {
      _fileHistory.createSync(recursive: true);
    }
    _fileHistory.writeAsStringSync(jsonEncode(history));
  }

  void clearElectricityHistory() {
    if (!_fileHistory.existsSync()) {
      return;
    }

    _fileHistory.deleteSync();
    _fileHistory.createSync();
  }

  String _cacheHintFromError(Object error) {
    if (error is NotSchoolNetworkException) {
      return "electricity.not_school_network";
    }
    if (error is NoAccountInfoException) {
      return "electricity.cache_hint_account_missing";
    }
    if (error is AccountFailedParseException) {
      return "electricity.cache_hint_account_parse_failed";
    }
    if (error is CaptchaFailedException) {
      return "electricity.cache_hint_captcha_failed";
    }
    if (error is PasswordWrongException) {
      return "electricity.cache_hint_password_wrong";
    }
    if (error is LoginFailedException) {
      return "electricity.cache_hint_login_failed";
    }
    if (error is NotInitalizedException) {
      if (error.msg == "用户名或密码错误") {
        return "electricity.cache_hint_password_wrong";
      }
      if (error.msg.contains("验证码")) {
        return "electricity.cache_hint_captcha_failed";
      }
      return "electricity.cache_hint_login_failed";
    }
    if (error is DioException) {
      return "electricity.cache_hint_network_failed";
    }
    return "electricity.cache_hint_unknown_error";
  }

  Future<FetchResult<EnergyInfo>> getElectricityInfo({
    Future<String> Function(List<int>)? captchaFunction,
  }) async {
    log.info("[EletricitySession][update] Ready to update electricity info. ");
    DateTime fetchDay = DateTime.now();

    // Fetch cache info
    final cache = getCache();

    try {
      log.info("[EletricitySession][update] Fetching from Internet.");
      var toReturn = await _requestNewEnergyInfo(
        captchaFunction: captchaFunction,
      );
      saveCache(toReturn);
      return FetchResult.fresh(fetchTime: fetchDay, data: toReturn);
    } catch (e, s) {
      log.handle(e, s, "[getElectricityInfo] Have issue");
      if (cache != null) {
        return FetchResult.cache(
          fetchTime: cache.fetchTime,
          data: cache.data,
          hintKey: _cacheHintFromError(e),
        );
      }
      rethrow;
    }
  }

  static const _aesKey = "1234567812345678";
  static const _iv = "1234567812345678";

  /// Request for ElectricitySession, true by default
  Future<dynamic> _request(
    String url, {
    required Map<String, dynamic> data,
    bool isGetMethod = false,
  }) async {
    /// First stands for timestamp, Second stands for signature.
    /// Just post it in this way.
    (String, String) sign = await dio
        .post(
          "https://ignypt.xidian.edu.cn/baseNew/api/User/GetSignature",
          data: {
            "data": "",
            "access_token": "",
            "OpCode": "MPAY",
            "RequestID": "",
          },
        )
        .then(
          (data) => (
            data.data["data"]["timestamp"].toString(),
            data.data["data"]["signature"].toString(),
          ),
        );

    var enc = encrypt.Encrypter(
      encrypt.AES(encrypt.Key.fromUtf8(_aesKey), mode: encrypt.AESMode.cbc),
    );
    var iv = encrypt.IV.fromUtf8(_iv);
    log.info("[ElectricitySession][_request] $data ${jsonEncode(data)}");
    if (isGetMethod) {
      return dio.get(
        url,
        queryParameters: {
          "content": Uri.encodeComponent(
            enc.encrypt(jsonEncode(data), iv: iv).base64,
          ),
        },
        options: Options(
          headers: {
            "timestamp": sign.$1,
            "signature": sign.$2,
            "OpCode": "MPAY",
            "OrgId": "",
            "RequestID": "",
          },
        ),
      );
    }
    return dio.post(
      url,
      data: {"content": enc.encrypt(jsonEncode(data), iv: iv).base64},
      options: Options(
        headers: {
          "timestamp": sign.$1,
          "signature": sign.$2,
          "OpCode": "MPAY",
          "OrgId": "",
          "RequestID": "",
        },
        contentType: "application/json",
      ),
    );
  }

  Future<EnergyInfo> _requestNewEnergyInfo({
    required Future<String> Function(List<int>)? captchaFunction,
  }) async {
    final location = await checkAndLogin(
      target:
          "https://xxcapp.xidian.edu.cn/uc/api/oauth/index?"
          "redirect=https://ignypt.xidian.edu.cn/revenueH5/login?"
          "opcode=MPAY&appid=200260318155520600&state=12312312312312&qrcode=0",
      sliderCaptcha: (String cookieStr) =>
          SliderCaptchaClientProvider(cookie: cookieStr).solve(),
    );

    var response = await followIDSRedirects(
      initialLocation: location,
      client: dio,
    );
    final code = response.realUri.queryParameters["code"]!;
    log.info('[ElectricitySession][loginEnergy] Login redirect received.');

    response = await _request(
      "https://ignypt.xidian.edu.cn/estManage/api/WeChat/V2/OauthGetUserInfo",
      data: {"CODE": code},
      isGetMethod: true,
    );

    response = await _request(
      "https://ignypt.xidian.edu.cn/estManage/api/WeChat/V2/H5UserIDLogIn",
      data: {
        "UserID": preference.getString(preference.Preference.idsAccount),
        "Pwd": "",
        "IsCehckPwd": 1,
        "NodeID": "",
      },
    );

    String nodeID = response.data["ResData"][0]["NodeID"];

    response = await _request(
      "https://ignypt.xidian.edu.cn/estManage/api/wechat/v2/H5QueryMeterList",
      data: {"NodeID": nodeID},
      isGetMethod: true,
    );

    int electricityIndex =
        response.data["ResData"]["rows"][0]["MediumCode"] == "2" ? 0 : 1;

    num electricityRemainNum = num.parse(
      response.data["ResData"]["rows"][electricityIndex]["LastNum"].toString(),
    );
    String electricityMetID =
        response.data["ResData"]["rows"][electricityIndex]["MetID"];

    List<int> fetchDate = response
        .data["ResData"]["rows"][electricityIndex]["LastReadDate"]
        .toString()
        .split("-")
        .map((e) => int.parse(e))
        .toList();

    DateTime rangeEndForElectricity = DateTime(
      fetchDate[0],
      fetchDate[1],
      fetchDate[2],
    );
    DateTime rangeBeginForElectricity = rangeEndForElectricity.shift(
      months: -1,
    );
    DateTime rangeEndForWater = DateTime.now();
    DateTime rangeBeginForWater = rangeEndForWater.shift(years: -1);

    List<MeterInfo> electricityList =
        await _request(
          "https://ignypt.xidian.edu.cn/estManage/api/WeChat/V2/GetMetRead",
          isGetMethod: true,
          data: {
            "MetID": electricityMetID,
            "ReadTimeS": DateFormat(
              "yyyy-MM-dd",
            ).format(rangeBeginForElectricity),
            "ReadTimeE": DateFormat(
              "yyyy-MM-dd",
            ).format(rangeEndForElectricity),
            "ReadNum": "",
          },
        ).then(
          (value) => (value.data["ResData"]["rows"] as List<dynamic>)
              .map((e) => MeterInfo.fromJson(e))
              .toList(),
        );

    List<MeterInfo>? waterList;

    try {
      int waterIndex = electricityIndex == 0 ? 1 : 0;
      String waterMetID = response.data["ResData"]["rows"][waterIndex]["MetID"];
      waterList =
          await _request(
            "https://ignypt.xidian.edu.cn/estManage/api/WeChat/V2/GetMetRead",
            isGetMethod: true,
            data: {
              "MetID": waterMetID,
              "ReadTimeS": DateFormat("yyyy-MM-dd").format(rangeBeginForWater),
              "ReadTimeE": DateFormat("yyyy-MM-dd").format(rangeEndForWater),
              "ReadNum": "",
            },
          ).then(
            (value) => (value.data["ResData"]["rows"] as List<dynamic>)
                .map((e) => MeterInfo.fromJson(e))
                .toList(),
          );
    } catch (e, s) {
      log.error(
        "[EnergySession] failed to fetch water list, it will leave a blank",
        e,
        s,
      );
    }

    return EnergyInfo(
      electricityMeterList: electricityList,
      waterMeterList: waterList,
      electricityRemain: electricityRemainNum,
      lastReadDate: rangeEndForElectricity,
    );
  }
}

class NotFoundException implements Exception {}

class NeedInfoException implements Exception {}

class NotInitalizedException implements Exception {
  final String msg;
  const NotInitalizedException(this.msg);

  @override
  String toString() => "[NotInitalizedException] $msg";
}

class NoAccountInfoException implements Exception {}

class AccountFailedParseException implements Exception {}

class CaptchaFailedException implements Exception {}
