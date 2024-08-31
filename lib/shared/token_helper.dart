import 'package:universal_io/io.dart';

class TokenHelper {
  TokenHelper._();

  static Map<String, dynamic> addJWTHeader({
    required Map<String, dynamic> headers,
    required String token,
  }) {
    headers.addAll({HttpHeaders.authorizationHeader: "Bearer $token"});
    return headers;
  }
}
