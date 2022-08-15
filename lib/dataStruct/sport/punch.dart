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

class PunchDataList{
  int allTime = 0;
  int valid = 0;
  List<PunchData> all = [];
}

