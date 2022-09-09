class Score {
  int mark;       // 编号，用于某种计算，从 0 开始
  String name;    // 学科名称
  double score;   // 分数
  String year;    // 学年
  double credit;  // 学分
  String status;  // 修读状态
  String? classID; // 教学班序列号
  String? scoreStructure; //成绩构成
  String? scoreDetail; //分项成绩
  String isPassed; //是否及格
  Score({
    required this.mark,
    required this.name,
    required this.score,
    required this.year,
    required this.credit,
    required this.status,
    required this.isPassed,
    this.classID,
    this.scoreStructure,
    this.scoreDetail,
  });
}

class ScoreList {
  late List<Score> scoreTable;
  late Set<String> semester;
  late Set<String> statuses;
  Set<String> unPassed = {};
  double randomChoice = 0.0;

  ScoreList({required this.scoreTable}){
    semester = { for (var i in scoreTable) i.year };
    statuses = { for (var i in scoreTable) i.status };
    for (var i in scoreTable){
      if (i.status == "公共任选") {
        randomChoice += i.credit;
      }
    }
    for (var i in scoreTable) {
      if (i.isPassed != '1') {
        unPassed.add(i.name);
      }
      if (unPassed.contains(i.name) && i.isPassed == "1"){
        unPassed.remove(i.name);
        /// Whatever score is, if not passed in the first time, count as 60.
        /// Please take a note of it.
        i.score = 60;
        i.name += "(非初修通过)";
        unPassed.remove(i.name);
      }
    }
  }
}

late ScoreList scores;
/*
Score xianbei = Score(
  mark: 0,
  name: "淫梦学",
  score: 81,
  year: "2010-2009-1",
  credit: 4.0,
  status: "必修课",
  classID: "1145141919810"
);
*/