// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/repository/experiment/experiment_dio_transfer.dart';

class ExperimentSession extends NetworkSession {
  static const experimentCacheName = "Experiment.json";
  @override
  Dio get dio => Dio()
    ..interceptors.add(alice.getDioInterceptor())
    ..transformer = ExperimentDioTransformer()
    ..options.contentType = Headers.formUrlEncodedContentType
    ..options.followRedirects = false
    ..options.validateStatus =
        (status) => status != null && status >= 200 && status < 400;

  static Map<String, String> selectInfo = {};
  String cookieStr = "";

  /// This function is used to fetch the teacher for the experiment class.
  Future<String> teacher({
    required String time,
    required String subject,
  }) async {
    //const String publicHeader =
    //    "__EVENTTARGET=plan1%24ExpeList&__EVENTARGUMENT=&__LASTFOCUS=&";
    String searchHeader(String expList) =>
        "__EVENTTARGET=plan1%24ExpeList&__EVENTARGUMENT=&__LASTFOCUS=&__VIEWSTATE=%2FwEPDwUJNzIxNTY3OTg3D2QWAgIDD2QWAgIBD2QWBgIBDxAPFggeDEF1dG9Qb3N0QmFja2ceDkRhdGFWYWx1ZUZpZWxkBQpFeHBlUGxhbklEHg1EYXRhVGV4dEZpZWxkBQxFeHBlUGxhbk5hbWUeC18hRGF0YUJvdW5kZ2QQFRMh5omt5pGG5rOV5rWL6YeP5YiH5Y%2BY5qih6YeP5a6e6aqMJ%2BaLieS8uOazlea1i%2BmHj%2BadqOawj%2BW8ueaAp%2BaooemHj%2BWunumqjCHlpI3mkYbmtYvph4%2Fph43lipvliqDpgJ%2Fluqblrp7pqowe5LiJ5qOx6ZWc6aG26KeS55qE5rWL6YeP5a6e6aqMEuWFieagheihjeWwhOWunumqjB7nkIbmg7PmsJTkvZPnirbmgIHmlrnnqIvlrp7pqowS5YqI5bCW5bmy5raJ5a6e6aqMGOWFieeahOWBj%2BaMr%2BeglOeptuWunumqjBvoloTpgI%2FplZznhKbot53mtYvph4%2Flrp7pqowe5Y2V57yd6KGN5bCE5YWJ5by65YiG5biD5a6e6aqMKui%2FiOWFi%2BWwlOmAiuW5sua2ieS7qua1i%2Ba%2FgOWFieazoumVv%2BWunumqjCTlhrLlh7vms5XmtYvph4%2Fpq5jpmLvlkoznlLXlrrnlrp7pqowe6ZyN6ICz5YWD5Lu25rWL6YeP56OB5Zy65a6e6aqMGOS9jueUtemYu%2BeahOa1i%2BmHj%2BWunumqjC3nlKjlhrLlh7vms5XmtYvph4%2Fonrrnur%2FnrqHno4HlnLrliIbluIPlrp7pqowh54G15pWP55S15rWB6K6h54m55oCn5rWL6YeP5a6e6aqMG%2BawtOS4reWjsOmAn%2BeahOa1i%2BmHj%2BWunumqjB7nqbrmsJTkuK3lo7DpgJ%2FnmoTmtYvph4%2Flrp7pqowk55S15a2Q55qE55S15YGP6L2s5ZKM56OB5YGP6L2s5a6e6aqMFRMDQjAxA0IwMgNCMDMDQjA0A0IwNQNCMDYDQjA3A0IwOANCMDkDQjEwA0IxMQNCMTIDQjEzA0IxNANCMTUDQjE2A0IxNwNCMTgDQjE5FCsDE2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2cWAQIFZAIDDw8WAh4EVGV4dAUe55CG5oOz5rCU5L2T54q25oCB5pa556iL5a6e6aqMZGQCBQ88KwALAQAPFgweDERhdGFLZXlGaWVsZAUERVBJRB4IRGF0YUtleXMWCgKKTgKLTgKMTgKNTgKOTgKPTgKQTgKRTgKSTgKTTh4LXyFJdGVtQ291bnQCCh4JUGFnZUNvdW50AgEeFV8hRGF0YVNvdXJjZUl0ZW1Db3VudAIKHg1FZGl0SXRlbUluZGV4Av%2F%2F%2F%2F8PZBYCZg9kFhQCAQ9kFgpmD2QWAgIBDw8WAh8EBRzmmJ%2FmnJ%2FkuIDkuIvljYgxNTo1Ne%2B9njE4OjEwZGQCAQ9kFgICAQ8PFgIfBAUJ6IOh6I2j5petZGQCAg9kFgICAQ8PFgIfBAUBMmRkAgMPZBYCAgEPDxYCHwQFAjEzZGQCBA9kFgICAQ8PFgIfBAUD5pivZGQCAg9kFgpmD2QWAgIBDw8WAh8EBRzmmJ%2FmnJ%2FkuIDmmZrkuIoxODozMO%2B9njIwOjQ1ZGQCAQ9kFgICAQ8PFgIfBAUJ6IOh6I2j5petZGQCAg9kFgICAQ8PFgIfBAUBMmRkAgMPZBYCAgEPDxYCHwQFAjEzZGQCBA9kFgICAQ8PFgIfBAUD5pivZGQCAw9kFgpmD2QWAgIBDw8WAh8EBRzmmJ%2FmnJ%2FkuozkuIvljYgxNTo1Ne%2B9njE4OjEwZGQCAQ9kFgICAQ8PFgIfBAUJ6IOh6I2j5petZGQCAg9kFgICAQ8PFgIfBAUBMmRkAgMPZBYCAgEPDxYCHwQFAjEzZGQCBA9kFgICAQ8PFgIfBAUD5pivZGQCBA9kFgpmD2QWAgIBDw8WAh8EBRzmmJ%2FmnJ%2FkuozmmZrkuIoxODozMO%2B9njIwOjQ1ZGQCAQ9kFgICAQ8PFgIfBAUJ6IOh6I2j5petZGQCAg9kFgICAQ8PFgIfBAUBMmRkAgMPZBYCAgEPDxYCHwQFAjEzZGQCBA9kFgICAQ8PFgIfBAUD5pivZGQCBQ9kFgpmD2QWAgIBDw8WAh8EBRzmmJ%2FmnJ%2FkuInkuIvljYgxNTo1Ne%2B9njE4OjEwZGQCAQ9kFgICAQ8PFgIfBAUJ6IOh6I2j5petZGQCAg9kFgICAQ8PFgIfBAUBMmRkAgMPZBYCAgEPDxYCHwQFAjEzZGQCBA9kFgICAQ8PFgIfBAUD5pivZGQCBg9kFgpmD2QWAgIBDw8WAh8EBRzmmJ%2FmnJ%2FkuInmmZrkuIoxODozMO%2B9njIwOjQ1ZGQCAQ9kFgICAQ8PFgIfBAUJ6IOh6I2j5petZGQCAg9kFgICAQ8PFgIfBAUBMmRkAgMPZBYCAgEPDxYCHwQFAjEzZGQCBA9kFgICAQ8PFgIfBAUD5pivZGQCBw9kFgpmD2QWAgIBDw8WAh8EBRzmmJ%2FmnJ%2Flm5vkuIvljYgxNTo1Ne%2B9njE4OjEwZGQCAQ9kFgICAQ8PFgIfBAUJ546L5YWw576OZGQCAg9kFgICAQ8PFgIfBAUBMmRkAgMPZBYCAgEPDxYCHwQFAjEzZGQCBA9kFgICAQ8PFgIfBAUD5pivZGQCCA9kFgpmD2QWAgIBDw8WAh8EBRzmmJ%2FmnJ%2Flm5vmmZrkuIoxODozMO%2B9njIwOjQ1ZGQCAQ9kFgICAQ8PFgIfBAUJ546L5YWw576OZGQCAg9kFgICAQ8PFgIfBAUBMmRkAgMPZBYCAgEPDxYCHwQFAjEzZGQCBA9kFgICAQ8PFgIfBAUD5pivZGQCCQ9kFgpmD2QWAgIBDw8WAh8EBRzmmJ%2FmnJ%2FkupTkuIvljYgxNTo1Ne%2B9njE4OjEwZGQCAQ9kFgICAQ8PFgIfBAUJ546L5YWw576OZGQCAg9kFgICAQ8PFgIfBAUBMmRkAgMPZBYCAgEPDxYCHwQFAjEzZGQCBA9kFgICAQ8PFgIfBAUD5pivZGQCCg9kFgpmD2QWAgIBDw8WAh8EBRzmmJ%2FmnJ%2FkupTmmZrkuIoxODozMO%2B9njIwOjQ1ZGQCAQ9kFgICAQ8PFgIfBAUJ546L5YWw576OZGQCAg9kFgICAQ8PFgIfBAUBMmRkAgMPZBYCAgEPDxYCHwQFAjEzZGQCBA9kFgICAQ8PFgIfBAUD5pivZGRkvuH6Y6ax23oMkxvxTrcQdw2MqlVsGtfP3ebsOECfoJk%3D&__VIEWSTATEGENERATOR=D00094F3&__EVENTVALIDATION=%2FwEdABXSI9jOWpDvRoxTFuL6r4rd1QZro53UTKny2Ps1j1qZL126909GVTyyD7VaLIR%2FEzOdlYL889oF%2B7Sr7hcCMV%2Fg9qFg5nQ6AnwHFuWlnshcn2t%2FvIupV%2FRYUW1PY4JzzvMY1AhiqPIp5tz%2BJrTD2XB6%2BqIrShL%2F0TPj3ZZnao0D3vM4bWl3ycVh1yQ5%2Bc1zn1Hts%2BEr1si7sU8eESIyH9PjrzmrgF7LB22P6ukoT202PIauOvbEewDUHM%2FR2Fdw4qapSrKDSFNXSFSDbsRtK4vAlmk7EVbqY9ChCZL822pk3frD7qqKbtpyLiNplf%2F%2BrfJIU7qdav0a2VX2FulJ7D24sNBNRpDa6whXQwztGNzv%2FQTfdfCXdOdrHHhzQNcbhurSDfsfiCqyqeIu9ckE52LasUxAGcTPIBdmPgYtIJhgzdIhV7KNsAUQ6xKPM0kio4hCpUtj4e86FyXJauHQ9ZSnntx0AqvpQut9xYu6eaSi4w%3D%3D&plan1%24ExpeList=$expList";

    RegExp weekGet = RegExp(
      r'<span id="plan1_PlanGrid_TimeN_[0-9]{1,2}">(?<week>(.*))</span>',
    );
    RegExp teacherGet = RegExp(
      r'<span id="plan1_PlanGrid_Teacher_[0-9]{1,2}">(?<teacher>(.*))</span>',
    );
    /*
    RegExp headerGet = RegExp(
      r'<input type="hidden" name="(?<name>(.*))" id="(?<id>(.*))" value="(?<value>(.*))">',
    );*/

    /// Get inside
    String page = await dio
        .get(
          "http://wlsy.xidian.edu.cn/PhyEws/student/course.aspx",
          options: Options(
            headers: {
              HttpHeaders.cookieHeader: cookieStr,
              HttpHeaders.hostHeader: "wlsy.xidian.edu.cn",
            },
          ),
        )
        .then(
          (value) => value.data,
        );

    /// Fetch heder
    /// headerGet.allMatches(page).toList();
    /*
    String header = publicHeader;
    var hiddenItems = BeautifulSoup(page).findAll("input");
    if (hiddenItems.isEmpty) throw FailedToFetchException;
    for (var i in hiddenItems) {
      if (["__EVENTTARGET", "__EVENTARGUMENT", "__LASTFOCUS"].contains(i.id)) {
        continue;
      }
      header += "${i.id}=${Uri.encodeFull(i.getAttrValue("value") ?? "")}&";
    }
    */

    /// Init the select info if necessary
    if (selectInfo.isEmpty) {
      RegExp infoGet = RegExp(
        r'<option( selected="selected")? value="(?<code>(B[0-9]{2}))">(?<name>(.*))</option>',
      );

      var expInfo = infoGet.allMatches(page.toString()).toList();
      for (var i in expInfo) {
        selectInfo[i.namedGroup("name")!] = i.namedGroup("code")!;
      }
    }

    if (selectInfo[subject] != "B01") {
      log.d(
        "[experiment_session][getData] "
        "${selectInfo[subject]} ferching...",
      );
      page = await dio
          .post(
            "http://wlsy.xidian.edu.cn/PhyEws/student/course.aspx",
            data: searchHeader(selectInfo[subject]!),
            options: Options(
              headers: {
                HttpHeaders.cookieHeader: cookieStr,
                HttpHeaders.hostHeader: "wlsy.xidian.edu.cn",
              },
            ),
          )
          .then(
            (value) => value.data,
          );
    }
    var weekInfo = weekGet.allMatches(page).toList();
    var teacherInfo = teacherGet.allMatches(page).toList();

    for (int i = 0; i < weekInfo.length; ++i) {
      if (weekInfo[i].namedGroup('week')?.contains(time) ?? false) {
        return teacherInfo[i].namedGroup('teacher')!;
      }
    }

    throw NotFoundTeacherException;
  }

