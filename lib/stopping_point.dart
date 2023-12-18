import 'station.dart';

class StoppingPoint {
  String? platform;
  String? sta;
  String? ata;
  bool? ataForecast;
  String? std;
  String? atd;
  bool? atdForecast;
  String? crs;
  String? joinWithRid;
  bool? cancelledHere;

  StoppingPoint.fromJson(Map<String, dynamic> json) {
    platform = json['t9:platform'];
    sta = json['t9:sta'];
    ata = (json['t9:ata'] != null) ? json['t9:ata'] : json['t9:eta'];
    ataForecast = (json['t9:arrivalType'] == 'Actual') ? false : true;
    std = json['t9:std'];
    atd = (json['t9:atd'] != null) ? json['t9:atd'] : json['t9:etd'];
    atdForecast = (json['t9:departureType'] == 'Actual') ? false : true;
    crs = json['t10:crs'];

    if (json['t10:associations']?['t10:association']?['t10:category'] == "join") {
      joinWithRid = json['t10:associations']['t10:association']['t10:rid'];
    }

    cancelledHere = json['t9:isCancelled'];
  }

  Map toJson() {
    return {
      'cancelledHere' : cancelledHere,
      'platform' : platform,
      'sta' : sta,
      'ata' : ata,
      'ataForecast' : ataForecast,
      'std' : std,
      'atd' : atd,
      'atdForecast' : atdForecast,
      'crs' : crs,
      'attachRid' : joinWithRid,
    };
  }
}