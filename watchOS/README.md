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
切换概览、课程列表、日视图、月视图和周视图，课程颜色与 Flutter 手机端
保持一致。

Watch App 支持简体中文、繁体中文和英语，并采用手机 App 当前实际生效语言。
日、周视图支持触摸和数码表冠连续翻页；周视图课程色块可打开可滚动详情。

`Widget/` 提供 Smart Stack 课程小组件，显示当前/下一节课程、地点、时间和
一周 5×7 点阵。小组件通过 App Group 读取手表 App 已校验并完整写入的缓存，
不自行发起网络或校园系统请求。

课程提醒由 iPhone 本地通知转发，Watch App 不重复调度同一提醒。

## 源代码结构

`Views/` 按页面和基础设施拆分，页面文件只保存自己的状态与布局：

- `RootScheduleView.swift`：顶层路由、同步提示、悬浮控件和详情覆盖层；
- `OverviewScheduleView.swift`、`CourseListView.swift`：概览与整学期列表；
- `DayScheduleView.swift`、`WeekScheduleView.swift`、
  `MonthScheduleView.swift`：日、周、月三个独立页面；
- `MonthCalendarData.swift`：月份网格模型、五段标记和运行时预热缓存；
- `CourseViews.swift`：课程卡片和课程详情；
- `CalendarPagingSupport.swift`：三个日历页面共用的横向分页、表冠和吸附算法；
- `InteractionAwareScrollView.swift`：列表与详情使用的滚动观察桥；
- `WatchInteractionSupport.swift`：统一触觉反馈和表冠连续会话语义。

共享分页文件不读取课表，页面文件不直接解析通信字典。需要修改动画参数时，
优先修改共用纯函数；需要修改具体页面内容时，只进入对应页面文件。

启动恢复完成后，Store 会准备当前月及前后两月的轻量窗口。月份页只消费这份
内存结果；课表更新时重建课程标记，确定性的日期网格继续复用。
