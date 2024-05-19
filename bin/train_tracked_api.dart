import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:yaml/yaml.dart';

import 'package:train_tracked_api/ldbsvws.dart';
import 'package:train_tracked_api/logging.dart';

late dynamic configMap;

late String hostname;
late int port;
late String password;

String? apiKey;
late Uri ldbsvws;

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
    log.e("No OpenLDBSVWS API key specified. Terminating...");
    return -1;
  }

  if (password == "courgette") {
    log.w("Using default token 'courgette' - Please change this in the automatically generated config.yaml");
  }

  app.get('/arrivals', (Request request) async {
    final params = request.requestedUri.queryParameters;

    if (params['token'] != password) {
      log.i("Request /arrivals with invalid token");
      return Response.forbidden('Invalid access token');
    }
    if (params['crs']?.length != 3) {
      log.i("Request /arrivals with invalid crs");
      return Response.badRequest();
    }

    log.i("Request /arrivals?crs=${params['crs']}");

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
      log.i("Request /departures with invalid token");
      return Response.forbidden('Invalid access token');
    }
    if (params['crs']?.length != 3) {
      log.i("Request /departures with invalid crs");
      return Response.badRequest();
    }

    log.i("Request /departures?crs=${params['crs']}");

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
      log.i("Request /details with invalid token");
      return Response.forbidden('Invalid access token');
    }

    log.i("Request /details?rid=${params['rid']}");

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
  log.i("Serving Train-Tracked API at http://$hostname:$port");

  return 0;
}