  Future<List<ExperimentData>> getData() async {
    log.i(
      "[experiment_session][getData] "
      "Path at ${supportPath.path}.",
    );
    var file = File("${supportPath.path}/$experimentCacheName");
    bool isExist = file.existsSync();
    log.i(
      "[experiment_session][getData] "
      "File exist: $isExist.",
    );
    try {
      if (await NetworkSession.isInSchool() == false) {
        throw NotSchoolNetworkException;
      }

      if (preference
          .getString(preference.Preference.experimentPassword)
          .isEmpty) {
        throw NoExperimentPasswordException;
      }

      log.d(
        "[experiment_session][getData] "
        "Get login in experiment_session.",
      );

      var loginResponse = await dio.post(
        'http://wlsy.xidian.edu.cn/PhyEws/default.aspx',
        data: '__EVENTTARGET=&__EVENTARGUMENT=&'
            '__VIEWSTATE=%2FwEPDwUKMTEzNzM0MjM0OWQYAQUeX19D'
            'b250cm9sc1JlcXVpcmVQb3N0QmFja0tleV9fFgEFD2xvZ2luMSRidG5Mb2dpbkOuzGVaztce4Ict7jsIJ0F5pUDb%2BsmSbCCrNVSBlPML&'
            '__VIEWSTATEGENERATOR=EE008CD9&'
            '__EVENTVALIDATION=%2FwEdAAcKecdPGDB%2BfW8Tyghx'
            '7AeSpOzeiNZ7aaEg5p6LqSa9cODI2bZwNtRxUKPkisVLf8l'
            '8Vv4WhRVIIhZlyYNJO%2BySrDKOhP%2B%2FYMNbVIh74hA2r'
            'CYnBBSTsX9SjxiYNNk%2B5kglM%2B6pGIq22Oi5mNu6u6eC2W'
            'EBfKAmATKwSpsOL%2FPNcRyi9l8Dnp6JamksyAzjhW4%3D&'
            'login1%24StuLoginID=${preference.getString(preference.Preference.idsAccount)}&'
            'login1%24StuPassword=${preference.getString(preference.Preference.experimentPassword)}&'
            'login1%24UserRole=Student&'
            'login1%24btnLogin.x=28&'
            'login1%24btnLogin.y=14',
      );

      if (loginResponse.statusCode != 302) {
        throw LoginFailedException();
      }

      cookieStr = "";

      log.d(
        "[experiment_session][getData] "
        "Start fetching data.",
      );

      for (String i
          in loginResponse.headers[HttpHeaders.setCookieHeader] ?? []) {
        log.d(
          "[experiment_session][getData] "
          "Cookie $i.",
        );
        if (i.contains("PhyEws_StuName")) {
          /// This guy find out the secret.
          cookieStr += "PhyEws_StuName=waterfloatinggenderly; ";
        } else if (i.contains('HttpOnly')) {
          continue;
        } else {
          cookieStr += '${i.split(';')[0]}; ';
        }
      }

      log.d(
        "[experiment_session][getData] "
        "Cookie is $cookieStr.",
      );

      var data = await dio
          .get(
            "http://wlsy.xidian.edu.cn/PhyEws/student/select.aspx",
            options: Options(
              headers: {
                HttpHeaders.cookieHeader: cookieStr,
                HttpHeaders.hostHeader: "wlsy.xidian.edu.cn",
              },
            ),
          )
          .then(
            (value) => value.data,
          );

      RegExp regExp = RegExp(
        r'<td class="forumRow" height="25"><span>(?<id>[0-9]{1,2})</span></td>'
        r'<td class="forumRow" height="25"><a class="linkSmallBold" target="_new">(?<name>((?!《物理实验》)(?!下载).*?)（[0-9]学时）)</a></td>'
        r'<td class="forumRow" align="center" height="25"><span>(?<week>[0-9]{1,2})</span></td>'
        r'<td class="forumRow" height="25"><span>(?<time>星期(.*)([0-2][0-9]:[0-5][0-9])～([0-2][0-9]:[0-5][0-9]))</span></td>'
        r'<td class="forumRow" height="25"><span>(?<date>([0-9]{1,2}/[0-9]{1,2}/[0-9]{4}))</span></td>'
        r'<td class="forumRow" align="center" height="25"><span>(?<place>([A-F]([0-999]{3,3})))</span></td>'
        r'<td class="forumRow" height="25"><a class="linkSmallBold" target="_new">大学物理实验</a></td>'
        r'<td class="forumRow" height="25"><span>(?<score>(.*))</span></td><td class="forumRow" height="25"><span></span></td>'
        r'<td class="forumRow" height="25"><span>(?<note>([0-9]{1,3}页))</span></td>',
      );

      var expInfo = regExp.allMatches(data).toList();
      List<ExperimentData> toReturn = [];
      for (var i in expInfo) {
        toReturn.add(
          ExperimentData(
            name: i.namedGroup('name')!.replaceAll('（3学时）', ''),
            score: i.namedGroup('score')!,
            classroom: i.namedGroup('place')!,
            date: i.namedGroup('date')!,
            timeStr: i.namedGroup('time')!,
            reference: i.namedGroup("note")!,
            teacher: await teacher(
              time: i.namedGroup('time')!,
              subject: i.namedGroup('name')!.replaceAll('（3学时）', ''),
            ),
          ),
        );
      }

      log.i(
        "[experiment_session][getData] "
        "Evaluating cache. ${jsonEncode(toReturn)}.",
      );
      if (isExist) {
        log.i(
          "[experiment_session][getData] "
          "Refreshing cache...",
        );
        file.deleteSync();
      }

      file.writeAsStringSync(jsonEncode(toReturn));
      return toReturn;
    } catch (e) {
      if (isExist) {
        log.i(
          "[experiment_session][getData] "
          "Using cache...",
        );
        List<dynamic> data = jsonDecode(file.readAsStringSync());
        return List<ExperimentData>.generate(
          data.length,
          (index) => ExperimentData.fromJson(data[index]),
        );
      } else {
        rethrow;
      }
    }
  }
}

class LoginFailedException implements Exception {}

class FailedToFetchException implements Exception {}

class NotFoundTeacherException implements Exception {}

class NoExperimentPasswordException implements Exception {}

class ExperimentClosedException implements Exception {}
