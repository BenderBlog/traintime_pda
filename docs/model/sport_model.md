# 体育信息结构体

本文档说明 `lib/model/xidian_sport` 下除 `punch.dart` 外的两个模型文件：

- `lib/model/xidian_sport/sport_class.dart`：每学期选择的体育课程详情；
- `lib/model/xidian_sport/sport_score.dart`：每学年体测成绩概览。

## 体育课程详情

### `SportClass`

定义：

```dart
typedef SportClass = List<SportClassItem>;
```

含义：

- `SportClass` 不是一个独立类，而是 `List<SportClassItem>` 的类型别名
- 它表示“一组体育课程记录”
- 这意味着课程列表本身没有额外元数据，只有一组条目

### `SportClassItem`

`SportClassItem` 表示一条体育课程记录。

字段如下：

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `termToShow` | `String` | 原始学期显示文本 |
| `score` | `String` | 该课程对应成绩 |
| `type` | `String` | 课程类型 |
| `term` | `String` | 结构化后的学期标识 |
| `name` | `String` | 课程名称 |
| `teacher` | `String` | 任课教师 |
| `week` | `int` | 星期几，取值预期为 `1..7` |
| `start` | `int` | 起始节次 |
| `stop` | `int` | 结束节次 |
| `place` | `String` | 上课地点 |

### 内部正则

类内部有两个正则表达式：

#### `_termDealer`

```dart
RegExp(r'^(?<year_start>\d{4})-(?<year_end>\d{4})(.*)(?<term>\d{1})')
```

作用：

- 从原始学期字符串里提取：
  - 起始学年
  - 结束学年
  - 学期编号

输出后会生成：

- `term = "2023-2024-1"`

#### `_timeDealer`

```dart
RegExp(r'^星期(?<week>.{1})(?<start>\d{1})(?<stop>\d{1})')
```

作用：

- 从课程时间字符串中提取：
  - 星期几
  - 起始节次
  - 结束节次

它假设原始时间格式形如：

- `星期一12`
- `星期三34`

### `SportClassItem.fromData(...)`

这是主要构造入口。

输入：

- `termName`
- `name`
- `score`
- `type`
- `teacher`
- `time`
- `place`

处理逻辑：

1. 用 `_termDealer` 解析 `termName`
2. 用 `_timeDealer` 解析 `time`
3. 将中文星期转换为整数：
   - `一 -> 1`
   - `二 -> 2`
   - `三 -> 3`
   - `四 -> 4`
   - `五 -> 5`
   - `六 -> 6`
   - `日 -> 7`
4. 将提取出的年份和学期拼成结构化 `term`
5. 构造私有实例 `SportClassItem._(...)`

这说明：

- `fromData(...)` 既是构造函数，也是一个轻量解析器
- 它把“后端原始字符串”转换成更结构化的课程对象

### `SportClassItem._(...)`

这是私有构造函数。

特点：

- 不允许外部绕过 `fromData(...)` 直接随意创建完整对象
- 把“解析入口”收敛到工厂方法里

这让类的创建方式更统一，但也意味着：

- 模型和后端格式耦合比较强
- 如果后端时间/学期格式变化，`fromData(...)` 会直接受影响

## sport_score.dart

这个文件使用了三层结构来描述每学年体测成绩。

关系如下：

```text
SportScore
└── List<SportScoreOfYear>
    └── List<SportItems>
```

也就是：

- `SportScore` 表示四年体测成绩的加权计算结果，该结果由后端控制了；
- `SportScoreOfYear` 表示某学年的体测成绩；
- `SportItems` 表示单个考核项目。

### `SportItems`

`SportItems` 表示单个考核项目。

字段如下：

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `examName` | `String` | 项目名称 |
| `examunit` | `String` | 实测成绩的单位 |
| `actualScore` | `String` | 实测成绩原始值 |
| `score` | `double` | 该项目折算后的分数 |
| `rank` | `String` | 项目是否合格或等级描述 |

补充说明：

- `rank` 的默认值写成了 `"不合格"`，但正常情况下，构造时会显式传入 `rank`；
- `actualScore` 用 `String` 而不是数值，因为原始成绩为字符串，或者用字符串存储更好。

### `SportScoreOfYear`

`SportScoreOfYear` 表示某学年的体测成绩。

字段如下：

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `year` | `String` | 学年 |
| `totalScore` | `String` | 该学年的体测总分 |
| `rank` | `String` | 该学年 |
| `gradeType` | `String` | 阶段类别描述 |
| `moreinfo` | `String` | 补充信息 |
| `details` | `List<SportItems>` | 单项成绩明细 |

### `SportScore`

`SportScore` 是体育成绩总模型。

字段如下：

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `total` | `String` | 当前总成绩 |
| `rank` | `String` | 当前总评等级或是否合格 |
| `detail` | `String` | 总体说明文本 |
| `list` | `List<SportScoreOfYear>` | 分学年成绩列表 |

默认值：

- `total = "0.0"`
- `rank = ""`
- `detail = ""`
- `list = []`

这意味着 `SportScore` 支持无参创建，其刚创建时是一个“空成绩对象”。

### 计算属性

`SportScore` 里有三个 getter。

#### `isFourYearsComplete`

```dart
bool get isFourYearsComplete => list.length >= 4;
```

用成绩列表条数是否达到 4 来判断“是否四年数据完整”，一年对应一条 `SportScoreOfYear`。

#### `isQualified`

```dart
bool get isQualified => !rank.contains("不");
```

只要总评字符串里不包含“`不`”，就认为合格。

#### `scoreRankI18nStr`

```dart
String get scoreRankI18nStr =>
    list.length < 4 ? "class_attendance.course_state.unknown" : rank;
```

如果成绩列表不足 4 条，则返回一个国际化 i18n key，表示“未知”。如果成绩列表达到 4 条，则返回真实 `rank`。由于涉及国际化，UI 使用时需要进行 i18n 处理。

## AI 分析的隐含约束和风险

虽然这两个模型文件本身不复杂，但都带有明显的隐含约束，这类隐含约束和风险是基于西安电子科技大学体育服务返回数据设计的。

### `sport_class.dart` 的隐含约束

- `termName` 必须匹配 `_termDealer`
- `time` 必须匹配 `_timeDealer`
- 星期必须是中文 `一二三四五六日`
- `start` 和 `stop` 当前只匹配单个数字

这意味着：

- 如果后端把节次改成两位数，如 `10`
- 或时间格式不再是 `星期三34`
- 或星期文本改成 `周三`

那么 `fromData(...)` 可能直接解析失败。

### `sport_score.dart` 的隐含约束

- `rank` 的业务判断依赖字符串包含关系
- `isFourYearsComplete` 依赖列表长度而不是学年内容
- `scoreRankI18nStr` 同时承担业务值和 i18n key 两种职责

这意味着：

- 模型比较轻量，但语义规则偏“约定驱动”
- 如果后端文案变化，合格判断可能失准