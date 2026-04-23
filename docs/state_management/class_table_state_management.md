# 日程表页面

相关代码：

- `lib/page/classtable/classtable.dart`
- `lib/page/classtable/classtable_state.dart`
- `lib/page/classtable/class_page/classtable_page.dart`
- `lib/page/classtable/class_page/content_classtable_page.dart`
- `lib/page/classtable/class_page/empty_classtable_page.dart`
- `lib/page/classtable/class_page/classtable_inline_banner.dart`
- `lib/controller/classtable_controller.dart`
- `lib/controller/exam_controller.dart`
- `lib/controller/physics_experiment_controller.dart`
- `lib/controller/other_experiment_controller.dart`
- `lib/controller/week_swift_controller.dart`

## 总览

日程表页面而是以课程信息为主轴，组合课表、考试、物理实验和其他实验四类数据。其中课程信息决定页面是否进入日程矩阵页。

页面侧不直接读取控制器，而是统一经由`ClassTableWidgetState`暴露状态。阅读下列材料前需要对`InheritedWidget`和`ChangeNotifier`有了解。

> ClassTable 直译过来就是课程表，本程序最开始开发的一个出发点是电表 MyXDU 将这三类数据割裂开渲染。

## 入口结构

课表窗口入口在`lib/page/classtable/classtable.dart`，入口会创建`ChangeNotifier`状态类`ClassTableWidgetState(currentWeek: currentWeek)`，然后通过`ClassTableState`这个`InheritedWidget`向整棵页面树共享状态。这意味着课表页面里的各个子组件原则上都通过`ClassTableState.of(context)!.controllers`获取状态，而不是各自直接读取控制器。

上述设计可以使日程表组件不直接访问整体页面状态`lib/controller`，从而方便其他人使用代码时尽量少考虑代码解耦问题。

## ClassTableWidgetState 的职责

`lib/page/classtable/classtable_state.dart`里的`ClassTableWidgetState`是日程表页面的页面状态层，职责有四类：

1. 转发底层控制器状态;
2. 管理页面局部状态，例如`chosenWeek`;
3. 提供页面可直接消费的聚合判断;
4. 提供日程表矩阵、导出日历、刷新等页面能力。

### 控制器桥接

控制器需要转接程序整体的状态，包括以下几个：

- `ClassTableController`：课程信息控制器，包括网络课程和用户自定义课程；
- `ExamController`：考试信息控制器；
- `PhysicsExperimentController`：物理实验信息控制器；
- `OtherExperimentController`：其他实验信息控制器；
- `WeekSwiftController`：周次增减控制器。

同时通过一个 signal bridge effect 监听这些控制器里的的 signal / computed 状态，并在变化时调用`notifyListeners()`要求日程表刷新。

### 页面局部状态

`ClassTableWidgetState`自己维护当前选择周次状态`chosenWeek`，该状态在周切换时触发页面重绘。

### 页面聚合状态

它对外暴露了大量只读 getter，主要分几组。

#### 课程主数据

- `semesterLength`：学期长度，有几周；
- `semesterCode`：当前学期代码；
- `classDetail`：课程信息；
- `timeArrangement`：时间安排信息，引用课程信息`classDetail`；
- `notArranged`：未安排课程信息；
- `classChange`：课程安排调整信息，该信息作为获取过程中课程安排调整的参考；
- `startDay`：学期开始时间，用于计算当前周次；
- `currentWeek`：当前周次信息。

#### 状态条相关

状态条需要这两类信息：

- `loadingSources`：正在加载的控制器信息；
- `cacheSources`：当前加载信息为缓存的控制器信息。

列表内信息使用`ClassTableStatusSource`枚举表示课程、考试、物理实验和其他实验信息，这两个列表供顶部的数据加载条`ClassTableInlineBanner`使用。

#### 错误弹窗相关

- `errorWithoutCacheSources`：真实`AsyncError`，即没有缓存兜底的失败；
- `errorWithCacheSources`：当前显示的是缓存，而且存在缓存获取原因`hintKey`，表示在线获取失败但成功回退缓存。

#### 空页增强相关

用于在空页里提醒用户有对应信息，包括两类：

- `hasExamArrangement`：相应控制器加载了考试信息；
- `hasExperimentArrangement`：相应控制器加载了物理实验信息或者其他实验信息。

