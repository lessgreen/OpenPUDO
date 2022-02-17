import 'package:date_format/date_format.dart';

extension DateTimeExt on DateTime {
  String get ddmmyyyy => formatDate(this, [dd, "/", mm, "/", yyyy]);
}
