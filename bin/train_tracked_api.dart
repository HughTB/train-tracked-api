import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:yaml/yaml.dart';

import 'package:train_tracked_api/ldbsvws.dart';
import 'package:train_tracked_api/util.dart';

late dynamic configMap;

late String hostname;
late int port;
late String password;

String? apiKey;
late Uri ldbsvws;

final app = Router();

Future<int?> main(List<String> arguments) async {
  if (await File('config.yaml').exists()) {
    final config = File('config.yaml').readAsStringSync();
    configMap = loadYaml(config);
  } else {
    log("Config file does not exist, or could not be loaded. Creating a new config.yaml", false);
    final config = File('config.yaml');
    config.writeAsStringSync('''
apiKey: null

server:
  hostname: '0.0.0.0'
  port: 42069
  password: 'courgette'
    ''');
    configMap = null;
  }

  hostname = configMap?['server']?['hostname'] ?? '0.0.0.0';
  port = configMap?['server']?['port'] ?? 42069;
  password = configMap?['server']?['password'] ?? "courgette";
  
  apiKey = configMap?['apiKey'];
  ldbsvws = Uri.parse(configMap?['ldbsvwsUrl'] ?? "https://lite.realtime.nationalrail.co.uk/OpenLDBSVWS/ldbsv13.asmx");

  if (apiKey == null) {
    log("No OpenLDBSVWS API key specified. Terminating...", true);
    return -1;
  }

  if (password == "courgette") {
    log("Using default token 'courgette' - Please change this in the automatically generated config.yaml", false);
  }

  app.get('/arrivals', (Request request) async {
    final params = request.requestedUri.queryParameters;

    if (params['token'] != password) {
      log("Request /arrivals with invalid token", false);
      return Response.forbidden('Invalid access token');
    }
    if (params['crs']?.length != 3) {
      log("Request /arrivals with invalid crs", false);
      return Response.badRequest();
    }

    log("Request /arrivals?crs=${params['crs']}", false);

    final trainServices = await getArrivalsByCrs(ldbsvws, apiKey!, params['crs']!.toUpperCase());
    final busServices = await getArrivalsByCrs(ldbsvws, apiKey!, params['crs']!.toUpperCase(), busServices: true);

    final results = trainServices + busServices;


    return Response.ok(
      <String, dynamic> {
        '"generatedAt"' : '"${DateTime.now().toIso8601String()}"',
        '"services"' : jsonEncode(results),
      }.toString(),
      headers: {
        "content-type" : "application/json",
      },
    );
  });

  app.get('/departures', (Request request) async {
    final params = request.requestedUri.queryParameters;

    if (params['token'] != password) {
      log("Request /departures with invalid token", false);
      return Response.forbidden('Invalid access token');
    }
    if (params['crs']?.length != 3) {
      log("Request /departures with invalid crs", false);
      return Response.badRequest();
    }

    log("Request /departures?crs=${params['crs']}", false);

    final trainServices = await getDeparturesByCrs(ldbsvws, apiKey!, params['crs']!.toUpperCase());
    final busServices = await getDeparturesByCrs(ldbsvws, apiKey!, params['crs']!.toUpperCase(), busServices: true);

    final results = trainServices + busServices;

    return Response.ok(
      <String, dynamic> {
        '"generatedAt"' : '"${DateTime.now().toIso8601String()}"',
        '"services"' : jsonEncode(results),
      }.toString(),
      headers: {
        "content-type" : "application/json",
      },
    );
  });

  app.get('/details', (Request request) async {
    final params = request.requestedUri.queryParameters;

    if (params['token'] != password) {
      log("Request /details with invalid token", false);
      return Response.forbidden('Invalid access token');
    }

    log("Request /details?rid=${params['rid']}", false);

    final results = await getServiceByRid(ldbsvws, apiKey!, params['rid']!);

    return Response.ok(
      <String, dynamic> {
        '"generatedAt"' : '"${DateTime.now().toIso8601String()}"',
        '"services"' : jsonEncode(results),
      }.toString(),
      headers: {
        "content-type" : "application/json",
      },
    );
  });

  await shelf_io.serve(app, hostname, port);
  log("Serving Train-Tracked API at http://$hostname:$port", false);

  return 0;
}
