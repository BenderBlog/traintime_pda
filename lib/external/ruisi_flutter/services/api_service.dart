// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import '../constants/urls.dart';
import '../models/forum.dart';
import '../models/topic.dart';
import '../models/post.dart';
import '../models/message.dart';
import '../models/post_page_meta.dart';
import '../repository/ruisi_api.dart';
import 'settings_service.dart';

/// 业务 API 服务
///
/// 基于 [RuisiApi] 的底层 HTTP 能力，封装论坛业务逻辑。
/// Cookie 管理、formhash 注入等均由 [RuisiApi] 处理。
class ApiService {
  final RuisiApi _api;
  final SettingsService _settings;

  ApiService(this._api, this._settings);

  /// 底层 RuisiApi 实例（用于代理设置等底层操作）
  RuisiApi get ruisiApi => _api;

  // =========================================================================
  // 登录
  // =========================================================================

  /// 是否已登录
  bool get isLoggedIn => _settings.isLogin;

  /// 检查登录页是否需要验证码，返回 seccodehash（null 表示不需要）
  Future<String?> fetchLoginCaptchaHash() async {
    _api.talker.info('正在获取登录页验证码 hash...');
    final (ok, body) = await _api.get(Urls.loginUrl);
    if (!ok) {
      _api.talker.error('获取登录页失败');
      return null;
    }

    _api.talker.debug('登录页响应长度: ${body.length}');

    // 方式1: 从 <input name=seccodehash> 获取
    final doc = html_parser.parse(body);
    final input = doc.querySelector('input[name=seccodehash]');
    if (input != null) {
      final hash = input.attributes['value'];
      if (hash != null && hash.isNotEmpty) {
        _api.talker.info('验证码 hash 获取成功(input): $hash');
        return hash;
      }
    }

    // 方式2: Discuz 用 JS 动态渲染验证码，hash 在 updateseccode('HASH', ...) 中
    final jsMatch = RegExp(r"updateseccode\('(\w+)'").firstMatch(body);
    if (jsMatch != null) {
      final hash = jsMatch.group(1)!;
      _api.talker.info('验证码 hash 获取成功(js): $hash');
      return hash;
    }

    _api.talker.warning('登录页不需要验证码');
    return null;
  }

  /// 获取验证码的 update token
  Future<String?> _fetchCaptchaUpdate(String hash) async {
    final (ok, body) = await _api.get(Urls.getValidUpdateUrl(hash));
    if (!ok) return null;

    // 解析响应中的 update 值: update('xxxx')
    final match = RegExp(r"update\('(\w+)'").firstMatch(body);
    return match?.group(1);
  }

  /// 获取验证码图片二进制数据
  Future<Uint8List?> fetchCaptchaImage(String hash) async {
    _api.talker.info('正在获取验证码图片, hash=$hash');
    final update = await _fetchCaptchaUpdate(hash);
    _api.talker.info('验证码 update token: $update');
    final url = Urls.updateValidUrl(update ?? '0', hash);
    _api.talker.info('验证码图片 URL: $url');
    final (ok, data) = await _api.getRaw(url);
    if (ok) {
      _api.talker.info('验证码图片获取成功, 大小: ${data?.length ?? 0} bytes');
    } else {
      _api.talker.error('验证码图片获取失败');
    }
    return ok ? data : null;
  }

  /// 校验验证码是否正确
  Future<bool> verifyCaptcha(String hash, String value) async {
    final (ok, body) = await _api.get(Urls.checkValidUrl(hash, value));
    if (!ok) return false;
    return body.contains('succeed');
  }

