# AppShell 设计

## 概览

`AppShell` 是进入应用后的页面骨架，负责页面切换和自适应的详情区域。首页网格组件的骨架在 `shared/widgets/layouts/grid_page.dart` 中提供组件本体及其参数接口，由调用方实现接口并传入 `GridPage` ，然后将 `GridPage` 作为组件组装到 `AppShell` 实现从组件到页面到骨架的拼装

页面内容由各 feature 提供。`AppShell` 不导入功能模块，也不持有任何业务数据。本设计遵循[项目架构](../../../.agents/skills/pda-v2-coding-principles/references/architecture.md)中 `core` 与功能模块的依赖边界的设计。

## 页面接口

`core/presentation/` 定义面向界面的 `AppShellPageInterface` 接口。每个实现提供导航标签、普通与选中图标，以及构建页面内容的方法。标签和页面内容在构建时取得 `BuildContext`，以便响应语言与主题变化。

`AppShell` 只接收 `AppShellPageInterface` 的实现，不根据页面类型决定如何构建内容。它接收至少一个的页面，否则使用 `PlaceHolder()` 创建一个默认页面 `DefaultAppShellPage` 并在 Debug 模式下触发断言错误。页面顺序按数组的顺序。`AppShell` 管理当前页、`PageView` 和导航栏，并保持滑动与点击导航时的选中状态一致。

本次重构在宽屏和窄屏都沿用旧版的底部导航栏。主从详情区域，即 [Master-Detail View](https://blogs.windows.com/windowsdeveloper/2017/05/01/master-master-detail-pattern/) 仍按可用宽度切换布局。

启动装配创建页面实现并传给 `AppShell`，此步骤是 `main.dart` 直接依赖各个 feature，是特权设计。功能模块可以在自己的 presentation 层实现 `AppShellPage`，也可以向共享页面（即 `GridPage`，这是一个由 `core/widgets/layouts/grid_page.dart` 实现的一个 `AppShellPageInterface`，在 `main.dart` 中调用装配，并直接从各个 feature 中获取 widget，在 `main.dart` 范围内的特权结构）提供组件；功能模块只依赖 `core` 的页面接口和组件，不直接依赖其他功能模块。跨功能数据仍通过消费方 port、`integration/` 和启动装配接线。

## 主从详情导航

`AppShell` 提供旧版 `BasedSplitView` 所承担的应用级详情导航。宽屏左侧始终显示包含 `PageView` 和底部导航栏的主区域，右侧显示独立的二级页面路由栈。所属 feature 构建二级页面，`AppShell` 在详情路由栈中执行入栈、替换和出栈。窄屏用同一详情路由栈显示二级页面，并允许返回主区域。窗口宽度变化时保留路由栈，只改变其呈现方式。布局切换依据两侧内容所需的最小宽度，不照搬某个平台的固定断点。

`AppShell` 通过 `core/presentation/app_shell.dart` 定义的方法提供详情路由的入栈、替换和出栈操作。功能页面用这些方法入栈页面，`AppShell` 将其放入详情区域。普通的根路由仍用于登录等需要覆盖整个应用的页面。Flutter 的 `Navigator.of(context)` 查找最近的 `Navigator`，不能只凭调用位置推断它会打开详情。实现可以在 `AppShell` 内使用局部 `Navigator`，但必须让详情操作明确指向它或等效的详情状态。feature 页面不创建全局 `Navigator` 键，也不应该为了支持详情而扩充 `AppShellPageInterface` 接口。

没有详情的页面照常使用。返回操作弹出详情路由栈的栈顶；切换 `PageView` 当前页面不清空详情路由栈。

`AppShell` 只管理详情路由栈和宽窄布局。选中的实体、详情数据及操作仍由所属功能管理。feature 提供详情页面时，应通过自身的 application 和注入的依赖取得数据，`AppShell` 不读取业务模型。

## 内置页面与共享组件

`core/shared/widgets/` 提供一个 `AppShellPage` 实现。

| 页面实现 | 接收的内容 | 负责的布局 |
| --- | --- | --- |
| 网格页 | 卡片组件及各卡片的 Flex 宽度 | 网格列宽、卡片占位和响应式布局 |

卡片用返回 `Widget` 函数和返回整数 `flex` 函数的接口表示。`flex` 只表达卡片希望占用的相对宽度，现在只能取值 [1,4]；网格页根据可用宽度计算实际尺寸，并在入口拒绝无效权重。卡片的内容、业务交互和数据归属仍由提供该卡片的功能负责。卡片的排序、隐藏等规则若需要持久化，通过注入实现的 `PreferenceStoreInterface` 获得持久化能力。

## 职责边界

- `AppShell` 决定页面顺序、切换行为和详情区域的布局，不计算网格尺寸或者持久化。
- `core/shared/layouts/` 实现通用布局，不读取 feature 模块的数据。
- 各功能的 presentation 层创建卡片或其他页面内容，使用共享组件时只从 `core` 导入。
- 启动装配汇集页面与组件，注入它们需要的依赖，再创建 `AppShell`。
