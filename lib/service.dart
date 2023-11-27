import 'package:xml/xml.dart';

import 'station.dart';

class Service {
  late String rid;
  late String trainId;
  late String operator;
  late String operatorCode;
  late String? sta;
  late String? ata;
  late bool? forecastAta;
  late String? std;
  late String? atd;
  late bool? forecastAtd;
  late String platform;
  late Station origin;
  late Station destination;

  // Apparently the 'correct' way to convert XML to Dart Classes is to convert to Json first
  Service.fromJson(Map<String, dynamic> json) {
    rid = json['t10:rid'];
    trainId = json['t10:trainid'];
    operator = json['t10:operator'];
    operatorCode = json['t10:operatorCode'];
    sta = json['t10:sta'];
    ata = (json['t10:ata'] != null) ? json['t10:ata'] : json['t10:eta'];
    forecastAta = (json['t10:arrivalType'] == 'Actual') ? false : true;
    std = json['t10:std'];
    atd = (json['t10:atd'] != null) ? json['t10:atd'] : json['t10:etd'];
    forecastAtd = (json['t10:departureType'] == 'Actual') ? false : true;
    platform = json['t10:platform'];
    origin = Station(json['t13:origin']['t6:location']['t5:crs'], json['t13:origin']['t6:location']['t5:locationName']);
    destination = Station(json['t13:destination']['t6:location']['t5:crs'], json['t13:destination']['t6:location']['t5:locationName']);
  }
}