  /// 登录
  ///
  /// 采用方案 A（与 iOS 原版 LoginViewController 一致）：
  /// 直接检查 POST 响应中是否包含 "欢迎您回来"，
  /// 然后用正则从响应中提取 uid/用户名/formhash。
  /// 无需额外网络请求，不受移动端/桌面端页面结构差异影响。
  ///
  /// 返回 (成功?, 错误信息)
  Future<(bool, String?)> login(
    String username,
    String password, {
    String? seccodeHash,
    String? seccodeVerify,
  }) async {
    // Step 1: 获取登录页，提取 formhash 和 loginhash
    final (webpageOk, webpage) = await _api.get(Urls.loginUrl);

    if (!webpageOk) return (false, '无法访问登录页面');

    var document = html_parser.parse(webpage);

    String? formhash = document
        .querySelector('input[name="formhash"]')
        ?.attributes['value'];
    String? action = document
        .querySelector('form[id^="loginform_"]')
        ?.attributes['action'];
    String loginhash =
        RegExp(r'loginhash=(\w+)').firstMatch(action ?? '')?.group(1) ?? '';

    if (formhash == null || loginhash.isEmpty) {
      return (false, '无法解析登录表单');
    }

    final params = <String, dynamic>{
      'formhash': formhash,
      'referer': Urls.baseUrl,
      'loginfield': 'username',
      'username': username,
      'password': md5.convert(utf8.encode(password)).toString(),
      'questionid': '0',
      'answer': '',
      'cookietime': '315360000',
    };

    // 如果有验证码，附加参数
    if (seccodeHash != null && seccodeVerify != null) {
      params['seccodehash'] = seccodeHash;
      params['seccodeverify'] = seccodeVerify;
    }

    // Step 2: POST 登录请求
    final (ok, body) = await _api.post(
      "${Urls.loginUrl}&loginsubmit=yes&loginhash=$loginhash&inajax=1",
      params: params,
    );

    if (!ok) return (false, '登录请求失败');

    // Step 3: 直接解析 POST 响应（方案 A，与 iOS 原版一致）
    // iOS 参考：LoginViewController.swift#loginClick -> loginResult
    if (body.contains('欢迎您回来')) {
      // 登录成功，从响应中提取用户信息
      // 响应格式示例：
      //   <p>欢迎您回来，<font color="#0099FF">实习版主</font> 激萌路小叔，现在将转入登录前页面</p>
      //   或：<p>欢迎您回来，实习版主 激萌路小叔，现在将转入登录前页面</p>
      //   以及包含 home.php?mod=space&uid=XXX 和 formhash=XXXX 的链接
      // 提取 formhash（用于后续 API 调用）
      final formhashMatch = RegExp(r'formhash=(\w{6,8})').firstMatch(body);
      final newFormhash = formhashMatch?.group(1);

      // 提取用户名（从"欢迎您回来"后的内容中）
      String uname = username;
      final welcomeMatch = RegExp(r'欢迎您回来[，,]\s*(.+)').firstMatch(body);
      if (welcomeMatch != null) {
        final welcomeText = welcomeMatch.group(1)!;
        // 去掉 HTML 标签，取最后的用户名部分
        final cleanText = welcomeText
            .replaceAll(RegExp(r'<[^>]+>'), ' ')
            .trim();
        final parts = cleanText.split(RegExp(r'[，,\s]+'));
        if (parts.isNotEmpty) uname = parts.last.trim();
      }

      // 提取 uid：先从响应中找
      int uid = 0;
      final uidMatch = RegExp(
        r'home\.php\?mod=space[&\w=]*uid=(\d+)',
      ).firstMatch(body);
      if (uidMatch != null) {
        uid = int.parse(uidMatch.group(1)!);
      }

      // Fallback: AJAX 响应可能不含 uid 链接，访问用户空间页面获取
      if (uid == 0) {
        _api.talker.info('响应中未找到 uid，尝试从用户空间页面获取...');
        final (spaceOk, spaceBody) = await _api.get(
          '${Urls.baseUrl}home.php?mod=space',
        );
        if (spaceOk) {
          // 格式1: home.php?mod=space&uid=XXX
          final spaceUid = RegExp(
            r'home\.php\?mod=space[&\w=]*uid=(\d+)',
          ).firstMatch(spaceBody);
          if (spaceUid != null) {
            uid = int.parse(spaceUid.group(1)!);
          }
          // 格式2: space-uid-XXX.html
          if (uid == 0) {
            final altUid = RegExp(r'space-uid-(\d+)').firstMatch(spaceBody);
            if (altUid != null) {
              uid = int.parse(altUid.group(1)!);
            }
          }
          // 格式3: JSON "uid": XXX
          if (uid == 0) {
            final jsonUid = RegExp(r'"uid"\s*:\s*(\d+)').firstMatch(spaceBody);
            if (jsonUid != null) {
              uid = int.parse(jsonUid.group(1)!);
            }
          }
        }
      }

      _api.talker.info(
        '登录成功: uid=$uid, username=$uname, formhash=${newFormhash ?? _api.formhash}',
      );

      if (uid > 0) {
        await _settings.saveLogin(
          uid: uid,
          username: username,
          formhash: newFormhash ?? _api.formhash ?? '',
          password: password,
        );
      } else {
        _api.talker.warning('无法获取 uid，saveLogin 未执行！');
      }
      return (true, null);
    } else if (body.contains('验证码填写错误')) {
      return (false, '验证码填写错误');
    } else if (body.contains('登录失败') && body.contains('您还可以尝试')) {
      final errorMatch = RegExp(r'登录失败.*?</p>', dotAll: true).firstMatch(body);
      final errorText = errorMatch?.group(0) ?? '登录失败';
      final cleanError = errorText.replaceAll(RegExp(r'<[^>]+>'), '').trim();
      return (false, cleanError);
    } else if (body.contains('密码错误次数过多')) {
      final errorMatch = RegExp(
        r'密码错误次数过多.*?</p>',
        dotAll: true,
      ).firstMatch(body);
      final errorText = errorMatch?.group(0) ?? '密码错误次数过多';
      final cleanError = errorText.replaceAll(RegExp(r'<[^>]+>'), '').trim();
      return (false, cleanError);
    } else {
      return (false, '账号或密码错误');
    }
  }

  // =========================================================================
  // 板块列表
  // =========================================================================

  Future<List<ForumGroup>> getForumList() async {
    final (ok, body) = await _api.get(Urls.forumlistUrl);
    if (!ok) {
      _api.talker.warning('板块列表网络请求失败，使用本地 JSON 兜底');
      return _loadForumListFromJson();
    }

    final groups = _parseForumListHtml(body);
    if (groups.isEmpty) {
      _api.talker.warning('板块列表 HTML 解析为空，使用本地 JSON 兜底');
      return _loadForumListFromJson();
    }

    _api.talker.info('板块列表解析成功: ${groups.length} 个分组');
    return groups;
  }

  /// 解析论坛板块列表 HTML
  ///
  /// 同时兼容桌面版 `forumdisplay` 链接与移动端
  /// `forum-<fid>-1.html` 链接。
  List<ForumGroup> _parseForumListHtml(String html) {
    final doc = html_parser.parse(html);
    final groups = <ForumGroup>[];

    String extractLastText(dom.Element el) {
      String last = '';
      for (final node in el.nodes) {
        if (node is dom.Text) {
          final t = node.data.trim();
          if (t.isNotEmpty) last = t;
        } else if (node is dom.Element) {
          final t = node.text.trim();
          if (t.isNotEmpty) last = t;
        }
      }
      return last;
    }

    int extractForumId(String href) {
      final mobileMatch = RegExp(r'forum-(\d+)').firstMatch(href);
      if (mobileMatch != null) {
        return int.parse(mobileMatch.group(1)!);
      }

      final classicMatch = RegExp(r'fid=(\d+)').firstMatch(href);
      if (classicMatch != null) {
        return int.parse(classicMatch.group(1)!);
      }

      return 0;
    }

    /// TODO: Add parse for 106
    int normalizeForumId(int fid) {
      return fid == 106 ? 110 : fid;
    }

    List<Forum> parseForumLinks(dom.Element container) {
      final forums = <Forum>[];
      for (final a in container.querySelectorAll('a')) {
        final href = a.attributes['href'] ?? '';
        if (href.isEmpty) continue;

        final fid = normalizeForumId(extractForumId(href));
        if (fid <= 0) continue;

        final name = extractLastText(a);
        if (name.isEmpty) continue;

        forums.add(Forum(fid: fid, name: name));
      }
      return forums;
    }

    // 策略 1: 移动版板块列表（subforumshow + sub_forum）
    final titleBlocks = doc.querySelectorAll('.subforumshow');
    _api.talker.debug('找到 .subforumshow 数量: ${titleBlocks.length}');

    for (int i = 0; i < titleBlocks.length; i++) {
      final titleEl = titleBlocks[i];
      final titleText =
          titleEl.querySelector('h2 a')?.text.trim() ??
          titleEl.querySelector('h2')?.text.trim() ??
          '板块 $i';

      final forumsDiv = titleEl.nextElementSibling;
      if (forumsDiv == null) continue;

      final forums = parseForumLinks(forumsDiv);
      if (forums.isNotEmpty) {
        groups.add(ForumGroup(fgId: i, name: titleText, forums: forums));
      }
    }

    // 策略 2: 桌面版板块列表（bbs-forum-title + 下一个兄弟 div）
    if (groups.isEmpty) {
      final titleElements = doc.querySelectorAll('h2.bbs-forum-title');
      _api.talker.debug('找到 h2.bbs-forum-title 数量: ${titleElements.length}');

      for (int i = 0; i < titleElements.length; i++) {
        final titleEl = titleElements[i];
        final titleText = titleEl.children.isNotEmpty
            ? titleEl.children.first.text.trim()
            : titleEl.text.trim();

        final forumDiv = titleEl.nextElementSibling;
        if (forumDiv == null) continue;

        final forums = parseForumLinks(forumDiv);
        if (forums.isNotEmpty) {
          groups.add(ForumGroup(fgId: i, name: titleText, forums: forums));
        }
      }
    }

    // 策略 3: select 元素中的 option（备用）
    if (groups.isEmpty) {
      final selects = doc.querySelectorAll('select[id]');
      for (int i = 0; i < selects.length; i++) {
        final select = selects[i];
        final forums = parseForumLinks(select);
        if (forums.isNotEmpty) {
          final title = select.previousElementSibling?.text.trim() ?? '板块 $i';
          groups.add(ForumGroup(fgId: i, name: title, forums: forums));
        }
      }
    }

    // 策略 4: .bm_c 区域降级匹配
    if (groups.isEmpty) {
      final sections = doc.querySelectorAll('.bm_c');
      for (int i = 0; i < sections.length; i++) {
        final section = sections[i];
        final forums = parseForumLinks(section);
        if (forums.isEmpty) continue;

        final title =
            section.parent?.querySelector('h2')?.text.trim() ?? '板块 $i';
        groups.add(ForumGroup(fgId: i, name: title, forums: forums));
      }
    }

    return groups;
  }

