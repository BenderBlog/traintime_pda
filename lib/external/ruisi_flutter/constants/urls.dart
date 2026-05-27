// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

/// 睿思论坛 API 地址常量
/// 基于 Discuz! 论坛系统
/// 仅校内网运行
class AppConstants {
  static const String appId = 'id1322805454';
  static const int postId = 921699;
  static const String hostRs = 'rs.xidian.edu.cn';
}

class Urls {
  static const String homePage = 'https://github.com/BenderBlog/ruisi_flutter';
  static const String baseUrl = 'https://rs.xidian.edu.cn/';

  // ---- 认证 ----
  static const String loginUrl =
      '${baseUrl}member.php?mod=logging&action=login';
  static const String checkLoginUrl =
      '${baseUrl}member.php?mod=logging&action=login&inajax=1';
  static const String forgetPasswordUrl =
      '${baseUrl}member.php?mod=lostpasswd&lostpwsubmit=yes&inajax=1';

  // ---- 签到 ----
  static const String signUrl = '${baseUrl}plugin.php?id=dsu_paulsign:sign';
  static const String signPostUrl =
      '${baseUrl}plugin.php?id=dsu_paulsign:sign&operation=qiandao&infloat=1&inajax=1';

  // ---- 首页 ----
  static const String hotUrl = '${baseUrl}forum.php?mod=guide&view=hot';
  static const String newUrl = '${baseUrl}forum.php?mod=guide&view=newthread';
  static const String newReplyUrl = '${baseUrl}forum.php?mod=guide&view=new';

  // ---- 板块 ----
  // 与 iOS 版本一致：使用 mobile=2 移动端接口，返回简洁 HTML
  static const String forumlistUrl =
      '${baseUrl}forum.php?inajax=1&forumlist=1&mobile=2';
  static String getPostsUrl(int fid) =>
      '${baseUrl}forum.php?mod=forumdisplay&fid=$fid';

  // ---- 帖子 ----
  static String getPostUrl(int tid, {int? pid}) {
    if (pid != null) {
      return '${baseUrl}forum.php?mod=redirect&goto=findpost&ptid=$tid&pid=$pid';
    }
    return '${baseUrl}forum.php?mod=viewthread&tid=$tid';
  }

  static String newPostUrl(int fid) =>
      '${baseUrl}forum.php?mod=post&action=newthread&fid=$fid';
  static const String editSubmitUrl =
      '${baseUrl}forum.php?mod=post&action=edit&extra=&editsubmit=yes';
  static String editPostUrl(int tid, int pid) =>
      '${baseUrl}forum.php?mod=post&action=edit&tid=$tid&pid=$pid';

  // ---- 消息 ----
  static const String messageReply =
      '${baseUrl}home.php?mod=space&do=notice&inajax=1';
  static const String messagePm = '${baseUrl}home.php?mod=space&do=pm';
  static const String messageAt =
      '${baseUrl}home.php?mod=space&do=notice&view=mypost&type=at&inajax=1';

  // ---- 聊天 ----
  static String getChatDetailUrl(int tuid) =>
      '${baseUrl}home.php?mod=space&do=pm&subop=view&touid=$tuid';
  static String postChatUrl(int tuid) =>
      '${baseUrl}home.php?mod=spacecp&ac=pm&op=send&pmid=$tuid&daterange=0&pmsubmit=yes';

  // ---- 收藏 ----
  static const String starUrl =
      '${baseUrl}home.php?mod=space&do=favorite&view=me';
  static String addStarUrl(dynamic tid) =>
      '${baseUrl}home.php?mod=spacecp&ac=favorite&type=thread&id=$tid&handlekey=favbtn&inajax=1';
  static String deleteStarUrl(int favid) =>
      '${baseUrl}home.php?mod=spacecp&ac=favorite&op=delete&favid=$favid&type=all&inajax=1';

  // ---- 用户 ----
  static String getMyPostsUrl(int? uid) {
    if (uid == null) {
      return '${baseUrl}forum.php?mod=guide&view=my';
    }
    return '${baseUrl}home.php?mod=space&uid=$uid&do=thread&view=me';
  }

  static const String myMoneyUrl =
      '${baseUrl}home.php?mod=spacecp&ac=credit&showcredit=1&inajax=1';
  static const String myReplysUrl =
      '${baseUrl}forum.php?mod=guide&view=my&type=reply&inajax=1';
  static const String friendsUrl = '${baseUrl}home.php?mod=space&do=friend';
  static String deleteFriendUrl(int uid) =>
      '${baseUrl}home.php?mod=spacecp&ac=friend&op=ignore&uid=$uid&confirm=1';
  static const String searchFriendUrl =
      '${baseUrl}home.php?mod=spacecp&ac=search&searchsubmit=yes';
  static String addFriendUrl(int uid) =>
      '${baseUrl}home.php?mod=spacecp&ac=friend&op=add&uid=$uid&inajax=1';
  static String getUserDetailUrl(dynamic uid) =>
      '${baseUrl}home.php?mod=space&uid=$uid&do=profile';
  static String getAvaterUrl(dynamic uid, {int size = 1}) {
    final sizeStr = size == 0
        ? 'small'
        : size == 2
        ? 'big'
        : 'middle';
    return 'https://rs.xidian.edu.cn/uc2_link/avatar.php?uid=$uid&size=$sizeStr';
  }

  // ---- 搜索 ----
  static const String searchUrl = '${baseUrl}search.php?mod=forum';
  static String getSearchUrl2(String searchId) =>
      '${baseUrl}search.php?mod=forum&searchid=$searchId&orderby=lastpost&ascdesc=desc&searchsubmit=yes';

  // ---- @列表 ----
  static const String atListUrl = '${baseUrl}misc.php?mod=getatuser&inajax=1';

  // ---- 图片上传 ----
  static const String uploadImageUrl =
      '${baseUrl}misc.php?mod=swfupload&operation=upload&type=image&inajax=yes&infloat=yes&simple=2';
  static String deleteUploadedUrl(String aid) =>
      '${baseUrl}forum.php?mod=ajax&action=deleteattach&inajax=yes&aids[]=$aid';

  // ---- 验证码 ----
  static const String checkNewpostUrl =
      '${baseUrl}forum.php?mod=ajax&action=checkpostrule&ac=newthread';
  static String updateValidUrl(String update, String hash) =>
      '${baseUrl}misc.php?mod=seccode&update=$update&idhash=$hash';
  static String getValidUpdateUrl(String hash) =>
      '${baseUrl}misc.php?mod=seccode&action=update&idhash=$hash';
  static String checkValidUrl(String hash, String value) =>
      '${baseUrl}misc.php?mod=seccode&action=check&inajax=1&idhash=$hash&secverify=$value';
}
