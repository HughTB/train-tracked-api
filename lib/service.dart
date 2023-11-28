import 'station.dart';
import 'stopping_point.dart';

class Service {
  late String rid;
  late String trainId;
  late String operator;
  late String operatorCode;
  String? sta;
  String? ata;
  bool? forecastAta;
  String? std;
  String? atd;
  bool? forecastAtd;
  String? platform;
  late List<Station> origin = [];
  late List<Station> destination = [];
  late List<StoppingPoint> stoppingPoints = [];

  // Apparently the 'correct' way to convert XML to Dart Classes is to convert to Json first
  Service.fromBoardJson(Map<String, dynamic> json) {
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

    if (json['t13:origin']['t6:location'][0] != null) {
      for (dynamic location in json['t13:origin']['t6:location']) {
        origin.add(Station(location['t5:crs'], location['t5:locationName']));
      }
    } else { origin.add(Station(json['t13:origin']['t6:location']['t5:crs'], json['t13:origin']['t6:location']['t5:locationName'])); }

    if (json['t13:destination']['t6:location'][0] != null) {
      for (dynamic location in json['t13:destination']['t6:location']) {
        destination.add(Station(location['t5:crs'], location['t5:locationName']));
      }
    } else { destination.add(Station(json['t13:destination']['t6:location']['t5:crs'], json['t13:destination']['t6:location']['t5:locationName'])); }
  }

  Service.fromDetailsJson(Map<String, dynamic> json) {
    rid = json['t10:rid'];
    trainId = json['t10:trainid'];
    operator = json['t10:operator'];
    operatorCode = json['t10:operatorCode'];
    sta = null;
    ata = null;
    forecastAta = null;
    std = null;
    atd = null;
    forecastAtd = null;
    platform = null;

    for (dynamic location in json['t13:locations']['t13:location']) {
      if (location['t9:isPass'] != "true") {
        stoppingPoints.add(StoppingPoint.fromJson(location));
      }
    }

    // print(json['t13:locations']['t13:location']);
  }
}