这些判断本身在对应控制器中定义，`ClassTableWidgetState`仅作转发。

### 页面能力

`ClassTableWidgetState`还承接了页面的一些行为能力：

- `addUserDefinedClass`：添加用户定义日程信息；
- `editUserDefinedClass`：编辑用户定义日程信息；
- `deleteUserDefinedClass`：删除用于定义日程信息，上述三个方法需要转发到上层控制器；
- `updateClasstable`：更新日程信息；
- `outputToCalendar`：输出到系统日历中；
- `iCalenderStr`：生成 iCal 格式的字符串；
- `events`：`outputToCalendar` 和`iCalenderStr`的辅助函数，生成日历日程的格式化信息；
- `getArrangement(...)`：通过`TimeArrangement`信息获取课程信息`ClassDetail`。

## 页面主分流

主分流在`lib/page/classtable/class_page/classtable_page.dart`：

- 有课程信息`haveClass == true`：进入日程矩阵页面`ContentClassTablePage`；
- 无课程信息`haveClass == false`：进入空白提示页面`EmptyClassTablePage`。

没有课程信息，就必须进入空页，即使考试或实验存在，也不进入日程矩阵页面。

当前`haveClass`的定义是`timeArrangement.isNotEmpty && classDetail.isNotEmpty`。

## 日程矩阵页

`lib/page/classtable/class_page/content_classtable_page.dart` 是真正的日程矩阵页。

它主要由三部分组成：`AppBar`、顶部状态条和周选择条、每周课程矩阵`PageView`。

### AppBar

日程矩阵页的`AppBar`包含返回按钮、错误提示按钮和更多菜单。

其中错误提示按钮只在以下任一条件成立时出现，点击后会弹出错误概览弹窗。

- `errorWithoutCacheSources.isNotEmpty`：该控制器获取信息失败，无缓存信息；
- `errorWithCacheSources.isNotEmpty`：该控制器获取信息失败，回退至缓存。

在错误弹窗中，每一项会显示来源名和对应的`hintKey`翻译。若无`hintKey` ，则退回`network_error`。

在更多菜单中，包含以下功能的触发方式：

- 查看未安排课程也页面；
- 查看调课信息页面；
- 添加自定义课程页面；
- 导出日历文件`.ics`；
- 导出到系统日历；
- 刷新课表。

这些能力都通过`ClassTableWidgetState`转发到底层控制器或本地工具逻辑。

### 顶部状态条

顶部状态条组件为日程表页面里面的`ClassTableInlineBanner`，该组件由程序整体的`LoadingAlerter`修改而来。它只关心两类输入，目前正在加载控制器列表`loadingSources`和加载了缓存信息的控制器列表`cacheSources`。

该组件会显示两行信息，加载信息和缓存信息。最右侧有个`LoadingIndicator`转圈组件，仅当加载列表不为空时显示。

### 周选择条

周选择条对应`ContentClassTablePage._topView()`，本质上是一个横向的`PageView`，由`rowControl`控制。每一个项目都是一个“第 N 周”的卡片，卡片内部使用`week_choice_view.dart`来展示周次标题和简略概览。

周选择条本身并不保存当前周次，它依赖`ClassTableWidgetState.chosenWeek`作为共享状态。这个字段同时被顶部周条和底部矩阵页使用。

`chosenWeek`的初始化规则在`ClassTableWidgetState`构造阶段完成。如果当前周次`currentWeek`小于0，代表未开学，取第0周；如果当前周次比学期长度`semesterLength`长，代表安排都完了，取最后一周，否则取`currentWeek`。

用户点击顶部某一周按钮时，会直接修改`classTableState.chosenWeek`，随后通过`_switchPage()`同时驱动两个组件的滚动：

 - 周次选择条的滚动：触发`rowControl.animateToPage(...)`；
 - 日程矩阵滚动的滚动：触发`pageControl.animateToPage(...)`。

从而让顶部周选择条和底部矩阵页始终切换到同一周。

反过来，用户左右滑动底部课程矩阵时，`_classTablePage()`里的`onPageChanged`会在合适时机回写`chosenWeek`，顶部周选择条也会被同步滚动到对应位置。

