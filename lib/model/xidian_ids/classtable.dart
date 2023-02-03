class ClassDetail {
  String name; // 名称
  String? teacher; // 老师
  String? place; // 地方
  String? code; // 课程序号
  String? number; // 班级序号

  ClassDetail({
    required this.name,
    this.teacher,
    this.place,
    this.code,
    this.number,
  });

  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) =>
      other is ClassDetail &&
      other.runtimeType == runtimeType &&
      name == other.name;

  @override
  String toString() {
    if (place != null) {
      return "${name.length <= 15 ? name : "${name.substring(0, 14)}..."}\n$place";
    } else {
      return name;
    }
  }
}

class TimeArrangement {
  int index; // 课程索引
  // 返回的是 0 和 1 组成的数组，0 代表这周没课程，1 代表这周有课
  String weekList; // 上课周次
  int day; // 星期几上课
  int start; // 上课开始
  int stop; // 上课结束
  late int step; // 上课长度
  TimeArrangement({
    required this.index,
    required this.weekList,
    required this.day,
    required this.start,
    required this.stop,
  }) {
    step = stop - start;
  }
}

class Classes {
  List<ClassDetail> classDetail = [];
  List<TimeArrangement> timeArrangement = [];
  String semesterCode = "";
  String termStartDay = "";
  int semesterLength = 0;
  bool isDone = false;
}

Classes classData = Classes();
