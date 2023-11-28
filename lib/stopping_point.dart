import 'station.dart';

class StoppingPoint {
  String? platform;
  String? sta;
  String? ata;
  bool? forecastAta;
  String? std;
  String? atd;
  bool? forecastAtd;
  late Station station;
  String? joinWithRid;

  StoppingPoint.fromJson(Map<String, dynamic> json) {
    platform = json['t9:platform'];
    sta = json['t9:sta'];
    ata = (json['t9:ata'] != null) ? json['t9:ata'] : json['t9:eta'];
    forecastAta = (json['t9:arrivalType'] == 'Actual') ? false : true;
    std = json['t9:std'];
    atd = (json['t9:atd'] != null) ? json['t9:atd'] : json['t9:etd'];
    forecastAtd = (json['t9:departureType'] == 'Actual') ? false : true;
    station = Station(json['t10:crs'], json['t10:locationName']);

    if (json['t10:associations']?['t10:association']?['t10:category'] == "join") {
      joinWithRid = json['t10:associations']['t10:association']['t10:rid'];
    }
  }
}