  /// 从本地 assets/forums.json 加载板块列表（兜底方案）
  ///
  /// 与 Android 版 RuisUtils.getForums() 一致，
  /// 当网络请求失败或 HTML 解析失败时使用。
  Future<List<ForumGroup>> _loadForumListFromJson() async {
    try {
      final jsonStr = await rootBundle.loadString(
        'assets/ruisi_flutter/forums.json',
      );
      final List<dynamic> jsonList = json.decode(jsonStr);
      final groups = <ForumGroup>[];
      for (int i = 0; i < jsonList.length; i++) {
        final group = jsonList[i] as Map<String, dynamic>;
        final name = group['name'] as String;
        final forumList = (group['forums'] as List<dynamic>).map((f) {
          final map = f as Map<String, dynamic>;
          return Forum(fid: map['fid'] as int, name: map['name'] as String);
        }).toList();
        if (forumList.isNotEmpty) {
          groups.add(ForumGroup(fgId: i, name: name, forums: forumList));
        }
      }
      _api.talker.info('从本地 JSON 加载板块列表成功: ${groups.length} 个分组');
      return groups;
    } catch (e) {
      _api.talker.error('从本地 JSON 加载板块列表失败: $e');
      return [];
    }
  }

  /// 获取发帖页面元信息（主题分类、上传凭证等）
  Future<PostPageMeta> loadNewPostMeta(int fid) async {
    final (ok, body) = await _api.get(Urls.newPostUrl(fid));
    if (!ok) {
      throw Exception('获取发帖页面失败');
    }

    final doc = html_parser.parse(body);

    final freshFormhash = doc
        .querySelector('input[name="formhash"]')
        ?.attributes['value'];
    if (freshFormhash != null) {
      _api.formhash = freshFormhash;
    }

    final typeOptions = <ForumTypeOption>[];
    for (final option in doc.querySelectorAll('#typeid option')) {
      final value = option.attributes['value'];
      final id = int.tryParse(value ?? '');
      final name = option.text.trim();
      if (id != null && id > 0 && name.isNotEmpty) {
        typeOptions.add(ForumTypeOption(id: id, name: name));
      }
    }

    String? uploadUid;
    String? uploadHash;
    final uploadMatch = RegExp(
      r'uploadformdata:\s*\{uid:\s*"(\d+)",\s*hash:\s*"([^"]+)"\}',
    ).firstMatch(body);
    if (uploadMatch != null) {
      uploadUid = uploadMatch.group(1);
      uploadHash = uploadMatch.group(2);
    }

    String? seccodeHash;
    final seccodeMatch = RegExp(r'updateseccode\(([^)]+)\)').firstMatch(body);
    if (seccodeMatch != null) {
      seccodeHash = seccodeMatch.group(1);
    }

    return PostPageMeta(
      typeOptions: typeOptions,
      uploadUid: uploadUid,
      uploadHash: uploadHash,
      seccodeHash: seccodeHash,
      formhash: freshFormhash,
    );
  }

  // =========================================================================
  // 帖子列表
  // =========================================================================

  Future<PostPageMeta> loadReplyUploadMeta(int tid) async {
    final url =
        '${Urls.baseUrl}forum.php?mod=post&action=reply&tid=$tid&mobile=2';
    final (ok, body) = await _api.get(url);
    if (!ok) {
      throw Exception('获取回复页面失败');
    }

    final doc = html_parser.parse(body);

    final freshFormhash = doc
        .querySelector('input[name="formhash"]')
        ?.attributes['value'];
    if (freshFormhash != null) {
      _api.formhash = freshFormhash;
    }

    String? uploadUid;
    String? uploadHash;
    final uploadMatch = RegExp(
      r'uploadformdata:\s*\{uid:\s*"(\d+)",\s*hash:\s*"([^"]+)"\}',
    ).firstMatch(body);
    if (uploadMatch != null) {
      uploadUid = uploadMatch.group(1);
      uploadHash = uploadMatch.group(2);
    }

    final fidMatch = RegExp(r'fid=(\d+)').firstMatch(body);
    final fid = fidMatch?.group(1);

    return PostPageMeta(
      typeOptions: const [],
      uploadUid: uploadUid,
      uploadHash: uploadHash,
      formhash: freshFormhash,
      fid: fid,
    );
  }

  /// 板块帖子
  Future<List<Topic>> getTopicList(int fid, {int page = 1}) async {
    final (ok, body) = await _api.get('${Urls.getPostsUrl(fid)}&page=$page');
    if (!ok) return [];
    return _parseTopicList(body);
  }

  /// 热帖
  Future<List<Topic>> getHotTopics() async {
    final (ok, body) = await _api.get(Urls.hotUrl);
    if (!ok) return [];
    return _parseTopicList(body);
  }

  /// 最新帖子
  Future<List<Topic>> getNewTopics({int page = 1}) async {
    final (ok, body) = await _api.get('${Urls.newUrl}&page=$page');
    if (!ok) return [];
    return _parseGuideTopicList(body);
  }

