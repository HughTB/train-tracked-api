import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';

import 'package:train_tracked_api/service.dart';
import 'package:train_tracked_api/util.dart';

Future<http.Response> makeRequest(Uri uri, String soapBody) {
  return http.post(
    uri,
    headers: {
      "Content-Type": "text/xml;charset=UTF-8",
    },
    body: utf8.encode(soapBody),
    encoding: Encoding.getByName("UTF-8"),
  );
}

Future<List<Service>> getArrivalsByCrs(Uri ldb, String apiKey, String crs, {int maxItems = 50, int timeWindow = 120}) async {
  List<Service> results = [];

  if (maxItems <= 0 || maxItems > 150 || timeWindow <= 0 || timeWindow > 1440) { return results; }

  final body = '''
  <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:typ="http://thalesgroup.com/RTTI/2013-11-28/Token/types" xmlns:ldb="http://thalesgroup.com/RTTI/2021-11-01/ldbsv/">
    <soapenv:Header>
      <typ:AccessToken>
        <typ:TokenValue>$apiKey</typ:TokenValue>
      </typ:AccessToken>
    </soapenv:Header>
    <soapenv:Body>
      <ldb:GetArrivalBoardByCRSRequest>
        <ldb:numRows>$maxItems</ldb:numRows>
        <ldb:crs>$crs</ldb:crs>
        <ldb:time>${DateTime.now().toIso8601String()}</ldb:time>
        <ldb:timeWindow>$timeWindow</ldb:timeWindow>
      </ldb:GetArrivalBoardByCRSRequest>
    </soapenv:Body>
  </soapenv:Envelope>
  ''';

  final response = await makeRequest(ldb, body);

  if (response.statusCode == 200) {
    final jsonTransform = Xml2Json();
    jsonTransform.parse(response.body);
    final jsonStr = jsonTransform.toParker();
    Map<String, dynamic> jsonMap = json.decode(jsonStr);

    if (jsonMap['soap:Envelope']['soap:Body']['GetArrivalBoardByCRSResponse']['GetBoardResult']['t13:trainServices'] == null) {
      return results;
    }

    for (Map<String, dynamic> serviceJson in jsonMap['soap:Envelope']['soap:Body']['GetArrivalBoardByCRSResponse']['GetBoardResult']['t13:trainServices']['t13:service']) {
      results.add(Service.fromBoardJson(serviceJson));
    }
  } else {
    log("getArrivalsByCrs($ldb, APIKEY, $crs, $maxItems, $timeWindow):", true);
    log("Status: ${response.statusCode}", true);
    log("Body:   ${response.body}", true);
  }

  return results;
}

Future<List<Service>> getDeparturesByCrs(Uri ldb, String apiKey, String crs, {int maxItems = 50, int timeWindow = 120}) async {
  List<Service> results = [];

  if (maxItems <= 0 || maxItems > 150 || timeWindow <= 0 || timeWindow > 1440) { return results; }

  final body = '''
  <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:typ="http://thalesgroup.com/RTTI/2013-11-28/Token/types" xmlns:ldb="http://thalesgroup.com/RTTI/2021-11-01/ldbsv/">
    <soapenv:Header>
      <typ:AccessToken>
        <typ:TokenValue>$apiKey</typ:TokenValue>
      </typ:AccessToken>
    </soapenv:Header>
    <soapenv:Body>
      <ldb:GetDepartureBoardByCRSRequest>
        <ldb:numRows>$maxItems</ldb:numRows>
        <ldb:crs>$crs</ldb:crs>
        <ldb:time>${DateTime.now().toIso8601String()}</ldb:time>
        <ldb:timeWindow>$timeWindow</ldb:timeWindow>
      </ldb:GetDepartureBoardByCRSRequest>
    </soapenv:Body>
  </soapenv:Envelope>
  ''';

  final response = await makeRequest(ldb, body);

  if (response.statusCode == 200) {
    final jsonTransform = Xml2Json();
    jsonTransform.parse(response.body);
    final jsonStr = jsonTransform.toParker();
    Map<String, dynamic> jsonMap = json.decode(jsonStr);

    if (jsonMap['soap:Envelope']['soap:Body']['GetDepartureBoardByCRSResponse']['GetBoardResult']['t13:trainServices'] == null) {
      return results;
    }

    for (Map<String, dynamic> serviceJson in jsonMap['soap:Envelope']['soap:Body']['GetDepartureBoardByCRSResponse']['GetBoardResult']['t13:trainServices']['t13:service']) {
      results.add(Service.fromBoardJson(serviceJson));
    }
  } else {
    log("getDeparturesByCrs($ldb, APIKEY, $crs, $maxItems, $timeWindow):", true);
    log("Status: ${response.statusCode}", true);
    log("Body:   ${response.body}", true);
  }

  return results;
}

Future<Service?> getServiceByRid(Uri ldb, String apiKey, String rid) async {
  Service? result;

  final body = '''
  <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:typ="http://thalesgroup.com/RTTI/2013-11-28/Token/types" xmlns:ldb="http://thalesgroup.com/RTTI/2021-11-01/ldbsv/">
    <soapenv:Header>
      <typ:AccessToken>
        <typ:TokenValue>$apiKey</typ:TokenValue>
      </typ:AccessToken>
    </soapenv:Header>
    <soapenv:Body>
      <ldb:GetServiceDetailsByRIDRequest>
        <ldb:rid>$rid</ldb:rid>
      </ldb:GetServiceDetailsByRIDRequest>
    </soapenv:Body>
  </soapenv:Envelope>
  ''';

  final response = await makeRequest(ldb, body);

  if (response.statusCode == 200) {
    final jsonTransform = Xml2Json();
    jsonTransform.parse(response.body);
    final jsonStr = jsonTransform.toParker();
    Map<String, dynamic> jsonMap = json.decode(jsonStr);

    result = Service.fromDetailsJson(jsonMap['soap:Envelope']['soap:Body']['GetServiceDetailsByRIDResponse']['GetServiceDetailsResult']);
  } else {
    log("getServiceByRid($ldb, APIKEY, $rid):", true);
    log("Status: ${response.statusCode}", true);
    log("Body:   ${response.body}", true);
  }

  return result;
}