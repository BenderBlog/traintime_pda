class ClassDetail {
  String name;
  String? teacher;
  String? place;
  ClassDetail({
    required this.name,
    this.teacher,
    this.place,
  });
  @override
  String toString() {
    if (place != null) {
      return "${name.length <= 15 ? name : "${name.substring(0, 14)}..."} $place";
    } else {
      return name;
    }
  }
}

class WeekClassInformation {
  DateTime startOfTheWeek;
  List<List<int?>> classList;
  WeekClassInformation({
    required this.startOfTheWeek,
    required this.classList,
  });
}

class Classes {
  List<ClassDetail> onTable = [];
  // List<ClassDetail> notOnTable = [];
  /// Must be List.generate(7, (_) => List.filled(10, null, growable: false))
  Map<int, WeekClassInformation> classTable = {};
  String semesterCode = "";
  String termStartDay = "";
  bool isDone = false;
}

Classes classData = Classes();
