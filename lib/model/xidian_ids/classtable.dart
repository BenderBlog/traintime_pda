class ClassDetail{
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
      return "$name\n$place";
    } else {
      return "$name";
    }
  }
}

class Classes{
  // List<ClassDetail> notOnTable = [];
  /// Must be List.generate(7, (_) => List.filled(10, null, growable: false))
  Map<int,List<List<ClassDetail?>>> classTable = {};
  String semesterCode = "";
  String termStartDay = "";
  bool isDone = false;
}

Classes classData = Classes();