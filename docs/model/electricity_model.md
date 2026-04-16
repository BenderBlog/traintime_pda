# Electricity Model

相关代码：

- `lib/model/xidian_ids/electricity.dart`
- `lib/model/fetch_result.dart`
- `lib/repository/xidian_ids/electricity_session.dart`
- `lib/controller/electricity_controller.dart`

## 总览

电费模块当前围绕两类数据组织：

1. 单次电费结果
   - `ElectricityInfo`
2. 仓库层统一结果包装
   - `FetchResult<ElectricityInfo>`

此外，还存在一个历史列表形态：

- `List<ElectricityInfo>`

用于折线图和平均日耗电图。

## ElectricityInfo

`ElectricityInfo` 定义在：

- `lib/model/xidian_ids/electricity.dart`

字段组成：

- `fetchDay`
  - 类型：`DateTime`
  - 含义：这条电费信息的抓取时间
- `remain`
  - 类型：`String`
  - 含义：剩余电量，或者一个电费状态 key
- `owe`
  - 类型：`String`
  - 含义：欠费金额，或者一个电费状态 key

### 为什么 `remain` 和 `owe` 是字符串

电费模块当前没有把“数值”和“状态”拆成不同字段，而是统一用字符串表达：

- 成功时：
  - `remain` 可能是 `"28.60"`
  - `owe` 可能是 `"0.00"` 或 `"12.50"`
- 失败或特殊情况时：
  - `remain` 可能是 `electricity_status.remain_network_issue`
  - `owe` 可能是 `electricity_status.owe_not_found`

因此，页面和控制器经常会用：

- `double.tryParse(...)`

来判断某个字段当前表达的是实际数值，还是一个状态 key。

## ElectricityInfo.empty(...)

辅助构造：

- `ElectricityInfo.empty(DateTime time)`

生成一份占位数据：

- `fetchDay = time`
- `remain = electricity_status.pending`
- `owe = electricity_status.pending`

当前它更偏向模型层的默认占位，不是主流程里的核心返回值。

## JSON 结构

`ElectricityInfo` 使用 `json_serializable`：

- `factory ElectricityInfo.fromJson(...)`
- `Map<String, dynamic> toJson()`

这使它能够直接用于：

- 当前电费缓存文件 `Electricity.json`
- 历史电费缓存文件 `ElectricityHistory.json`

## FetchResult<ElectricityInfo>

电费模块仓库层当前统一返回：

- `FetchResult<ElectricityInfo>`

字段语义见：

- `docs/model/fetch_result.md`

电费场景里的具体含义是：

- `isCache`
  - 当前展示的是在线新结果，还是缓存回退结果
- `fetchTime`
  - 当前结果的获取时间
  - 对于电费模块，缓存时间目前直接使用 `ElectricityInfo.fetchDay`
- `data`
  - 一份 `ElectricityInfo`
- `hintKey`
  - 只有缓存回退时可能存在
  - 用于告诉 UI 为什么正在显示缓存

### 电费模块的返回语义

- `FetchResult.fresh(...)`
  - 在线登录缴费平台成功
  - 成功拿到一份新的 `ElectricityInfo`
- `FetchResult.cache(...)`
  - 在线抓取失败
  - 但本地缓存存在，且 `remain` 可解析为数字
  - 同时附带错误映射后的 `hintKey`

## 历史数据结构

电费历史列表当前使用：

- `List<ElectricityInfo>`

其语义是“按抓取时间记录的一组余额快照”。

历史列表并不会额外包一层 `FetchResult`，因为它不是当前请求结果，而是一个本地持久化的统计输入。

### 历史列表的使用方式

1. 余额折线图
   - 以 `fetchDay` 的日期为 X 轴
   - 以 `remain` 的数值为 Y 轴
2. 平均日耗电图
   - 先按天取最小 `remain`
   - 再根据相邻两天差值计算平均每日耗电量

### 历史列表的数据要求

只有满足以下条件的 `ElectricityInfo` 才适合进入历史：

- `remain` 可以解析为数字
- 数据来自 fresh，而不是 cache

因此控制器在写历史前会显式做数值判断。

## 当前缓存和历史缓存的区别

### 当前缓存

当前缓存只保存“最近一条可展示电费数据”：

- 文件：`Electricity.json`
- 对应数据：`ElectricityInfo`
- 页面用途：
  - 构造期预热
  - 在线失败时做 `FetchResult.cache(...)`

### 历史缓存

历史缓存保存“一组用于图表分析的余额快照”：

- 文件：`ElectricityHistory.json`
- 对应数据：`List<ElectricityInfo>`
- 页面用途：
  - 历史折线图
  - 平均日耗电图

## 电费模型在 UI 层的解释

UI 对 `ElectricityInfo` 的解释不是固定字段映射，而是带判断逻辑的：

- `remain` 若可解析为数字
  - 当成电量值显示
  - 详情页附加 `kWh`
- `remain` 若不可解析
  - 视为 i18n key
  - 走 `FlutterI18n.translate(...)`

- `owe` 若可解析为数字
  - 首页和详情页优先显示“待清缴 {due} 元欠费”之类的模板
- `owe` 若不可解析
  - 视为状态 key
  - 走 `FlutterI18n.translate(...)`

## 小结

电费模型的核心特点有三点：

1. 单次结果模型很小
   - 只有 `fetchDay / remain / owe`
2. 数值和状态码共用字符串字段
   - 业务层和 UI 层需要做解析判断
3. 当前结果和历史结果分开组织
   - 当前结果走 `FetchResult<ElectricityInfo>`
   - 历史结果走 `List<ElectricityInfo>`
