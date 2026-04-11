# 考试信息结构体

相关代码：

- `lib/model/xidian_ids/exam.dart`
- `lib/repository/xidian_ids/exam_session.dart`
- `lib/controller/exam_controller.dart`

## 核心模型

### Subject

- `subject`：课程或考试名称
- `typeStr`：后端原始考试类型字符串
- `startTimeStr`：格式化后的开始时间字符串
- `endTimeStr`：格式化后的结束时间字符串
- `time`：后端原始时间字段
- `place`：考试地点
- `seat`：座位号，可为空

### ToBeArranged

- `subject`：尚未安排考务的课程名称
- `id`：课程编号

### ExamData

- `subject`：已安排考试列表
- `toBeArranged`：未安排考务课程列表

## Subject 的时间语义

`Subject` 里同时保留了两套时间信息：

1. 原始字段
   - `time`
2. 派生字段
   - `startTimeStr`
   - `endTimeStr`
   - `startTime`
   - `stopTime`

其中：

- `time` 是后端返回的原始考试时间字符串
- `startTimeStr` / `endTimeStr` 是在 `Subject.generate(...)` 时格式化写入的缓存友好字段
- `startTime` / `stopTime` 是运行时从 `time` 再次解析出来的 `DateTime?` getter

## 支持的时间格式

当前模型支持两类正则：

### 本科考试时间

对应：

- `timeRegExpUnderGraduate`

形如：

- `2026-01-10 14:00-16:00`

### 研究生考试时间

对应：

- `timeRegExpPostGraduate`

形如：

- `2026-01-10 周一(14:00-16:00)`

## 时间解析规则

`startTime` 与 `stopTime` 的 getter 都会按以下顺序尝试：

1. 先匹配本科正则
2. 再匹配研究生正则
3. 若都失败，返回 `null`

这意味着模型层把“无法解析时间”的考试保留下来了，而不是直接丢弃。上层控制器会据此把它们归入：

- `isDisQualified`

## type 的归一化

`Subject.type` 会对 `typeStr` 做一层简化归类：

- 包含 `期末考试` -> `期末考试`
- 包含 `期中考试` -> `期中考试`
- 包含 `结课考试` -> `结课考试`
- 包含 `入学` -> `入学考试`
- 其他情况 -> 原样返回 `typeStr`

它的目的不是保存原始数据，而是为展示层提供更稳定的考试类型标签。

## Subject.generate(...)

仓库层不会直接手写 `Subject(...)`，而是优先通过：

- `Subject.generate(...)`

生成逻辑：

1. 尝试解析 `time`
2. 若解析成功
   - 生成 `yyyy-MM-dd HH:mm:ss` 格式的 `startTimeStr` / `endTimeStr`
3. 若解析失败
   - `startTimeStr = "cancel_exam"`
   - `endTimeStr = "cancel_exam"`

注意：

- 这里的 `"cancel_exam"` 不是布尔状态，而是一个特殊占位字符串
- 真正判断“能否解析考试时间”的依据仍然是 `startTime` / `stopTime` 是否为 `null`

## JSON 序列化

三个模型都使用 `json_serializable`：

- `Subject.fromJson(...)` / `toJson()`
- `ToBeArranged.fromJson(...)` / `toJson()`
- `ExamData.fromJson(...)` / `toJson()`

这意味着：

- 在线抓取后的考试数据可以直接写入本地缓存
- 本地缓存可以直接恢复为 `ExamData`
