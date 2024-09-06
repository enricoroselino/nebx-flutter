class HttpStatusCode {
  HttpStatusCode._();

  // status codes so i don't rely on package like :io
  static const int success = 200;

  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int timeout = 408;
  static const int unprocessableEntity = 422;

  static const int internalServerError = 500;
  static const int connectionTimedOut = 522;
  static const int gatewayTimeout = 504;

  static const int unknown = 999;
}
