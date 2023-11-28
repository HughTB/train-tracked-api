import 'package:date_time_format/date_time_format.dart';

void log(String? text, bool error) {
  print("${DateTime.now().format('H:i:s')} - ${(error) ? "ERROR: " : "INFO: "}$text");
}