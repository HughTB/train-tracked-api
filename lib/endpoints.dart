import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';

import 'package:train_tracked_api/crs_list.g.dart';
import 'package:train_tracked_api/ldbsvws.dart';
import 'package:train_tracked_api/logging.dart';

class Endpoints {
  String passkey;
  String apiKey;
  Uri ldbsvws;

  Endpoints(this.passkey, this.apiKey, this.ldbsvws);

  bool _checkAuth(Request request) {
    return request.headers['x-api-key'] == passkey;
  }

  bool _isValidCrs(String? crs) {
    if (crs == null || crs.length != 3) { return false; }

    return crsList.contains(crs.toUpperCase());
  }

  bool _isValidCrsList(String? crsList) {
    if (crsList == null) { return false; }

    return crsList.split(",").fold(true, (prev, curr) => _isValidCrs(curr) && prev);
  }

  bool _isValidRid(String? rid) {
    if (rid == null || rid.length < 8 || rid.length > 16) { return false; }

    return true; // We can't really do more filtering than this, as there is no actual defined format for an RID
  }

  String _getRequestAddress(Request request) {
    return (request.context['shelf.io.connection_info'] as HttpConnectionInfo?)?.remoteAddress.address ?? "unknown";
  }

  Future<Response> arrivals(Request request) async {
    final params = request.requestedUri.queryParameters;

    log.i("${_getRequestAddress(request)} - /arrivals?crs=${params['crs']}");

    if (!_checkAuth(request)) {
      return Response.forbidden("Invalid api key");
    }
    if (!_isValidCrs(params['crs'])) {
      return Response.badRequest(body: "Invalid CRS code");
    }

    final trainServices = await getArrivalsByCrs(ldbsvws, apiKey, params['crs']!.toUpperCase());
    final busServices = await getArrivalsByCrs(ldbsvws, apiKey, params['crs']!.toUpperCase(), busServices: true);

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
  }

  Future<Response> departures(Request request) async {
    final params = request.requestedUri.queryParameters;

    log.i("${_getRequestAddress(request)} - /departures?crs=${params['crs']}");

    if (!_checkAuth(request)) {
      return Response.forbidden("Invalid api key");
    }
    if (!_isValidCrs(params['crs'])) {
      return Response.badRequest(body: "Invalid CRS code");
    }

    final trainServices = await getDeparturesByCrs(ldbsvws, apiKey, params['crs']!.toUpperCase());
    final busServices = await getDeparturesByCrs(ldbsvws, apiKey, params['crs']!.toUpperCase(), busServices: true);

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
  }

  Future<Response> details(Request request) async {
    final params = request.requestedUri.queryParameters;

    log.i("${_getRequestAddress(request)} - /details?rid=${params['rid']}");

    if (!_checkAuth(request)) {
      return Response.forbidden("Invalid api key");
    }
    if (!_isValidRid(params['rid'])) {
      return Response.badRequest(body: "Invalid RID");
    }

    final results = await getServiceByRid(ldbsvws, apiKey, params['rid']!);

    return Response.ok(
      <String, dynamic> {
        '"generatedAt"' : '"${DateTime.now().toIso8601String()}"',
        '"services"' : jsonEncode(results),
      }.toString(),
      headers: {
        "content-type" : "application/json",
      },
    );
  }

  Future<Response> disruptions(Request request) async {
    final params = request.requestedUri.queryParameters;
    log.i("${_getRequestAddress(request)} - /disruptions?crs=${params['crs']}");

    if (!_checkAuth(request)) {
      return Response.forbidden("Invalid api key");
    }
    if (!_isValidCrsList(params['crs'])) {
      return Response.badRequest(body: "One or more invalid CRS");
    }

    final results = await getDisruptionsByCrs(ldbsvws, apiKey, params['crs']!.split(","));

    return Response.ok(
      <String, dynamic> {
        '"generatedAt"' : '"${DateTime.now().toIso8601String()}"',
        '"disruptions"' : jsonEncode(results),
      }.toString(),
      headers: {
        "content-type" : "application/json",
      },
    );
  }
}