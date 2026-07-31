# XDYou Apple Watch

本目录包含原生 SwiftUI watchOS Companion App 和 WidgetKit Smart Stack
小组件。完整架构、协议和维护说明见
[`docs/apple_watch_technical_overview.md`](../docs/apple_watch_technical_overview.md)。

iPhone 始终是课表数据源。Flutter 将课程、自定义课程、考试和实验展开为
完整学期快照，iOS 原生层负责持久化并响应 WatchConnectivity 请求。手表每次
进入前台后先发送本地已完整安装的课表版本。版本变化时依次获取：

1. 当天；
2. 近 14 天；
3. 分块传输的完整学期。

版本一致时手机只返回轻量确认，不重复发送课表正文。手表分别缓存三个同步
阶段；手机离线、未启动或同步中断时，已有页面和缓存不会被清空。三点按钮可
切换概览、课程列表、日视图和周视图，课程颜色与 Flutter 手机端保持一致。

Watch App 支持简体中文、繁体中文和英语，并采用手机 App 当前实际生效语言。
日、周视图支持触摸和数码表冠连续翻页；周视图课程色块可打开可滚动详情。

`Widget/` 提供 Smart Stack 课程小组件，显示当前/下一节课程、地点、时间和
一周 5×7 点阵。小组件通过 App Group 读取手表 App 已校验并完整写入的缓存，
不自行发起网络或校园系统请求。

课程提醒由 iPhone 本地通知转发，Watch App 不重复调度同一提醒。
