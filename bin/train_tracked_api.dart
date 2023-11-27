import 'dart:io';
import 'package:yaml/yaml.dart';

import 'package:train_tracked_api/service.dart';
import 'package:train_tracked_api/ldbsvws.dart';
import 'package:train_tracked_api/util.dart';

late int port;
late String? apiKey;
late String apiPassword;
late Uri ldbsvws;

Future<int?> main(List<String> arguments) async {
  final config = File('config.yaml').readAsStringSync();
  final configMap = loadYaml(config);

  port = configMap['port'] ?? 42069;
  apiKey = configMap['apiKey'];
  apiPassword = configMap['password'] ?? "courgette";
  ldbsvws = Uri.parse(configMap['ldbsvwsUrl'] ?? "https://lite.realtime.nationalrail.co.uk/OpenLDBSVWS/ldbsv13.asmx");

  if (apiKey == null) {
    log("No API key specified. Terminating...", true);
    return -1;
  }

  print("==== Arrivals to SOU ====");

  final arrServices = await getDeparturesByCrs(ldbsvws, apiKey!, "SOU");

  for (Service service in arrServices) {
    print("${service.rid}: ${service.origin.stationName} -> ${service.destination.stationName}");
  }

  print("==== Departures from SOU ====");

  final depServices = await getDeparturesByCrs(ldbsvws, apiKey!, "SOU");

  for (Service service in depServices) {
    print("${service.rid}: ${service.origin.stationName} -> ${service.destination.stationName}");
  }

  return 0;
}