  /// 最新回复
  Future<List<Topic>> getNewReplyTopics({int page = 1}) async {
    final (ok, body) = await _api.get('${Urls.newReplyUrl}&page=$page');
    if (!ok) return [];
    return _parseGuideTopicList(body);
  }

  Future<List<Topic>> getMyTopics({int page = 1}) async {
    final (ok, body) = await _api.get('${Urls.getMyPostsUrl}&page=$page');
    if (!ok) return [];
    return _parseGuideTopicList(body);
  }

  /// 收藏列表
  Future<List<Topic>> getFavorites({int page = 1}) async {
    final (ok, body) = await _api.get('${Urls.starUrl}&page=$page');
    if (!ok) return [];
    return _parseTopicList(body);
  }

  List<Topic> _parseTopicList(String html) {
    final doc = html_parser.parse(html);
    final topics = <Topic>[];

    // 策略1: 桌面端 forumdisplay 页面 (板块帖子列表)
    // 容器: div#threadlist
    // 行结构: <tbody id="normalthread_xxx|stickthread_xxx">
    //   <tr>
    //     <td class="icn">       → 跳过
    //     <th class="common|new"> → 标题 (a.s.xst) + 分类标签
    //     <td class="by">         → 作者 + 发布日期
    //     <td class="num">        → 回复数 + 浏览数
    //     <td class="by">         → 最后回复人 + 时间
    //   </tr>
    // </tbody>
    final threadlist = doc.querySelector('#threadlist');
    if (threadlist != null) {
      for (final tbody in threadlist.querySelectorAll('tbody')) {
        final id = tbody.id;
        if (id == 'separatorline') {
          continue;
        }
        if (!id.startsWith('normalthread_') && !id.startsWith('stickthread_')) {
          continue;
        }

        final tr = tbody.querySelector('tr');
        if (tr == null) continue;

        // 找 th（标题列）
        dom.Element? th;
        for (final c in tr.children) {
          if (c.localName == 'th') {
            th = c;
            break;
          }
        }
        if (th == null) continue;

        // 标题: a.s.xst
        final titleLink = th.querySelector('a.s.xst');
        if (titleLink == null) continue;
        final title = titleLink.text.trim();
        final href = titleLink.attributes['href'] ?? '';
        final tidMatch = RegExp(r'tid=(\d+)').firstMatch(href);
        if (tidMatch == null || title.isEmpty) continue;

        // 分类标签
        final tagLink = th.querySelector('em a[href*="forumdisplay"]');
        final categoryName = tagLink?.text.trim();

        // td.by 列表
        final byCells = <dom.Element>[];
        for (final c in tr.children) {
          if (c.localName == 'td' && c.classes.contains('by')) {
            byCells.add(c);
          }
        }

        // 第1个 td.by: 作者 + 发布日期
        String author = '未知';
        int authorId = 0;
        String? postTime;
        if (byCells.isNotEmpty) {
          final authorLink = byCells[0].querySelector('cite a');
          author = authorLink?.text.trim() ?? '未知';
          final authorHref = authorLink?.attributes['href'] ?? '';
          final uidMatch = RegExp(r'uid[=:\-](\d+)').firstMatch(authorHref);
          if (uidMatch != null) authorId = int.parse(uidMatch.group(1)!);
          postTime = byCells[0].querySelector('em span')?.text.trim();
        }

        // td.num: 回复数 + 浏览数
        int replies = 0;
        int views = 0;
        for (final c in tr.children) {
          if (c.localName == 'td' && c.classes.contains('num')) {
            replies =
                int.tryParse(c.querySelector('a')?.text.trim() ?? '') ?? 0;
            views = int.tryParse(c.querySelector('em')?.text.trim() ?? '') ?? 0;
            break;
          }
        }

        // 最后回复时间
        String? lastReplyTime;
        if (byCells.length >= 2) {
          lastReplyTime = byCells[1].querySelector('em')?.text.trim();
        }

        // 置顶标记
        final isStick = id.startsWith('stickthread_');

        topics.add(
          Topic(
            tid: int.parse(tidMatch.group(1)!),
            fid: 0,
            title: title,
            author: author,
            authorId: authorId,
            replies: replies,
            views: views,
            postTime: postTime,
            lastReplyTime: lastReplyTime,
            isStick: isStick,
            categoryName: categoryName,
          ),
        );
      }
    }

    // 策略2: 桌面端 guide 页面 (hot/new/newReply)
    // 结构: #threadlist 内的 li 元素，或 .bm_c 下的列表
    if (topics.isEmpty) {
      final guideItems = doc.querySelectorAll(
        '#threadlist li, .threadlist li, .bm_c .tl li, .bm_c ul li',
      );
      for (final item in guideItems) {
        final link = item.querySelector('a[href*="viewthread"]');
        if (link == null) continue;

        final title = link.text.trim();
        final href = link.attributes['href'] ?? '';
        final tidMatch = RegExp(r'tid=(\d+)').firstMatch(href);
        if (tidMatch == null || title.isEmpty) continue;

        final authorEl = item.querySelector('a[href*="space"]');
        final author = authorEl?.text.trim() ?? '未知';
        final authorHref = authorEl?.attributes['href'] ?? '';
        final uidMatch = RegExp(r'uid[=:\-](\d+)').firstMatch(authorHref);

        // 尝试提取回复数
        int replies = 0;
        int views = 0;
        final numText =
            item.querySelector('.num, .nums, td:last-child')?.text ?? '';
        final numMatch = RegExp(r'(\d+)').allMatches(numText).toList();
        if (numMatch.isNotEmpty) {
          replies = int.tryParse(numMatch[0].group(1)!) ?? 0;
        }
        if (numMatch.length > 1) {
          views = int.tryParse(numMatch[1].group(1)!) ?? 0;
        }

        topics.add(
          Topic(
            tid: int.parse(tidMatch.group(1)!),
            fid: 0,
            title: title,
            author: author,
            authorId: uidMatch != null ? int.parse(uidMatch.group(1)!) : 0,
            replies: replies,
            views: views,
          ),
        );
      }
    }

    // 策略3: 通用降级匹配 - 任何包含 viewthread 链接的容器
    if (topics.isEmpty) {
      final allLinks = doc.querySelectorAll('a[href*="viewthread"]');
      final seenTids = <int>{};
      for (final link in allLinks) {
        final title = link.text.trim();
        final href = link.attributes['href'] ?? '';
        final tidMatch = RegExp(r'tid=(\d+)').firstMatch(href);
        if (tidMatch == null || title.isEmpty) continue;

        final tid = int.parse(tidMatch.group(1)!);
        if (seenTids.contains(tid)) continue;
        seenTids.add(tid);

        // 向上查找最近的容器来获取作者信息
        final container = link.parent?.parent;
        final authorEl = container?.querySelector('a[href*="space"]');
        final author = authorEl?.text.trim() ?? '未知';
        final authorHref = authorEl?.attributes['href'] ?? '';
        final uidMatch = RegExp(r'uid[=:\-](\d+)').firstMatch(authorHref);

        topics.add(
          Topic(
            tid: tid,
            fid: 0,
            title: title,
            author: author,
            authorId: uidMatch != null ? int.parse(uidMatch.group(1)!) : 0,
            replies: 0,
            views: 0,
          ),
        );
      }
    }
    return topics;
  }

