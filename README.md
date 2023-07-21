# watermeter 水表

主页和下载地址：[https://legacy.superbart.xyz/xdyou.html](https://legacy.superbart.xyz/xdyou.html)
赞助地址：[http://afdian.net/a/benderblog](http://afdian.net/a/benderblog)

(watermeter 是核心代号，项目最终成品将会是 Traintime PDA，或者是 XDYou)

西电同志们的又一个校内信息助手。

本软件的目标是利用[xidian-script](https://github.com/xdlinux/xidian-scripts)所提供的信息，加上我能力范围内能扩充的一些功能，来写一个纯本地的西电学子日常信息查看应用。

## 特性概览

### 校内服务
1. 根据[Timetable](https://github.com/zfman/TimetableView)重写的 Flutter 课程表。
2. 体育查询，打卡记录和体测成绩。
3. 成绩查询，包括可以自行选择科目计算均分。
4. 自行选择学期的考试安排查询。
5. 电量查询和欠费查询。
6. 校园卡流水查询和(如果有的话)校园卡余额查询。
7. 图书馆信息查询，个人借书状况和学校书库状况。

### 其他服务
1. XDU Planet：查看同学的博客，富含先辈的恩情（学习资料），另该功能代行转发学校教务处通知。
2. 西电目录，曾经在疫情封校期间运行的学校综合楼目录 + 食堂目录。

### 其他特性
1. 代码完全开源，结构清晰明了，[查看我程序的架构图](https://legacy.superbart.xyz/writing/XDYou%20SAD.html)。
2. 使用广受赞誉的 Flutter 架构，跨平台而且性能高。
3. 开发者很不正经()

# 编译环境

```bash
[superbart@superbart-laptop watermeter]$ flutter --version
Flutter 3.10.6 • channel stable • https://github.com/flutter/flutter.git
Framework • revision f468f3366c (9 天前) • 2023-07-12 15:19:05 -0700
Engine • revision cdbeda788a
Tools • Dart 3.0.6 • DevTools 2.23.1
```

注意：要编译此项目，Dart 编译器必须在 3.0 以上。

# 感谢名单

![](https://raw.githubusercontent.com/BenderBlog/watermeter/main/assets/Credit.jpg)

如果你对本程序啥想法，欢迎向我提出。
