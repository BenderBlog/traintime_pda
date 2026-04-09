# Experiment Window State

相关代码：

- `lib/page/experiment/experiment_window.dart`
- `lib/controller/physics_experiment_controller.dart`
- `lib/controller/other_experiment_controller.dart`
- `lib/page/public_widget/cache_alerter.dart`
- `lib/page/public_widget/loading_alerter.dart`

## 总览

实验页不是读取一个统一状态对象，而是组合物理实验和其他实验两路实验源状态。每一路页面都会同时看两类信息：

1. 异步状态
   - `futureSignal.value`
2. 最后有效结果
   - `hasValid...`：有无具体结果；
   - `is...FromCache`：是否读自缓存；
   - `...FetchTime`：获取时间；
   - `...CacheHintKey`：缓存获取时候的提示。

## 每一路的页面语义状态

页面实际上把每一路解释成以下几类语义：

- `loading`：通过`state.isLoading == true`判断是否处于加载状态；
- `readyFresh`：有获得数据，且不是来自缓存，即`isCache == false`；
- `readyCache`：有获得数据，且来自缓存，即`isCache == true`；
- `fatalError`：获取过程出错，即`state is AsyncError`，且这一路没有任何有效数据。

“请求过程失败但成功回退缓存”在页面语义上属于 `readyCache`而不属于 `fatalError`。

## 页面总判断顺序

页面先做以下判断：

- `hasValidPhysics`：是否获得物理实验数据；
- `hasValidOther`：是否获得其他实验数据；
- `hasAnyValidData = hasValidPhysics || hasValidOther`：任一实验数据有无获得；
- `physicsLoading`：物理实验信息是否正在加载；
- `otherLoading`：其他实验信息是否在加载；
- `physicsFatalError`：物理实验信息是否有报错且无数据；
- `otherFatalError`：其他实验信息是否有报错且无数据。

然后进入两个大分支：

1. 无任何有效数据：根据`!hasAnyValidData`判断。若两路都是 `fatalError`，表示全部有报错，显示整体 `ReloadWidget`。否则代表还在加载，显示中间 `CircularProgressIndicator`。一般来说在这种状态下至少一路仍在 loading，则顶部叠加一个 `LoadingAlerter`。这块需要后期证实。
2. 至少一路有有效数据：根据`hasAnyValidData`判断。如有，先渲染实验内容列表，同时对于缓存数据显示`CacheAlerter`、对于报错的状况错误卡片。若任一路仍在 loading，则叠加一个统一 `LoadingAlerter`。

## LoadingAlerter

实验页始终只显示一个 `LoadingAlerter`，文案由 `_resolveLoadingHintKey(...)` 决定：

- 两路都在 loading：`experiment.fetching_hint_both`
- 物理实验 loading：`experiment.fetching_hint_physics`
- 其他实验 loading：`experiment.fetching_hint_other`
- 物理实验 loading 且其他实验 fatal error：`experiment.fetching_hint_physics_with_other_failed`
- 其他实验 loading 且物理实验 fatal error：`experiment.fetching_hint_other_with_physics_failed`

## CacheAlerter

实验页可以同时显示物理实验缓存提示和其他实验缓存提示两条缓存提示。如果`isPhysicsFromCache && physicsFetchTime != null`，显示一个`CacheAlerter`；如果`isOtherFromCache && otherFetchTime != null`，再显示一个`CacheAlerter`。

在提示词方面，物理实验的类型名称是：`experiment.physics_experiment`，其他实验的类型名称是：`experiment.other_experiment`。`CacheAlerter`的提示词优先使用控制器里的 `...CacheHintKey`，为空时退回 `local_cache_hint`。

## 错误卡片

### 物理实验错误

若为普通情况，显示`experiment.error_physics`。

如果碰到物理实验密码为空的状况，即`NoPasswordException(type: PasswordType.physicsExperiment)`，需显示专门的密码缺失卡片。该卡片自带一按钮，点击后打开物理实验输入对话框`ExperimentPasswordDialog`，用户输入后出发物理实验信息重新加载`PhysicsExperimentController.i.reloadPhysicsExperiment()`。

### 其他实验错误

其他实验目前没有特殊卡片逻辑，直接显示 `experiment.error_other`。

## 典型状态组合

| Physics | Other | UI |
|---|---|---|
| loading | loading | 无有效数据时显示转圈 + 一个 `LoadingAlerter` |
| readyCache | loading | 显示内容 + 物理实验缓存提示 + 一个 `LoadingAlerter` |
| readyFresh | readyCache | 显示内容 + 其他实验缓存提示 |
| fatalError | loading | 无有效数据时显示转圈 + “其他实验正在加载，物理实验加载失败” 或其对称文案 |
| fatalError | readyFresh | 显示内容 + 物理实验错误卡片 |
| fatalError | readyCache | 显示内容 + 缓存提示 + 错误卡片 |
| fatalError | fatalError | 整体 `ReloadWidget` |