

class StringUtils {


  static String getTimestampStr(int timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${dateTime.year}-${dateTime.month}-${dateTime.day}";
  }
}