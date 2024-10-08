import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';

import 'package:train_tracked_api/service.dart';
import 'package:train_tracked_api/disruption.dart';
import 'package:train_tracked_api/logging.dart';

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

Future<List<Service>> getArrivalsByCrs(Uri ldb, String apiKey, String crs, {int maxItems = 50, int timeWindow = 120, bool busServices = false}) async {
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
      <ldb:services>${(busServices) ? "B" : "P"}</ldb:services>
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

    if (jsonMap['soap:Envelope']['soap:Body']['GetArrivalBoardByCRSResponse']['GetBoardResult'][(busServices) ? 't13:busServices' : 't13:trainServices'] == null) {
      return results;
    }

    for (Map<String, dynamic> serviceJson in jsonMap['soap:Envelope']['soap:Body']['GetArrivalBoardByCRSResponse']['GetBoardResult'][(busServices) ? 't13:busServices' : 't13:trainServices']['t13:service']) {
      results.add(Service.fromBoardJson(serviceJson));
    }
  } else {
    log.w("Failed request for getArrivalsByCrs($ldb, APIKEY, $crs, $maxItems, $timeWindow)");
    log.w("Status: ${response.statusCode}");
    log.w("If you are seeing this request fail frequently, please send a bug report to bug-hunt@train-tracked.com");
  }

  return results;
}

Future<List<Service>> getDeparturesByCrs(Uri ldb, String apiKey, String crs, {int maxItems = 50, int timeWindow = 120, bool busServices = false}) async {
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
      <ldb:services>${(busServices) ? "B" : "P"}</ldb:services>
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

    if (jsonMap['soap:Envelope']['soap:Body']['GetDepartureBoardByCRSResponse']['GetBoardResult'][(busServices) ? 't13:busServices' : 't13:trainServices'] == null) {
      return results;
    }

    for (Map<String, dynamic> serviceJson in jsonMap['soap:Envelope']['soap:Body']['GetDepartureBoardByCRSResponse']['GetBoardResult'][(busServices) ? 't13:busServices' : 't13:trainServices']['t13:service']) {
      results.add(Service.fromBoardJson(serviceJson));
    }
  } else {
    log.w("Failed request for getDeparturesByCrs($ldb, APIKEY, $crs, $maxItems, $timeWindow)");
    log.w("Status: ${response.statusCode}");
    log.w("If you are seeing this request fail frequently, please send a bug report to bug-hunt@train-tracked.com");
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
    log.w("Failed request for getServiceByRid($ldb, APIKEY, $rid)");
    log.w("Status: ${response.statusCode}");
    log.w("If you are seeing this request fail frequently, please send a bug report to bug-hunt@train-tracked.com");
  }

  return result;
}

Future<Map<String, List<Disruption>>> getDisruptionsByCrs(Uri ldb, String apiKey, List<String> crsList) async {
  Map<String, List<Disruption>> result = {};

  final body = '''
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:typ="http://thalesgroup.com/RTTI/2013-11-28/Token/types" xmlns:ldb="http://thalesgroup.com/RTTI/2021-11-01/ldbsv/">
  <soapenv:Header>
    <typ:AccessToken>
      <typ:TokenValue>$apiKey</typ:TokenValue>
    </typ:AccessToken>
  </soapenv:Header>
  <soapenv:Body>
    <ldb:GetDisruptionListRequest>
      <ldb:CRSList>
        ${crsList.map((crs) => {"<ldb:crs>$crs</ldb:crs>\n"})}
      </ldb:CRSList>
    </ldb:GetDisruptionListRequest>
  </soapenv:Body>
</soapenv:Envelope>
''';

  final response = await makeRequest(ldb, body);

  if (response.statusCode == 200) {
    final jsonTransform = Xml2Json();
    jsonTransform.parse(response.body);
    final jsonStr = jsonTransform.toParker();
    Map<String, dynamic> jsonMap = json.decode(jsonStr);

    // Yes this bit is horrible, no I'm not going to do anything about it right now
    // Dart doesn't actually support XML so a wierd conversion to JSON first is the
    // best it's going to be for the moment
    if (jsonMap['soap:Envelope']['soap:Body']['GetDisruptionListResponse']['GetDisruptionListResult']['t5:item'] is Iterable) {
      for (dynamic item in jsonMap['soap:Envelope']['soap:Body']['GetDisruptionListResponse']['GetDisruptionListResult']['t5:item']) {
        List<Disruption> disruptions = [];

        if (item['t5:disruptions'] != null) {
          if (item['t5:disruptions']['t5:message'] is Iterable) {
            for (dynamic disruption in item['t5:disruptions']['t5:message']) {
              disruptions.add(Disruption.fromJson(disruption));
            }
          } else {
            disruptions.add(
                Disruption.fromJson(item['t5:disruptions']['t5:message']));
          }
        }

        result[item['t5:crs']] = disruptions;
      }
    } else {
      List<Disruption> disruptions = [];
      dynamic item = jsonMap['soap:Envelope']['soap:Body']['GetDisruptionListResponse']['GetDisruptionListResult']['t5:item'];

      if (item['t5:disruptions'] != null) {
        if (item['t5:disruptions']['t5:message'] is Iterable) {
          for (dynamic disruption in item['t5:disruptions']['t5:message']) {
            disruptions.add(Disruption.fromJson(disruption));
          }
        } else {
          disruptions.add(
              Disruption.fromJson(item['t5:disruptions']['t5:message']));
        }
      }

      result[item['t5:crs']] = disruptions;
    }
  } else {
    log.w("Failed request for getDisruptionsByCrs($ldb, APIKEY, $crsList)");
    log.w("Status: ${response.statusCode}");
    log.w("If you are seeing this request fail frequently, please send a bug report to bug-hunt@train-tracked.com");
  }

  return result;
}

Future<Map<String, String>> getDisruptionReasonText(Uri ldbRef, String apiKey, int code) async {
  Map<String, String> result = {};

  final body = '''
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:typ="http://thalesgroup.com/RTTI/2013-11-28/Token/types" xmlns:ldb="http://thalesgroup.com/RTTI/2021-11-01/ldbsv_ref/">
   <soapenv:Header>
      <typ:AccessToken>
         <typ:TokenValue>$apiKey</typ:TokenValue>
      </typ:AccessToken>
   </soapenv:Header>
   <soapenv:Body>
      <ldb:GetReasonCodeRequest>
         <ldb:reasonCode>$code</ldb:reasonCode>
      </ldb:GetReasonCodeRequest>
   </soapenv:Body>
</soapenv:Envelope>
''';

  final response = await makeRequest(ldbRef, body);

  if (response.statusCode == 200) {
    final jsonTransform = Xml2Json();
    jsonTransform.parse(response.body);
    final jsonStr = jsonTransform.toParker();
    Map<String, dynamic> jsonMap = json.decode(jsonStr);

    result = {
      'reasonCode': jsonMap['soap:Envelope']['soap:Body']['GetReasonCodeResponse']['GetReasonCodeResult']['t5:code'],
      'delayText': jsonMap['soap:Envelope']['soap:Body']['GetReasonCodeResponse']['GetReasonCodeResult']['t5:lateReason'],
      'cancelText': jsonMap['soap:Envelope']['soap:Body']['GetReasonCodeResponse']['GetReasonCodeResult']['t5:cancReason'],
    };

    return result;
  } else {
    log.w("Failed request for getDisruptionReasonText($ldbRef, APIKEY, $code)");
    log.w("Status: ${response.statusCode}");
    log.w("If you are seeing this request fail frequently, please send a bug report to bug-hunt@train-tracked.com");
  }

  return result;
}