为了避免顶部和底部在动画过程中互相重复触发状态更新，内容页内部维护了`isTopRowLocked`状态。当程序主动调用`animateToPage()`进行联动切换时，临时阻止底部矩阵继续反向回写`chosenWeek`，从而避免周切换抖动或重复刷新。

### 日程矩阵

日程矩阵本体由顶部的周选择条`_topView()`和按周切页的`_classTablePage()`组成。实际每一周的表格渲染在`lib/page/classtable/class_table_view/class_table_view.dart`文件中，其数据来自`ClassTableWidgetState.getArrangement(weekIndex, dayIndex)`。

`getArrangement`方法可将课程安排信息`timeArrangement`、考试信息`subjects`和实验信息`experiments`合并进日程矩阵，从而实现课程、考试、实验的统一时间投影。

## 空白日程页面

`lib/page/classtable/class_page/empty_classtable_page.dart`负责空白日程页面的渲染。

顶部状态条错误按钮与日程矩阵页相同，不在此赘述。

空页文案现在按考试/实验情况细分为四类：

1. `classtable.empty_state.no_course`：无课，无考试，无实验；
2. `classtable.empty_state.with_exam`：无课但有考试；
3. `classtable.empty_state.with_experiment`：无课但有实验；
4. `classtable.empty_state.with_exam_and_experiment`：无课但同时有考试和实验。

空页保留“刷新课表”按钮，同时新增跳转至考试安排窗口和实验安排窗口。这虽然打破了“课程表组件状态管理独立于整体项目页面”的设计规范，但是对于用户来说是必要且方便的。

## 日程表页面涉及的部分状态管理

### 与 ClassTableController 的关系

`ClassTableController`是底层的日程表业务控制器，负责：

1. 从`semesterSignal`触发课表加载；
2. 维护`schoolClassTableSignal`；
3. 保留最后有效课表结果`_lastValidSchoolClassTable`；
4. 合并学校课表和用户自定义课表；
5. 暴露下面信息：
   - `classTableComputedSignal`；
   - `isClassTableFromCacheComputedSignal`；
   - `classTableFetchTimeComputedSignal`；
   - `classTableCacheHintKeyComputedSignal`；
   - `currentWeekComputedSignal`；
   - `arrangementOfTodayComputedSignal`；
   - `arrangementOfTomorrowComputedSignal`。

学期同步事件到来时，它会在学期变化时清理缓存和用户自定义课表，之后无论学期是否变化，都尝试 reload 。页面层不直接消费这些 signal，而是通过 `ClassTableWidgetState` 统一桥接。

### 与学期同步的关系

日程表页面会受`SemesterController`驱动的学期同步影响，但页面自身不处理学期逻辑。

学期同步事件会先影响各下游控制器，包括课程控制器、考试控制器、物理实验控制器、其他实验控制器和周次偏移控制器。其中周次偏移控制器仅作清空数值处理。

在上面步骤后，`ClassTableWidgetState`再通过 signal bridge effect 感知变化，通知页面重建。

## 典型页面状态组合

| 条件 | 页面表现 |
|---|---|
| 有课程，四路都正常 | 进入内容页，显示课程矩阵 |
| 有课程，部分来源 loading | 内容页 + 顶部状态条显示“正在更新” |
| 有课程，部分来源缓存 | 内容页 + 顶部状态条显示“当前使用缓存” |
| 有课程，部分来源无缓存错误 | 内容页 `AppBar` 显示错误按钮 |
| 无课程，无考试无实验 | 空页，仅显示空课表文案 |
| 无课程，但有考试 | 空页 + “查看考试安排”按钮 |
| 无课程，但有实验 | 空页 + “查看实验安排”按钮 |
| 无课程，同时有考试和实验 | 空页 + 两个跳转按钮 |

## AI 总结的当前设计结论

课表页当前采用的是“课程优先”设计：

- 是否进入课程矩阵页，只看课程信息；
- 考试和实验是辅助安排信息，不会把空页提升为内容页；
- 但它们会参与：
  - 顶部状态提示；
  - 错误概览；
  - 空页跳转入口；
  - 内容页矩阵中的时间投影。

这使得课表页在语义上仍然保持“课程页”，同时又能承接考试/实验带来的学期安排信息。
