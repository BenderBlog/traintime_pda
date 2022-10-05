class ClassDetail{
  String name;
  String? teacher;
  String? place;
  ClassDetail({
    required this.name,
    this.teacher,
    this.place,
  });
}

class Classes{
  List<ClassDetail> notOnTable = [];
  /// Must be List.generate(7, (_) => List.filled(9, null, growable: false))
  Map<int,List<List<ClassDetail?>>> classTable = {};
  String semesterCode = "";
  String termStartDay = "";
  bool isDone = false;
}

Classes classData = Classes();