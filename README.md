<div align="center">
<img src="./assets/icon.png" style="border-radius:10px; margin:10px; width:120px" alt="TrainTime PDA">
<h1>Traintime PDA</h1>

[![Release downloads](https://img.shields.io/github/downloads/BenderBlog/traintime_pda/total.svg)](https://GitHub.com/BenderBlog/traintime_pda/releases/) ![Android Version](https://img.shields.io/badge/Android%20API-23%2B-green)

Traintime PDA，又称 XDYou，是为西电学生设计的开源信息查询软件。

[临时主页地址](https://legacy.superbart.top/xdyou.html) 
</div>

[<img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg"
    alt="Get it on App Store"
    height="80">](https://apps.apple.com/us/app/xdyou/id6461723688?l=zh-Hans-CN)[<img src="https://raw.githubusercontent.com/f-droid/artwork/master/badge/get-it-on-zh-cn.svg"
    alt="Get it on F-Droid"
    height="80">](https://f-droid.org/zh_Hans/packages/io.github.benderblog.traintime_pda/)

## 特性概览

1. 支持查看本科生和研究生的课程信息，成绩信息，考试信息。
2. 查看日程表：包括课程信息，考试信息。顺便把你偶像的图片设成背景。（以及导入你对象的课表，写完真虐心啊）
3. 查看体育信息：体育课程信息和体测成绩记录。（打卡机在人世间完成了一个轮回）
4. 查看宿舍电量，顺手交电费同时可以查看过去七次获取的记录。（研究生需要自行输入电费账号）
5. 查看成绩，包括可以自行选择科目计算均分。
6. 考试安排查询。
7. 查询空闲教室。
8. 图书馆信息查询：个人借书状况和学校书库状况。
9. 校园卡流水查询以及直接扣除校园卡余额的付款码。
10. 其他小功能：请假，报修之类。
11. XDU Planet：查看同学的博客。
12. 物理实验查看功能。
13. 查询校园网用量，包括目前在线账号和用户自己的账号。（用户自己账号需要输入密码方可查询）
14. Android 和 iOS 特有的日程查看桌面小部件。
15. 完备的国际化支持：支持繁体中文和英语。

## 其他特性

1. 代码完全开源，没有任何遥测和埋点。本程序使用上只是模拟浏览器浏览网页，并将数据经过了很轻，很透明的处理。
2. 使用广受赞誉的 Flutter SDK，跨平台而且性能高。目前本程序能支持 Android，iOS 平台，同时有社区构建的 Windows，Linux 平台。
3. 受益于 Flutter 跨平台，本程序专门为平板和桌面设计适配了[Master-Detail View](https://blogs.windows.com/windowsdeveloper/2017/05/01/master-master-detail-pattern/)，使其在平板和桌面使用更自然。如果你是桌面用户，你不用专门去一站式看成绩了。
4. 开发者很不正经，而且相信群众的力量。本程序融合了除开发者之外到了十余人的想法和功能。

## 不是西电的同志们如何利用代码？

1. `/lib/page/classtable`是本程序的课程表/日程表组件，您可以拿去用来渲染课表，这个表可以往里面塞考试信息等和课程时间不对应的玩意。
2. 可以修改`/lib/repository`里面的东西，以用来适配您的学校相关系统。
3. `/lib/page/library`是简单的图书馆页面，包括借书状况和查询书籍，可以修改一下成为某些课的大作业。
4. `/ios/ClasstableWidget`是一个 iOS 下面简单的显示日程插件，可以按需使用。数据来源可以参考我是如何把东西存到程序公共空间的。
5. `/lib/page/public_widget`有一堆不知所以的部件，看情况随便用。

使用前看下文件的授权，以`SPDX-License-Identifier`开头。如果只有`MPL-2.0`而且你不方便开源**仅对这一个文件的修改**的话，和我联系。

计划写一个本代码的查看指南，请各位期待。

## 编译环境

```bash
Flutter 3.32.2 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 8defaa71a7 (5 天前) • 2025-06-04 11:02:51 -0700
Engine • revision 1091508939 (9 天前) • 2025-05-30 12:17:36 -0700
Tools • Dart 3.8.1 • DevTools 2.45.1
```

## 授权信息

本程序源代码按照 MPLv2 授权，部分文件有 MIT / Apache-2.0 授权。

本代码库附带 XDYou 的图标和开屏图，该图标和开屏图仅作为标识 iOS 授权者编译版本而使用。

编译产物中，Android 和其他平台产物称为 Traintime PDA，为自由软件。iOS 平台产物称为 XDYou，由于附带 XDYou 图标和开屏图，不允许非授权者以 XDYou 名义分发。

## 感谢名单

查看代码中`/lib/page/setting/about_page/about_page.dart`里面`getDevelopers`数组中的内容。

如果你对本程序啥想法，欢迎向我提出。
