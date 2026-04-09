# FetchResult

相关代码：`lib/model/fetch_result.dart`。

仓库层对 UI 的统一输出是 `FetchResult<T>`：

- `isCache`
- `fetchTime`
- `data`
- `hintKey`

语义：

- `FetchResult.fresh(...)`
  - 代表拿到的是新数据
- `FetchResult.cache(...)`
  - 代表拿到的是旧缓存
  - `hintKey` 用于告诉 UI 为什么退回缓存

在页面显示时，需要针对结果状态里面的`hintKey`进行处理并展示。如果`hintKey`有数据，则使用`i18n`方式进行处理，因为该类字符串很大的概率是需要国际化处理的。如果`hintKey`没有数据，则需要默认提示，可能是`inapp_cache_hint`或者`local_cache_hint`，代表内存缓存或者存储缓存。