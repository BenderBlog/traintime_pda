# Exam Window State

相关代码：

- `lib/page/exam/exam_info_window.dart`
- `lib/controller/exam_controller.dart`
- `lib/page/public_widget/cache_alerter.dart`
- `lib/page/public_widget/loading_alerter.dart`

## 总览

考试页是单数据源页面，页面同时读取两类信息：

1. 异步状态
   - `examInfoSignal.value`
2. 最后有效结果
   - `hasValidExamInfo`：有考试信息数据；
   - `isExamFromCache`：考试信息数据是否来自缓存；
   - `examFetchTime`：考试信息获取时间；
   - `examCacheHintKey`：一般来自缓存状态，考试信息附带的报错说明。

## 页面语义状态

页面实际上把考试页解释成以下四类语义：

- `loading`：处于加载状态，即`state.isLoading == true`，且当前没有任何有效数据；
- `readyFresh`：有获得数据并没有缓存，即`isCache == false`；
- `readyCache`：有获得数据且获得缓存，即`isCache == true`；
- `fatalError`：获取过程出错，即`state is AsyncError`，且当前没有任何有效数据。

“请求过程失败但成功回退缓存”在页面语义上属于 `readyCache`，而不属于 `fatalError`。

## 页面总判断顺序

页面先做以下判断：

- `hasValidExamInfo`：是否缓存信息；
- `state.isLoading`：目前是否在加载；
- `state is AsyncError`：目前是否有报错。

然后进入两个大分支：

1. 有有效数据：先渲染考试内容，然后判断有无缓存或加载状态。若当前结果来自缓存，则显示 `CacheAlerter`，若请求仍在 loading，则在已有内容上叠加一个 `LoadingAlerter`。
2. 无有效数据：若加载结束且有错误状况，即`state is AsyncError`，显示刷新组件`ReloadWidget`。否则显示刷新指示器`CircularProgressIndicator`

## 内容区状态

在 `hasValidExamInfo == true` 的前提下，页面再分两类内容：

- 若有时间的考试信息存在，即`subjects.isNotEmpty`，显示时间线内容；
- 若有时间的考试信息不存在，即`subjects.isEmpty`，显示“暂无考试安排”的空态。

时间线又分三块：

- 没有完成的考试`exam.not_finished`：使用 `isNotFinished`；
- 取消考试资格的考试`exam.unable_to_exam`：使用 `isDisQualified`，且仅在该类项目非空时显示；
- 已经完成的考试`exam.finished`：使用 `isFinished`。

## CacheAlerter

当满足以下条件时显示缓存提示：确实来自缓存，即`isFromCache == true`，和有缓存获取时间，即`fetchTime != null`。

考试页的缓存提示由两部分组成，原因和缓存时间。

1. 原因：优先使用i18n处理的缓存原因字符串`examCacheHintKey`，如果缓存原因字符串不存在`hintKey == null`或`hintKey == "local_cache_hint"`，则回退到`cache_reason_default`；
2. 缓存位置和时间：因为该类缓存在手机存储有缓存，使用`PlaceOfCache.device`，展示文案最终走 `local_cache_hint`。

## LoadingAlerter

加载提示器显示规则：

- 只有当已经有可展示数据，且当前请求仍在 loading 时，才显示 `LoadingAlerter`
- 文案固定使用 `exam.fetching_hint`
- 同时会叠加轻量遮罩和顶部提示条

无有效数据时不会额外显示顶部 loading 条，只显示中间转圈。

## 错误页

当状态有报错，即`state is AsyncError`且没有可显示数据（一般为缓存数据）即`hasValidExamInfo == false`时，页面进入 `ReloadWidget`。

如果当前请求失败但控制器里仍保留着历史有效结果，则页面不会进入错误页，而是继续显示旧内容。

## 顶部按钮

`AppBar` 上的按钮仅当有数据显示时候显示，包括刷新按钮和未安排时间的考试页面入口按钮。

## 典型状态组合

| State | UI |
|---|---|
| loading | 中间 `CircularProgressIndicator` |
| readyFresh | 显示考试内容，不显示缓存提示 |
| readyCache | 显示考试内容 + `CacheAlerter` |
| readyFresh + loading | 显示旧内容 + `LoadingAlerter` |
| readyCache + loading | 显示缓存内容 + `CacheAlerter` + `LoadingAlerter` |
| fatalError | `ReloadWidget` |
