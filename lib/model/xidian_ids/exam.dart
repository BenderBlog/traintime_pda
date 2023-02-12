class Subject {
  String subject;
  String type;
  String? teacher;
  //DateTime start;
  //DateTime end;
  String time;
  String place;
  int seat;

  @override
  String toString() {
    return "$subject $type $teacher $time $place $seat\n";
  }

  Subject({
    required this.subject,
    required this.type,
    this.teacher,
    required this.time,
    //required this.start,
    //required this.end,
    required this.place,
    required this.seat,
  });
}

// Or should I say, to be dead?
class ToBeArranged {
  String subject;
  String? teacher;
  String id;

  @override
  String toString() {
    return "$subject $teacher $id\n";
  }

  ToBeArranged({
    required this.subject,
    this.teacher,
    required this.id,
  });
}
