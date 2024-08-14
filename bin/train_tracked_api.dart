import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:yaml/yaml.dart';

import 'package:train_tracked_api/endpoints.dart';
import 'package:train_tracked_api/logging.dart';

late dynamic configMap;

late String hostname;
late int port;
late String token;

String? apiKey;
late Uri ldbsvws;
late Uri ldbsvwsRef;

final app = Router();

Future<int?> main(List<String> arguments) async {
  log = Logger('api.log', true, Level.debug);

  if (await File('config.yaml').exists()) {
    final config = File('config.yaml').readAsStringSync();
    configMap = loadYaml(config);
  } else {
    log.i("Config file does not exist, or could not be loaded. Creating a new config.yaml");
    final config = File('config.yaml');
    config.writeAsStringSync('''
ldbsvws:
  key: null # Darwin LDBSVWS key
  url: null # Uses the official NRE endpoint unless otherwise specified
  ref-url: null # Uses the official NRE reference endpoint unless otherwise specified

server:
  hostname: '0.0.0.0'
  port: 42069
  key: 'courgette'
  url: null # URL to redirect to when request is made to the index
    ''');
    configMap = null;
  }

  hostname = configMap?['server']?['hostname'] ?? '0.0.0.0';
  port = configMap?['server']?['port'] ?? 42069;
  token = configMap?['server']?['key'] ?? "courgette";
  
  apiKey = configMap?['ldbsvws']?['key'];
  ldbsvws = Uri.parse(configMap?['ldbsvws']?['url'] ?? "https://lite.realtime.nationalrail.co.uk/OpenLDBSVWS/ldbsv13.asmx");
  ldbsvwsRef = Uri.parse(configMap?['ldbsvws']?['ref-url'] ?? "https://lite.realtime.nationalrail.co.uk/OpenLDBSVWS/ldbsvref1.asmx");

  if (apiKey == null) {
    log.e("No OpenLDBSVWS API key specified. Terminating...");
    return -1;
  }

  if (token == "courgette") {
    log.w("Using default key 'courgette' - Please change this in config.yaml");
  }

  Endpoints endpoints = Endpoints(token, apiKey!, ldbsvws, ldbsvwsRef);

  // Add redirect if specified in config
  if (configMap?['server']?['url'] != null) {
    app.get('/', (Request request) { return Response.movedPermanently(configMap?['server']?['url']); });
  }

  app.get('/arrivals', endpoints.arrivals);
  app.get('/departures', endpoints.departures);
  app.get('/details', endpoints.details);
  app.get('/disruptions', endpoints.disruptions);
  app.get('/disruption-code', endpoints.disruptionCode);

  await shelf_io.serve(app, hostname, port);
  log.i("Serving Train-Tracked API at http://$hostname:$port");

  return 0;
}
