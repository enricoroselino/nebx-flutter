import 'dart:convert';

import 'package:xml2json/xml2json.dart';

class CodecHelper {
  CodecHelper._();

  static T decodeJson<T>(String jsonString) {
    return jsonDecode(jsonString) as T;
  }

  static T decodeXml<T>(String xmlString) {
    final xmlParser = Xml2Json();
    xmlParser.parse(xmlString);
    return decodeJson<T>(xmlParser.toParker());
  }

  static String encodeJson(dynamic object) {
    return jsonEncode(object);
  }
}
