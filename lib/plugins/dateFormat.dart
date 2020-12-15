import 'package:meta/meta.dart';

abstract class DateFormat {
  static DateTime toDateTime(String _formattedString){
    return DateTime.fromMillisecondsSinceEpoch(int.parse(_formattedString ?? 0));
  }

  static DateTime toDate(int _millisecondsSinceEpoch){
    return DateTime.fromMillisecondsSinceEpoch(_millisecondsSinceEpoch ?? 0);
  }

  static int toMillisecondsSinceEpoch(String _formattedString){
    final DateTime date = toDateTime(_formattedString);
    return _formattedString == null ? 0 : date.microsecondsSinceEpoch;
  }

  static int toMillisecond(String _formattedString){
    final DateTime date = toDateTime(_formattedString);
    return _formattedString == null ? 0 : date.millisecond;
  }

  static Duration diff(String startTime, String endTime, [isVerify = false]){
    final DateTime _startTime = DateTime.parse(startTime);
    final DateTime _endTime = DateTime.parse(endTime);
    assert(isVerify ? _endTime.isAfter(_startTime) : true);

    return _endTime.difference(_startTime);
  }

  static int diffDay(String startTime, String endTime){ // 获取周期数：天
    final Duration _diffDate = diff(startTime, endTime);
    return _diffDate.isNegative ? null : _diffDate.inDays;
  }

  static int diffHour(String startTime, String endTime){ // 获取周期数：时
    final Duration _diffDate = diff(startTime, endTime);
    return _diffDate.isNegative ? null : _diffDate.inHours;
  }

  static int diffMinute(String startTime, String endTime){ // 获取周期数：分
    final Duration _diffDate = diff(startTime, endTime);
    return _diffDate.isNegative ? null : _diffDate.inMinutes;
  }

  static int diffSecond(String startTime, String endTime){ // 获取周期数：秒
    final Duration _diffDate = diff(startTime, endTime);
    return _diffDate.isNegative ? null : _diffDate.inSeconds;
  }

  static String diffResult(String regStr, { // 返回null代表对比时间结束
    // String key, // 预留字段，支持单个Key获取对应的时间周期
    @required String startTime,
    @required String endTime
  }){
    final Duration diffTime = diff(startTime, endTime);

    final String day = diffDay(startTime, endTime).toString();
    final String hour = (diffTime - Duration(days: diffTime.inDays)).inHours.toString();
    final String minute = (diffTime - Duration(hours: diffTime.inHours)).inMinutes.toString();
    final String second = (diffTime - Duration(minutes: diffTime.inMinutes)).inSeconds.toString();

    return diffTime.isNegative
        ? null
        : regStr
        .replaceAll('DD', day.length == 1 ? '0$day' : day)
        .replaceAll('D', day)
        .replaceAll('hh', hour.length == 1 ? '0$hour' : hour)
        .replaceAll('h', hour)
        .replaceAll('mm', minute.length == 1 ? '0$minute' : minute)
        .replaceAll('m', minute)
        .replaceAll('ss', second.length == 1 ? '0$second' : second)
        .replaceAll('s', second);
  }

  static String format(String _formattedString, String regStr){
    final DateTime date = toDateTime(_formattedString);

    final String year = _formattedString == null ? '--' : date.year.toString();
    final String month = _formattedString == null ? '--' : date.month.toString();
    final String day = _formattedString == null ? '--' : date.day.toString();
    final String hour = _formattedString == null ? '--' : date.hour.toString();
    final String minute = _formattedString == null ? '--' : date.minute.toString();
    final String second = _formattedString == null ? '--' : date.second.toString();

    return regStr
        .replaceAll('YYYY', year)
        .replaceAll('YY', year.substring(2))
        .replaceAll('MM', month.length == 1 ? '0$month' : month)
        .replaceAll('M', month)
        .replaceAll('DD', day.length == 1 ? '0$day' : day)
        .replaceAll('D', day)
        .replaceAll('hh', hour.length == 1 ? '0$hour' : hour)
        .replaceAll('h', hour)
        .replaceAll('mm', minute.length == 1 ? '0$minute' : minute)
        .replaceAll('m', minute)
        .replaceAll('ss', second.length == 1 ? '0$second' : second)
        .replaceAll('s', second);
  }
}
