# NetworkUsage

本文档说明校园网相关的数据模型。对应代码位于：`lib/model/network_usage.dart`。

## 总览

当前文件包含两个纯数据模型：

1. `GeneralNetworkUsage`
   - 用于“当前用户”页和首页校园网卡片
   - 表示通过校园网查询后台拿到的总览流量信息
2. `CurrentUserNetInfo`
   - 用于“正在使用”页
   - 表示当前设备所在校园网环境下的实时在线信息

需要注意的是，这个模型文件现在只保留数据结构，不再承担状态枚举职责。

之前这里曾有：

- `CurrentUserNetInfoState`

它已被移除，“是否在校园网环境”已经迁移到：

- `NotSchoolNetworkException`

也就是说：

- 数据模型负责描述数据
- 异常模型负责描述错误和环境状态

## GeneralNetworkUsage

`GeneralNetworkUsage` 表示校园网总览查询结果。

字段：

- `ipList`
  - 类型：`List<(String, String, String)>`
  - 语义：在线设备列表
  - 当前约定元组含义为：
    - 第 1 项：IP
    - 第 2 项：在线时长或对应表格中的第二列文本
    - 第 3 项：流量用量或对应表格中的第三列文本
- `used`
  - 已使用流量
- `rest`
  - 余额
- `charged`
  - 查询页上对应的结算/附加信息文本

这个模型当前主要配合：

- `FetchResult<GeneralNetworkUsage>`

一起使用，由 `SchoolnetSession.getGeneralNetworkUsage()` 返回给 controller 和页面。

## CurrentUserNetInfo

`CurrentUserNetInfo` 表示当前在线校园网接口返回的完整数据。

它直接映射：

- `https://w.xidian.edu.cn/cgi-bin/rad_user_info`

返回的 JSON 字段。

特点：

- 字段较多
- 基本采用“接口字段原样映射”
- 当前主要由 `CurrentUserNetInfo.fromJson(...)` 构建

当前页面实际常用字段包括：

- `userName`
- `productsName`
- `userBalance`
- `sumBytes`
- `remainBytes`

其余字段暂时主要起到“完整保留接口响应”的作用。

## fromJson / toJson

`CurrentUserNetInfo` 提供：

- `CurrentUserNetInfo.fromJson(Map<String, dynamic>)`
- `toJson()`

用途：

- `fromJson`
  - 将校园网接口返回的 JSON 映射为 Dart 对象
- `toJson`
  - 便于后续调试、序列化或缓存扩展

目前 `GeneralNetworkUsage` 没有提供 `fromJson / toJson`，因为它不是直接由标准 JSON 构造，而是从 HTML 页面中解析得到。

## 模型边界

这两个模型只描述“数据长什么样”，不描述：

- 是否加载中
- 是否使用缓存
- 是否缺密码
- 是否密码错误
- 是否在校园网环境

这些状态现在分别由以下模型承担：

- `FetchResult<T>`
  - fresh / cache
- `NoPasswordException`
  - 缺密码
- `WrongPasswordException`
  - 密码错误
- `NotSchoolNetworkException`
  - 不在校园网环境

这种分层的好处是：

- 数据模型更纯粹
- 状态语义更清晰
- 页面和仓库层职责更容易分离
