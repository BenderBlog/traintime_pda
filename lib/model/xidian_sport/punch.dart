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
    this.state,
  );
}

class PunchDataList {
  String? situation;
  int allTime = -1;
  int valid = -1;
  List<PunchData> all = [];
}
