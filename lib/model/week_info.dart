class WeekTimeInfo {
  int week;
  int startTime;
  int endTime;

  WeekTimeInfo(int weekIndex, int startBeginTime) {
    this.week = weekIndex;
    DateTime beginDate = DateTime.fromMillisecondsSinceEpoch(startBeginTime);
    Duration weekDuration = Duration(days: 6, seconds: 0, minutes: 0, hours: 0);
    DateTime startDate = beginDate.add(Duration(days: 7 * (weekIndex - 1)));
    DateTime endDate = startDate.add(weekDuration);
    this.startTime = startDate.millisecondsSinceEpoch;
    print('startTime == $startTime');
    this.endTime = endDate.millisecondsSinceEpoch;
  }
}