  /// 解析导读页面（最新帖子 / 最新回复 / 热帖）
  ///
  /// 导读页面的列布局与板块页不同：
  ///   th > a.xst          标题
  ///   td.by[0]            版块/群组
  ///   td.by[1]            作者 + 发帖时间
  ///   td.num              回复/查看
  ///   td.by[2]            最后发表
  List<Topic> _parseGuideTopicList(String html) {
    final doc = html_parser.parse(html);
    final topics = <Topic>[];

    final threadlist = doc.querySelector('#threadlist');
    if (threadlist == null) return topics;

    for (final tbody in threadlist.querySelectorAll('tbody')) {
      final id = tbody.id;
      if (!id.startsWith('normalthread_') && !id.startsWith('stickthread_')) {
        continue;
      }

      final tr = tbody.querySelector('tr');
      if (tr == null) continue;

      // 收集所有 td.by 和 td.num
      final byCells = <dom.Element>[];
      dom.Element? numCell;
      for (final c in tr.children) {
        if (c.localName != 'td') continue;
        if (c.classes.contains('by')) {
          byCells.add(c);
        } else if (c.classes.contains('num')) {
          numCell = c;
        }
      }

      // 需要至少 3 个 td.by（版块、作者、最后发表）
      if (byCells.length < 3) continue;

      // 标题: th > a.xst
      dom.Element? th;
      for (final c in tr.children) {
        if (c.localName == 'th') {
          th = c;
          break;
        }
      }
      if (th == null) continue;

      final titleLink = th.querySelector('a.xst');
      if (titleLink == null) continue;
      final title = titleLink.text.trim();
      final href = titleLink.attributes['href'] ?? '';
      final tidMatch = RegExp(r'tid=(\d+)').firstMatch(href);
      if (tidMatch == null || title.isEmpty) continue;

      // td.by[0]: 版块/群组
      int fid = 0;
      String? categoryName;
      final forumLink = byCells[0].querySelector('a[href*="forumdisplay"]');
      if (forumLink != null) {
        categoryName = forumLink.text.trim();
        final fidMatch = RegExp(
          r'fid=(\d+)',
        ).firstMatch(forumLink.attributes['href'] ?? '');
        if (fidMatch != null) fid = int.parse(fidMatch.group(1)!);
      }

      // td.by[1]: 作者 + 发帖时间
      String author = '未知';
      int authorId = 0;
      String? postTime;
      final authorLink = byCells[1].querySelector('cite a');
      if (authorLink != null) {
        author = authorLink.text.trim();
        final authorHref = authorLink.attributes['href'] ?? '';
        final uidMatch = RegExp(r'uid[=:\-](\d+)').firstMatch(authorHref);
        if (uidMatch != null) authorId = int.parse(uidMatch.group(1)!);
      }
      // 优先取 span[title] 的绝对时间，fallback 到元素文本
      final postTimeEl = byCells[1].querySelector('em span');
      postTime = postTimeEl?.attributes['title'] ?? postTimeEl?.text.trim();

      // td.num: 回复/查看
      int replies = 0;
      int views = 0;
      if (numCell != null) {
        replies =
            int.tryParse(numCell.querySelector('a')?.text.trim() ?? '') ?? 0;
        views =
            int.tryParse(numCell.querySelector('em')?.text.trim() ?? '') ?? 0;
      }

      // td.by[2]: 最后发表
      String? lastReplyTime;
      final lastReplyEl = byCells[2].querySelector('em span');
      lastReplyTime =
          lastReplyEl?.attributes['title'] ?? lastReplyEl?.text.trim();

      final isStick = id.startsWith('stickthread_');

      topics.add(
        Topic(
          tid: int.parse(tidMatch.group(1)!),
          fid: fid,
          title: title,
          author: author,
          authorId: authorId,
          replies: replies,
          views: views,
          postTime: postTime,
          lastReplyTime: lastReplyTime,
          isStick: isStick,
          categoryName: categoryName,
        ),
      );
    }
    return topics;
  }

  // =========================================================================
  // 帖子详情
  // =========================================================================

