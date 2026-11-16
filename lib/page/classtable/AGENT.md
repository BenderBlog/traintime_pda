<!--
 Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
 SPDX-License-Identifier: MPL-2.0
-->

# 智能体提示

针对此课程表组件，需要就接下来操作进行说明。

## 分层（动代码之前先看这里）

```
class_page/ · class_table_view/ · class_add/ · arrangement_detail/     视图
        │  只拿 ClasstableScope 和 state 的公开 getter
        ▼
model/classtable_widget_state.dart     状态：选中周、编排缓存、全部写操作
        │  只依赖端口，不认识 controller，不 import signals
        ▼
model/classtable_source.dart（端口） + model/classtable_snapshot.dart（快照）
        ▲
        │  实现
data/global_classtable_source.dart     ← 全目录唯一 import controller / signals 的文件
data/preview_classtable_source.dart    ← 设置页预览用的样例数据
```

## 规则

1. 设置配置按类型放在 `model/style_config/`，UI、`ClasstableWidgetState` 和具体配置类都不直接访问 `preference`。
   - 通过 `StyleConfigPreferenceFunctions` 注入 `getBool`、`getDouble`、`setBool`、`setDouble` 和 `contains`；应用启动边界把这些函数绑定到实际存储。
   - UI 通过对应 config 或 state 的公开方法读写设置。
   - 背景图选择/复制属于用户交互，可以留在设置页面；背景开关、模糊程度和文件状态由 `ClassTableBackgroundStyleConfig` 管理。
   - iCal 导出时 `FilePicker.saveFile` 属于用户交互，留在页面；`.ics` 内容由 state 生成。
2. 新的课程表组件基于 `InheritedNotifier`：共享状态由 `ClasstableScope` 提供。
   - build 里用 `ClasstableScope.of(context)`（会订阅，数据一变就重建）；
   - 回调里用 `ClasstableScope.read(context)`（不订阅，避免在事件处理里注册依赖）。
3. 外部数据通过参数注入，不写死在状态里：状态只认 `ClasstableDataSource` 端口，具体实现由构建页面的地方选择。
   - 预览页用 `PreviewClasstableDataSource`，**不要**再 `extends ClasstableWidgetState` 覆写 getter 造假数据。
   - 状态持有并负责 `dispose` 它拿到的 source；`ClassTableWindow(source: ...)` 是唯一的注入点。
   - 端口只要求必须实现 `snapshot` / `now` / `decorationFileName` / `dispose`；写操作有默认实现，不支持的来源直接抛错。
4. 响应式统一用 `ValueListenable` / `ValueNotifier` / `ChangeNotifier`。
   - `signals` 只允许出现在 `data/global_classtable_source.dart`：那里两条 `effect` 把 controller 的 signal 收成一份快照；
   - 页面与状态层不得 `import 'package:signals/...'`。
   - 「ChangeNotifier 里面套 ChangeNotifier」这一条暂时不动（`weekNavigationNotifier` 仍在状态里），以后再统一。
5. 非本人下命令，不要写任何测试代码、回归测试等。

## 新增代码放哪

| 要加的东西 | 放哪 |
| --- | --- |
| 新的数据来源 | 继承 `ClasstableDataSource`，放 `data/`，只覆盖自己能提供的部分 |
| 新的派生数据 / 加载状态字段 | 加进 `ClasstableSnapshot`（不可变，一次性带全） |
| 新的写操作 | 加进 `ClasstableWidgetState`，再由端口转发给 controller |
| 新的样式可调项 | 放进 `model/style_config/` 对应类型文件，由 config 负责默认值、校验和调用注入的存取函数 |
| 新的纯查询（按周/日算数据） | 放 `model/`，写成接收列表参数的纯函数（参考 `custom_class_occurrence.dart`） |

## 已知待办

- 样式配置拆在 `model/style_config/`：`current_time_indicator_style_config.dart`、`class_card_style_config.dart`、`glass_style_config.dart`、`class_table_background_style_config.dart`、`week_bar_style_config.dart`。进行中与已完成课程卡片样式共用 `ClassCardStyleConfig`。
- `preference` 只由应用入口适配并注入 `StyleConfigPreferenceFunctions`；具体 style config 不导入 preference。
- 背景文件的定位、存在性检查与元数据读取由 `ClassTableBackgroundStyleConfig` 负责；用户选择/复制文件的交互仍留在设置页。
- 待办：毛玻璃开关修改 `GlassStyleConfig` 静态值，设置页回调目前只重建设置预览，实际课表没有收到设置变更通知；暂时不做实时刷新，后续需补充共享的设置变更通知机制。
- `ClassTableSheet` 的 `semesterLength` / `pageControl` 仍由外部传入，和状态层的周导航是两套，收的时候一并处理。
- `arrangement_detail_state.dart` 是 `updateShouldNotify` 恒为 false 的旧式 InheritedWidget。
