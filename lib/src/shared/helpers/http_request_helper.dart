import 'dart:convert';

import 'package:xml2json/xml2json.dart';

class HttpRequestHelper {
  HttpRequestHelper._();

  static Map<String, dynamic> jsonStringToMap(String responseData) {
    return jsonDecode(responseData);
  }

  static String mapToJsonString(Map<String, dynamic> payload) {
    return jsonEncode(payload);
  }

  static Map<String, dynamic> xmlStringToMap(String responseData) {
    final xmlParser = Xml2Json();
    xmlParser.parse(responseData);
    return jsonStringToMap(xmlParser.toParker());
  }
}