  Future<TopicDetail> getTopicDetail(int tid, {int page = 1}) async {
    final (ok, body) = await _api.get('${Urls.getPostUrl(tid)}&page=$page');
    if (!ok) {
      return TopicDetail(
        tid: tid,
        fid: 0,
        title: '加载失败',
        author: '',
        authorId: 0,
        time: '',
      );
    }

    final doc = html_parser.parse(body);
    final title = doc.querySelector('#thread_subject')?.text.trim() ?? '';

    final posts = <Post>[];
    // Discuz 桌面端：每层楼是 <table id="pidXXX" class="plhin">
    // 遍历 table 而非 .plc，避免 pid 提取失败和嵌套重复
    final postTables = doc.querySelectorAll(
      '#postlist table[id^="pid"], #postlist table.plhin',
    );

    int index = (page - 1) * 30 + 1;
    for (final table in postTables) {
      // 从 table 的 id 提取 pid（格式: pid12345）
      final tableId = table.attributes['id'] ?? '';
      final pidMatch = RegExp(r'pid(\d+)').firstMatch(tableId);

      // 作者信息在 <td class="pls"> 侧栏中
      // Discuz 桌面端用户链接格式多样：
      //   - space-uid-XXX.html
      //   - home.php?mod=space&uid=XXX
      //   - space-username-XXX.html
      final pls = table.querySelector('td.pls');
      var authorEl = pls?.querySelector(
        'a[href*="space-uid"], a[href*="mod=space&uid"], a[href*="space&uid="]',
      );
      // 降级：pls 中任何包含 "space" 的链接
      authorEl ??= pls?.querySelector('a[href*="space"]');
      // 降级：pls 中带 target="_blank" 的第一个链接（通常是作者名）
      authorEl ??= pls?.querySelector('a[target="_blank"]');
      // 再降级：整个 table 中的空间链接（排除 .plc 内容区的链接）
      if (authorEl == null) {
        for (final a in table.querySelectorAll('a[href*="space"]')) {
          // 排除内容区的链接（手动遍历父元素检查）
          var parent = a.parent;
          var inContent = false;
          while (parent != null && parent != table) {
            final cls = parent.className;
            if (cls.contains('t_f') || cls.contains('postmessage')) {
              inContent = true;
              break;
            }
            parent = parent.parent;
          }
          if (!inContent &&
              !(a.attributes['href'] ?? '').contains('attachment')) {
            authorEl = a;
            break;
          }
        }
      }
      final author = authorEl?.text.trim() ?? '未知';
      final authorHref = authorEl?.attributes['href'] ?? '';
      final uidMatch = RegExp(r'uid[=:\-](\d+)').firstMatch(authorHref);

      // 头像：pls 区域中的 <img>（Discuz 桌面端头像通常在 .avatar 或 <a> 内的 <img>）
      String? avatar;
      final avatarImg = pls?.querySelector('.avatar img, img.avatar');
      avatar = avatarImg?.attributes['src'];
      // 降级：pls 中第一个带 src 且 src 包含 avatar/uc_server 的 img
      if (avatar == null) {
        for (final img in pls?.querySelectorAll('img') ?? []) {
          final src = img.attributes['src'] ?? '';
          if (src.contains('avatar') ||
              src.contains('uc_server') ||
              src.contains('ucenter')) {
            avatar = src;
            break;
          }
        }
      }
      // 确保头像 URL 是完整的
      if (avatar != null && !avatar.startsWith('http')) {
        avatar = '${Urls.baseUrl}$avatar';
      }

      // 帖子内容在 <td class="plc"> 中
      final plc = table.querySelector('td.plc');
      final contentEl = plc?.querySelector('.t_f, .postmessage');
      var content = contentEl?.innerHtml ?? '';

      // .pattl 包含附件（文件样式图片 / 纯文件），拼进 content
      // 由 topic_detail_page 的 _IgnoreJsOpExtension 统一渲染
      final pattl = plc?.querySelector('.pattl');
      if (pattl != null) {
        content += pattl.innerHtml;
      }

      // 时间在 plc 区域的 .authi em 中
      final timeEl = plc?.querySelector('.authi em, .postinfo em');

      // 提取图片列表（.t_f 内嵌图片 + .pattl 文件样式图片）
      final images = <ImageAttachment>[];
      final allImgs = [
        ...?contentEl?.querySelectorAll('img[file]'),
        ...?pattl?.querySelectorAll('img[file]'),
      ];
      for (final img in allImgs) {
        final file = img.attributes['file'] ?? img.attributes['src'] ?? '';
        if (file.isNotEmpty && !file.contains('smiley')) {
          images.add(
            ImageAttachment(
              aid: images.length,
              url: file.startsWith('http') ? file : '${Urls.baseUrl}$file',
              filename: file.split('/').last,
            ),
          );
        }
      }

      posts.add(
        Post(
          pid: pidMatch != null ? int.parse(pidMatch.group(1)!) : 0,
          tid: tid,
          authorId: uidMatch != null ? int.parse(uidMatch.group(1)!) : 0,
          author: author,
          avatar: avatar,
          time: timeEl?.text.trim() ?? '',
          content: content,
          images: images,
          index: index++,
        ),
      );
    }

    int maxPage = page;
    for (final link in doc.querySelectorAll('.pg a[href*="page="]')) {
      final m = RegExp(r'page=(\d+)').firstMatch(link.attributes['href'] ?? '');
      if (m != null) {
        final p = int.parse(m.group(1)!);
        if (p > maxPage) maxPage = p;
      }
    }

    return TopicDetail(
      tid: tid,
      fid: 0,
      title: title,
      author: posts.isNotEmpty ? posts.first.author : '',
      authorId: posts.isNotEmpty ? posts.first.authorId : 0,
      time: posts.isNotEmpty ? posts.first.time : '',
      posts: posts,
      currentPage: page,
      totalPages: maxPage,
    );
  }

  // =========================================================================
  // 收藏
  // =========================================================================

  Future<bool> addFavorite(int tid) async {
    final (ok, body) = await _api.post(
      Urls.addStarUrl(tid),
      params: {'addsubmit': 'true'},
    );
    return ok && !body.contains('error');
  }

  // =========================================================================
  // 回复
  // =========================================================================

  Future<bool> replyTopic(int tid, String content) async {
    return replyTopicWithAttachments(tid, content, const []);
  }

  Future<bool> replyTopicWithAttachments(
    int tid,
    String content,
    List<String> attachmentAids,
  ) async {
    final meta = await loadReplyUploadMeta(tid);
    _api.formhash = meta.formhash ?? _api.formhash;
    final fid = meta.fid ?? '2';

    // 2. 提交回复
    final (ok, body) = await _api.post(
      '${Urls.baseUrl}forum.php?mod=post&action=reply&fid=$fid&tid=$tid&extra=&replysubmit=yes&inajax=1&handlekey=fastpost',
      params: {
        'message': "$content\nXDYou客户端发送",
        'usesig': '1',
        for (final aid in attachmentAids) 'attachnew[$aid]': '',
      },
    );
    return ok && !body.contains('error');
  }

  // =========================================================================
  // 签到
  // =========================================================================

