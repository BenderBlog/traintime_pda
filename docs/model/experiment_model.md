# Experiment Model

相关代码：

- `lib/model/xidian_ids/experiment.dart`
- `lib/repository/physics_experiment_session.dart`
- `lib/repository/xidian_ids/sysj_session.dart`

## 枚举

### ExperimentType

- `physics`：物理实验系统数据
- `others`：其他实验数据

## 核心模型

### ExperimentData

- `type`：`ExperimentType`
- `name`：实验名称
- `score`：`RecognitionResult?`
- `classroom`：实验地点
- `timeRanges`：`List<(DateTime, DateTime)>`
- `teacher`：任课教师
- `reference`：可选，参考书目或备注

## 字段语义

### score

`score` 不是所有实验源都天然提供的字段。

- 物理实验：会尝试通过图片识别补出 `RecognitionResult`
- 其他实验：没有额外成绩识别结果

### timeRanges

`timeRanges` 表示一个实验可能对应多个上课时段。

不同数据源下的常见情况：

- 物理实验：一条记录只带一个时段
- 其他实验：相同实验的多个时段聚合到同一个 `ExperimentData`

## JSON 序列化

`ExperimentData` 使用 `json_serializable`：

- `factory ExperimentData.fromJson(...)`
- `toJson()`

`score` 使用自定义转换器：

- `_recognitionResultFromJson`
- `_recognitionResultToJson`

## 旧缓存兼容

历史上 `score` 字段是 `String?`，现在是 `RecognitionResult?`。若读取到旧 `String`，`_recognitionResultFromJson` 返回 `null`。仓库层的缓存读取逻辑会进一步检查原始 JSON，若检测到旧格式，删除旧缓存并触发重新拉取。

## 复制语义

`ExperimentData.from(ExperimentData src)` 会做深复制：

- `type`
- `name`
- `score`
- `classroom`
- `teacher`
- `reference`
- `timeRanges.toList()`