import 'dart:convert';

import 'package:xml2json/xml2json.dart';

class HttpRequestHelper {
  HttpRequestHelper._();

  static Map<String, dynamic> jsonStringToMap(dynamic responseData) {
    return jsonDecode(responseData as String);
  }

  static String mapToJsonString(Map<String, dynamic> payload) {
    return jsonEncode(payload);
  }

  static Map<String, dynamic> xmlStringToMap(dynamic responseData) {
    final xmlParser = Xml2Json();
    xmlParser.parse(responseData as String);
    final Map<String, dynamic> jsonObject = jsonDecode(xmlParser.toParker());
    return jsonObject;
  }
}