  /// 从 HTML 中解析 <b> 标签内的签到天数
  static int? _extractSignDays(String html, String keyword) {
    final index = html.indexOf(keyword);
    if (index == -1) return null;
    final substring = html.substring(index);
    final match = RegExp(r'<b>(\d+)</b>').firstMatch(substring);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  Future<SignResult> sign() async {
    // 1. 时间校验
    final hour = DateTime.now().hour;
    if (hour < 7) {
      return SignResult(message: '签到时间: 7:00-24:00');
    }

    // 2. 获取签到页面
    final (pageOk, pageBody) = await _api.get(Urls.signUrl);
    if (!pageOk) return SignResult(message: '签到请求失败');

    // 3. 检测是否已签到：
    //    未签到页面存在 <form id="qiandao"> 签到表单
    //    已签到页面表单被替换为提示信息
    final bool hasForm = pageBody.contains('id="qiandao"');

    if (!hasForm) {
      // 已签到 — 解析累计天数
      final totalDays = _extractSignDays(pageBody, '您累计已签到');
      final monthDays = _extractSignDays(pageBody, '您本月已累计签到');
      return SignResult(
        alreadySigned: true,
        message: '今日已签到',
        consecutiveDays: totalDays,
        monthDays: monthDays,
      );
    }

    // 4. 从签到页面提取 formhash（CSRF 令牌）
    final formhashMatch = RegExp(
      r'name="formhash"\s+value="(\w+)"',
    ).firstMatch(pageBody);
    final formhash = formhashMatch?.group(1) ?? _api.formhash ?? '';

    // 5. 提交签到（qdmode=3 不填写）
    final (ok, body) = await _api.post(
      Urls.signPostUrl,
      params: {
        'formhash': formhash,
        'qdxq': 'kx',
        'qdmode': '3',
        'operation': 'qiandao',
        'infloat': '1',
      },
    );

    if (!ok) return SignResult(message: '签到请求失败');

    // 6. 检测结果：提交后表单消失 = 签到成功
    if (body.contains('恭喜你签到成功') || !body.contains('id="qiandao"')) {
      final totalDays = _extractSignDays(body, '您累计已签到');
      final monthDays = _extractSignDays(body, '您本月已累计签到');
      return SignResult(
        alreadySigned: false,
        message: '签到成功',
        consecutiveDays: totalDays,
        monthDays: monthDays,
      );
    }

    // 7. 错误处理
    if (body.contains('您访问的页面无手机页面')) {
      return SignResult(message: '非校园网环境无法签到');
    }

    return SignResult(message: '签到失败，请重试');
  }

  // =========================================================================
  // 消息通知
  // =========================================================================

  Future<List<ReplyNotification>> getReplyNotifications() async {
    final (ok, body) = await _api.get(Urls.messageReply);
    if (!ok) return [];
    return _parseNotifications<ReplyNotification>(body, (args) {
      return ReplyNotification(
        id: args['id'],
        tid: args['tid'],
        title: args['title'],
        author: '',
        time: '',
        snippet: args['snippet'],
        pid: args['pid'],
        isNew: args['isNew'],
      );
    });
  }

  Future<List<AtNotification>> getAtNotifications() async {
    final (ok, body) = await _api.get(Urls.messageAt);
    if (!ok) return [];
    return _parseNotifications<AtNotification>(body, (args) {
      return AtNotification(
        id: args['id'],
        tid: args['tid'],
        title: args['title'],
        author: '',
        time: '',
        snippet: args['snippet'],
        pid: args['pid'],
        isNew: args['isNew'],
      );
    });
  }

  List<T> _parseNotifications<T>(
    String html,
    T Function(Map<String, dynamic>) factory,
  ) {
    final doc = html_parser.parse(html);
    final items = <T>[];
    int id = 0;

    for (final li in doc.querySelectorAll('li')) {
      final link = li.querySelector('a');
      if (link == null) continue;

      final href = link.attributes['href'] ?? '';
      final tidMatch = RegExp(r'tid=(\d+)').firstMatch(href);
      final pidMatch = RegExp(r'pid=(\d+)').firstMatch(href);

      items.add(
        factory({
          'id': id++,
          'tid': tidMatch != null ? int.parse(tidMatch.group(1)!) : 0,
          'title': link.text.trim(),
          'snippet': li.text.trim(),
          'pid': pidMatch != null ? int.parse(pidMatch.group(1)!) : 0,
          'isNew':
              li.classes.contains('new') || li.querySelector('.new') != null,
        }),
      );
    }
    return items;
  }

  // =========================================================================
  // 发帖
  // =========================================================================

  /// 发布新帖子
  ///
  /// 返回 (成功?, 错误/成功消息)
  Future<(bool, String?)> newPost(
    int fid,
    String subject,
    String message,
    List<String> attachmentAids,
    int? typeId,
  ) async {
    final meta = await loadNewPostMeta(fid);
    _api.formhash = meta.formhash ?? _api.formhash;

    // 2. 提交新帖
    final (ok, body) = await _api.post(
      '${Urls.baseUrl}forum.php?mod=post&action=newthread&fid=$fid&extra=&topicsubmit=yes&inajax=1',
      params: {
        'formhash': _api.formhash ?? '',
        'subject': subject,
        'message': "$message\nXDYou 睿思客户端发送",
        'allownoticeauthor': '1',
        'usesig': '1',
        if (typeId != null && typeId > 0) 'typeid': '$typeId',
        for (final aid in attachmentAids) 'attachnew[$aid]': '',
      },
    );

    if (!ok) return (false, '发帖请求失败');

    // Discuz 发帖成功后会 301 重定向到新帖子，或返回包含成功提示的 XML
    if (body.contains('error') || body.contains('错误')) {
      // 提取错误信息
      final errorMatch = RegExp(r'<!\[CDATA\[(.*?)\]\]>').firstMatch(body);
      final errorText = errorMatch?.group(1) ?? '发帖失败，请检查内容后重试';
      _api.talker.error('发帖失败: $errorText');
      return (false, errorText);
    }

    _api.talker.info('发帖成功: fid=$fid, subject=$subject');
    return (true, null);
  }

  // =========================================================================
  // 搜索
  // =========================================================================

  /// 首次搜索，返回 [SearchResult]（含结果列表、searchid、分页信息、错误信息）。
  Future<SearchResult> search(String keyword) async {
    final (ok, body) = await _api.postFollowRedirect(
      Urls.searchUrl,
      params: {'srchtxt': keyword, 'searchsubmit': 'yes'},
    );
    if (!ok) {
      return SearchResult(error: '网络请求失败');
    }

    // 频率限制
    if (body.contains('秒内只能进行一次搜索')) {
      return SearchResult(error: '搜索太频繁，请稍后再试');
    }

    // 无结果
    if (body.contains('没有找到匹配结果')) {
      return SearchResult(error: '没有找到匹配结果');
    }

    // 如果响应包含 searchid，说明返回了结果页或重定向页
    // POST 响应即为搜索结果页，直接解析
    return _parseSearchResults(body);
  }

  /// 翻页搜索
  Future<SearchResult> searchPage(
    String searchId,
    String keyword,
    int page,
  ) async {
    final (ok, body) = await _api.get(
      Urls.getSearchUrl(searchId, keyword, page: page),
    );
    if (!ok) return SearchResult(error: '翻页请求失败');
    return _parseSearchResults(body).copyWith(searchId: searchId);
  }

  /// 解析搜索结果页面（桌面版）。
  ///
  /// 实际桌面端 HTML 结构（Discuz! X3.2 search/thread.htm）：
  /// ```html
  /// <div class="slst mtw" id="threadlist"><ul>
  ///   <li class="pbw" id="1188318">
  ///     <h3 class="xs3">
  ///       <a href="forum.php?mod=viewthread&amp;tid=1188318&amp;highlight=二手">
  ///     新校区求购<strong><font color="#ff0000">二手</font></strong>电动车！！</a>
  ///     </h3>
  ///     <p class="xg1">0 个回复 - 0 次查看</p>
  ///     <p>内容摘要...</p>
  ///     <p>
  ///       <span>2026-5-25 14:15</span>
  ///       - <span><a href="space-uid-314082.html">一枚bottle</a></span>
  ///       - <span><a href="forum-110-1.html" class="xi1">普通交易区</a></span>
  ///     </p>
  ///   </li>
  /// </ul></div>
  /// ```
  SearchResult _parseSearchResults(String html) {
    final doc = html_parser.parse(html);
    final topics = <Topic>[];

    // 定位搜索结果容器
    final threadlist = doc.querySelector('#threadlist');
    if (threadlist != null) {
      for (final li in threadlist.querySelectorAll('li.pbw')) {
        // tid: 优先从 li.id 获取
        final liId = li.id;
        int tid = int.tryParse(liId) ?? 0;

        // 标题链接: h3.xs3 > a
        final titleLink = li.querySelector('h3.xs3 a');
        if (titleLink == null) continue;
        final title = titleLink.text.trim();
        if (title.isEmpty) continue;

        // tid 备选: 从 href 中提取
        if (tid == 0) {
          final href = titleLink.attributes['href'] ?? '';
          final tidMatch = RegExp(r'tid=(\d+)').firstMatch(href);
          if (tidMatch != null) tid = int.tryParse(tidMatch.group(1)!) ?? 0;
        }
        if (tid == 0) continue;

        // 统计: <p class="xg1">N 个回复 - N 次查看</p>
        int replies = 0;
        int views = 0;
        final statsP = li.querySelector('p.xg1');
        if (statsP != null) {
          final statsText = statsP.text;
          final nums = RegExp(r'\d+').allMatches(statsText).toList();
          if (nums.length >= 2) {
            replies = int.tryParse(nums[0].group(0)!) ?? 0;
            views = int.tryParse(nums[1].group(0)!) ?? 0;
          }
        }

        // 作者: <a href="space-uid-314082.html">一枚bottle</a>
        String author = '';
        int authorId = 0;
        final authorLink = li.querySelector('a[href*="space-uid-"]');
        if (authorLink != null) {
          author = authorLink.text.trim();
          final authorHref = authorLink.attributes['href'] ?? '';
          final uidMatch = RegExp(r'space-uid-(\d+)').firstMatch(authorHref);
          if (uidMatch != null) {
            authorId = int.tryParse(uidMatch.group(1)!) ?? 0;
          }
        }

        // 发帖时间: meta <p> 中第一个 <span>
        String? postTime;
        final allPs = li.querySelectorAll('p');
        for (final p in allPs) {
          if (p.classes.contains('xg1')) continue;
          final firstSpan = p.querySelector('span');
          if (firstSpan != null) {
            final text = firstSpan.text.trim();
            // 匹配日期格式: 2026-5-25 14:15
            if (RegExp(r'\d{4}-\d{1,2}-\d{1,2}').hasMatch(text)) {
              postTime = text;
              break;
            }
          }
        }

        // 板块: <a href="forum-110-1.html" class="xi1">普通交易区</a>
        String? categoryName;
        int categoryId = 0;
        final forumLink = li.querySelector('a.xi1');
        if (forumLink != null) {
          categoryName = forumLink.text.trim();
          final forumHref = forumLink.attributes['href'] ?? '';
          final fidMatch = RegExp(r'forum-(\d+)').firstMatch(forumHref);
          if (fidMatch != null) {
            categoryId = int.tryParse(fidMatch.group(1)!) ?? 0;
          }
        }

        topics.add(
          Topic(
            tid: tid,
            fid: categoryId,
            title: title,
            author: author,
            authorId: authorId,
            replies: replies,
            views: views,
            postTime: postTime,
            categoryName: categoryName,
            categoryId: categoryId,
          ),
        );
      }
    }

    // 分页: <div class="pgs cl mbm"><div class="pg">
    int currentPage = 1;
    int totalPage = 1;
    String? searchId;
    final pg = doc.querySelector('.pg');
    if (pg != null) {
      final strong = pg.querySelector('strong');
      if (strong != null) {
        currentPage = _extractNumber(strong.text) ?? 1;
      }
      // searchid: 从分页链接中提取
      for (final a in pg.querySelectorAll('a')) {
        final href = a.attributes['href'] ?? '';
        final sidMatch = RegExp(r'searchid=(\d+)').firstMatch(href);
        if (sidMatch != null) {
          searchId = sidMatch.group(1);
          break;
        }
      }
      final span = pg.querySelector('span[title]');
      if (span != null) {
        final titleAttr = span.attributes['title'] ?? '';
        totalPage = _extractNumber(titleAttr) ?? 1;
      }
      if (totalPage <= 1) {
        final allLinks = pg.querySelectorAll('a');
        for (final a in allLinks) {
          final pageMatch = RegExp(
            r'page=(\d+)',
          ).firstMatch(a.attributes['href'] ?? '');
          if (pageMatch != null) {
            final p = int.tryParse(pageMatch.group(1)!) ?? 1;
            if (p > totalPage) totalPage = p;
          }
        }
      }
    }

    return SearchResult(
      topics: topics,
      searchId: searchId,
      currentPage: currentPage,
      totalPage: totalPage,
    );
  }

  int? _extractNumber(String text) {
    final m = RegExp(r'\d+').firstMatch(text);
    return m != null ? int.tryParse(m.group(0)!) : null;
  }
}

/// 搜索结果，携带帖子列表、分页信息和错误信息。
class SearchResult {
  final List<Topic> topics;
  final String? searchId;
  final int currentPage;
  final int totalPage;
  final String? error;

  const SearchResult({
    this.topics = const [],
    this.searchId,
    this.currentPage = 1,
    this.totalPage = 1,
    this.error,
  });

  bool get hasError => error != null;
  bool get hasMore => currentPage < totalPage;

  SearchResult copyWith({
    List<Topic>? topics,
    String? searchId,
    int? currentPage,
    int? totalPage,
    String? error,
  }) {
    return SearchResult(
      topics: topics ?? this.topics,
      searchId: searchId ?? this.searchId,
      currentPage: currentPage ?? this.currentPage,
      totalPage: totalPage ?? this.totalPage,
      error: error ?? this.error,
    );
  }
}
