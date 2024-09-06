import 'package:nebx/src/infrastructure/services/dio_request/constants/http_header_key.dart';

class TokenHelper {
  TokenHelper._();

  static Map<String, dynamic> addJWTHeader({
    required Map<String, dynamic> headers,
    required String token,
  }) {
    headers.addAll({HttpHeaderKey.authorization: "Bearer $token"});
    return headers;
  }
}
