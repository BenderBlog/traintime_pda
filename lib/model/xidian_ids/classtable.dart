class ClassDetail {
  String name; // 名称
  String? teacher; // 老师
  String? place; // 地方
  // 返回的是 0 和 1 组成的数组，0 代表这周没课程，1 代表这周有课
  String weekList; // 上课周次
  int day; // 星期几上课
  int start; // 上课开始
  int stop; // 上课结束
  late int step; // 上课长度
  ClassDetail({
    required this.name,
    required this.weekList,
    required this.day,
    required this.start,
    required this.stop,
    this.teacher,
    this.place,
  }) {
    step = stop - start;
  }

  @override
  String toString() {
    if (place != null) {
      return "${name.length <= 15 ? name : "${name.substring(0, 14)}..."}\n$place";
    } else {
      return name;
    }
  }
}

class Classes {
  List<ClassDetail> onTable = [];
  String semesterCode = "";
  String termStartDay = "";
  int semesterLength = 0;
  bool isDone = false;
}

Classes classData = Classes();
