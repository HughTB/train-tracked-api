import 'dart:io';
import 'package:yaml/yaml.dart';

import 'package:train_tracked_api/stopping_point.dart';
import 'package:train_tracked_api/service.dart';
import 'package:train_tracked_api/ldbsvws.dart';
import 'package:train_tracked_api/util.dart';

late String hostname;
late int port;
late String password;

String? apiKey;
late Uri ldbsvws;

Future<int?> main(List<String> arguments) async {
  final config = File('config.yaml').readAsStringSync();
  final configMap = loadYaml(config);

  hostname = configMap['server']['hostname'] ?? '0.0.0.0';
  port = configMap['server']['port'] ?? 42069;
  password = configMap['server']['password'] ?? "courgette";
  
  apiKey = configMap['apiKey'];
  ldbsvws = Uri.parse(configMap['ldbsvwsUrl'] ?? "https://lite.realtime.nationalrail.co.uk/OpenLDBSVWS/ldbsv13.asmx");

  if (apiKey == null) {
    log("No API key specified. Terminating...", true);
    return -1;
  }

  print("==== Arrivals to SOU ====");

  final arrServices = await getDeparturesByCrs(ldbsvws, apiKey!, "SOU");

  for (Service service in arrServices) {
    print("${service.rid}: ${service.origin[0].stationName} -> ${service.destination[0].stationName}");
  }

  print("==== Departures from SOU ====");

  final depServices = await getDeparturesByCrs(ldbsvws, apiKey!, "SOU");

  for (Service service in depServices) {
    print("${service.rid}: ${service.origin[0].stationName} -> ${service.destination[0].stationName}");
  }

  print("==== Service details for ${depServices.first.rid} ====");

  Service? firstDep = await getServiceByRid(ldbsvws, apiKey!, depServices.first.rid);

  if (firstDep != null) {
    for (StoppingPoint sp in firstDep.stoppingPoints) {
      print("${sp.std}: ${sp.station.stationName}");
    }
  }

  return 0;
}
