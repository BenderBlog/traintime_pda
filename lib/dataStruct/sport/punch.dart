class PunchData {
  String machineName;
  String weekNum;
  String punchDay;
  String punchTime;
  String state;
  PunchData(
      this.machineName,
      this.weekNum,
      this.punchDay,
      this.punchTime,
      this.state);
}

class ToStore{
  int allTime = 0;
  int valid = 0;
  List<PunchData> all = [];
}

/// Should be identical to the student id.
String account = "";
String password = "";