import 'dart:convert';

import 'station.dart';
import 'stopping_point.dart';

class Service {
  late String rid;
  late String trainId;
  late String operator;
  late String operatorCode;
  String? sta;
  String? ata;
  bool? ataForecast;
  String? std;
  String? atd;
  bool? atdForecast;
  String? platform;
  late List<String> origin = [];
  late List<String> destination = [];
  late List<StoppingPoint> stoppingPoints = [];
  bool? cancelled;

  // Apparently the 'correct' way to convert XML to Dart Classes is to convert to Json first
  Service.fromBoardJson(Map<String, dynamic> json) {
    rid = json['t10:rid'];
    trainId = json['t10:trainid'];
    operator = json['t10:operator'];
    operatorCode = json['t10:operatorCode'];
    sta = json['t10:sta'];
    ata = (json['t10:ata'] != null) ? json['t10:ata'] : json['t10:eta'];
    ataForecast = (json['t10:arrivalType'] == 'Actual') ? false : true;
    std = json['t10:std'];
    atd = (json['t10:atd'] != null) ? json['t10:atd'] : json['t10:etd'];
    atdForecast = (json['t10:departureType'] == 'Actual') ? false : true;
    platform = json['t10:platform'];

    if (json['t13:origin']['t6:location'][0] != null) {
      for (dynamic location in json['t13:origin']['t6:location']) {
        origin.add(location['t5:crs']);
      }
    } else { origin.add(json['t13:origin']['t6:location']['t5:crs']); }

    if (json['t13:destination']['t6:location'][0] != null) {
      for (dynamic location in json['t13:destination']['t6:location']) {
        destination.add(location['t5:crs']);
      }
    } else { destination.add(json['t13:destination']['t6:location']['t5:crs']); }

    cancelled = (json['t10:isCancelled'] == "true") ? true : false;
  }

  Service.fromDetailsJson(Map<String, dynamic> json) {
    rid = json['t10:rid'];
    trainId = json['t10:trainid'];
    operator = json['t10:operator'];
    operatorCode = json['t10:operatorCode'];
    sta = null;
    ata = null;
    ataForecast = null;
    std = null;
    atd = null;
    atdForecast = null;
    platform = null;

    for (dynamic location in json['t13:locations']['t13:location']) {
      if (location['t9:isPass'] != "true") {
        stoppingPoints.add(StoppingPoint.fromJson(location));
      }
    }

    // print(json['t13:locations']['t13:location']);
  }

  Map toJson() {
    return {
      'rid' : rid,
      'trainId' : trainId,
      'operator' : operator,
      'operatorCode' : operatorCode,
      'sta' : sta,
      'ata' : ata,
      'ataForecast' : ataForecast,
      'std' : std,
      'atd' : atd,
      'atdForecast' : atdForecast,
      'platform' : platform,
      'origin' : origin,
      'destination' : destination,
      'stoppingPoints' : stoppingPoints.map((sp) => (sp.toJson())).toList(),
      'cancelled' : cancelled,
    };
  }
}