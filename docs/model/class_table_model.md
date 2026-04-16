# 课表信息结构体

相关代码：

- `lib/model/xidian_ids/classtable.dart`
- `lib/repository/xidian_ids/classtable_session.dart`
- `lib/controller/classtable_controller.dart`
- `lib/repository/user_defined_class_file.dart`

## 枚举

### Source

- `empty`：空来源，占位值
- `school`：学校接口返回的课表数据
- `user`：用户自定义课程数据

### ChangeType

- `change`：调课
- `stop`：停课
- `patch`：补课

## 核心模型

### NotArrangementClassDetail

- `name`：课程名称
- `code`：课程序号，可为空
- `number`：班级序号，可为空
- `teacher`：教师信息，可为空

这个模型表示“存在课程信息，但没有进入标准时间安排”的课程。

### ClassDetail

- `name`：课程名称
- `code`：课程序号，可为空
- `number`：班级序号，可为空

它只承载课程本体信息，不包含时间、地点、周次。

### TimeArrangement

- `index`：指向课程详情的索引
- `weekList`：布尔周次表，`true` 表示该周有课
- `teacher`：教师信息，可为空
- `day`：星期几
- `start`：开始节次
- `stop`：结束节次
- `source`：数据来源，`school` 或 `user`
- `classroom`：教室，可为空

补充语义：

- `index` 不是 `TimeArrangement` 自身的索引，而是课程详情索引
- `step = stop - start`，表示课程跨度
- `weekList` 使用 `List<bool>` 而不是字符串，主要是为了缓存与跨端处理方便

### ClassTableData

- `semesterLength`：学期总周数
- `semesterCode`：学期代码
- `termStartDay`：学期起始日期字符串
- `classDetail`：学校课表课程详情
- `userDefinedDetail`：用户自定义课程详情
- `notArranged`：未进入标准时间安排的课程
- `timeArrangement`：标准时间安排列表
- `classChanges`：调课/停课/补课记录

这是课表模块的总模型。仓库层抓取、控制器合并、页面展示最终都围绕它工作。

### ClassChange

- `type`：`ChangeType`
- `classCode`：课程号
- `classNumber`：班级号
- `className`：课程名
- `originalAffectedWeeks`：原周次影响范围，可为空
- `newAffectedWeeks`：新周次影响范围，可为空
- `originalTeacherData`：原教师原始数据，可为空
- `newTeacherData`：新教师原始数据，可为空
- `originalClassRange`：原节次范围
- `newClassRange`：新节次范围
- `originalWeek`：原星期，可为空
- `newWeek`：新星期，可为空
- `originalClassroom`：原教室，可为空
- `newClassroom`：新教室，可为空

### UserDefinedClassData

- `userDefinedDetail`：用户自定义课程详情
- `timeArrangement`：用户自定义课程的时间安排

这是单独落盘到 `UserClass.json` 的模型，不带学期字段。

## 课程详情与时间安排的索引语义

`TimeArrangement.index` 的语义依赖 `source`：

- `source == Source.school`
  - `index` 指向 `classDetail`
- `source == Source.user`
  - `index` 指向 `userDefinedDetail`

`ClassTableData.getClassDetail(TimeArrangement t)` 会按这个规则解析课程详情。

这意味着：

- `timeArrangement` 可以混合学校课表和用户自定义课表
- 但必须始终依赖 `source` 决定索引落在哪个详情列表上

## 空课表语义

空课表是正常结果，不是异常。

当前约定为：

- `semesterCode` 必须明确
- `timeArrangement.isEmpty` 时可以视为空课表
- `notArranged` 允许不为空
- 如果不是空课表，`termStartDay` 必须非空

模型层通过断言表达了这一点：

- `timeArrangement.isNotEmpty -> termStartDay.isNotEmpty`

也就是说：

- 有标准课表安排时，必须能确定学期起始日
- 没有标准课表安排时，允许 `termStartDay` 为空

## termStartDay 的语义

`termStartDay` 不是普通展示字段，而是“按周课表能力”的前置条件。

它会影响：

- 当前周计算
- 周视图日期推导
- 课程日程映射
- 课程提醒排期

因此：

- 非空课表必须提供 `termStartDay`
- 空课表允许没有 `termStartDay`

## 调课模型的派生字段

`ClassChange` 提供了一些便于展示层使用的 getter：

### 周次列表

- `originalAffectedWeeksList`
- `newAffectedWeeksList`

这两个 getter 会把布尔周次数组转换成整数列表。

注意：

- 返回的整数是原数组索引
- 当前实现没有做“从 1 开始”的展示修正，展示层若需要“第 1 周、第 2 周”样式，需要再做格式化

### 教师信息

- `originalTeacher`
- `newTeacher`
- `originalNewTeacher`

其中：

- `originalTeacher` / `newTeacher` 会去掉原始数据中的编号与分隔信息
- `originalNewTeacher` 直接返回 `newTeacherData`

### 教师是否变更

`isTeacherChanged` 会从原教师和新教师原始数据中提取带编号的信息，再比较两侧是否一致。

它的目的不是比较展示名，而是比较后端编码层面的教师是否变化。

### 中文类型文本

`changeTypeString` 会把 `ChangeType` 映射成中文展示文本：

- `change` -> `调课`
- `patch` -> `补课`
- `stop` -> `停课`

## JSON 序列化

以下模型都使用 `json_serializable`：

- `NotArrangementClassDetail`
- `ClassDetail`
- `TimeArrangement`
- `ClassTableData`
- `ClassChange`
- `UserDefinedClassData`

也就是说：

- 学校课表可以直接缓存为 `ClassTableData`
- 用户自定义课表可以直接缓存为 `UserDefinedClassData`
- 调课记录也能随课表总模型一并持久化

## 用户自定义课程的模型边界

`UserDefinedClassData` 只保存：

- 用户自定义课程详情
- 用户自定义时间安排

它当前不保存：

- 学期代码
- 学期起始日
- 调课记录

因此它的职责很纯：

- 只表达用户自定义课程本身
- 不表达它属于哪个学期

当前业务上是通过学期切换时清理该文件，来避免旧学期自定义课程继续污染新学期课表。

## ClassTableData 的合并语义

在控制器层，最终展示给页面的课表通常不是单纯的学校课表，而是：

1. 学校课表 `ClassTableData`
2. 用户自定义课程 `UserDefinedClassData`

合并后的结果仍然用一个 `ClassTableData` 表达：

- 学校课程详情进 `classDetail`
- 用户课程详情进 `userDefinedDetail`
- `timeArrangement` 混合两路数据
- `source` 决定每一项安排该回溯到哪个详情列表

这也是 `ClassTableData` 当前设计最关键的地方：

- 一个总模型承载两类课程来源
- 但索引空间由 `source` 分隔，而不是全局统一索引
