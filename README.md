# Nebx

[![Pub](https://img.shields.io/pub/v/nebx.svg)](https://pub.dev/packages/nebx)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/enricoroselino/nebx-flutter/blob/master/LICENSE)

Nebx is a wrapper that support a powerful Dio HTTP client with error handling included.

## Get started

### Install

Add the `nebx` package to your [pubspec dependencies](https://pub.dev/packages/nebx/install).

## Examples

Build pre-made Dio instance using DioBuilderFactory to automatically provide and refresh Json Web Token with logger and internet interceptors: 

```dart
String loadToken() {
    // ... load your token here
    return "random.jwt.token";
}

IVerdict<String> refreshToken() {
  // ... do your api refreshing here then return the string
  return Verdict.successful("refreshed.jwt.token");
}

final checker = InternetCheckerImplementation();

final safeClient = DioBuilderFactory.clientJsonWebToken(
    baseUrl: "https://roselino.nebx.my.id/dummy",
    onTokenLoad: () => loadToken(),
    onTokenRefresh: () => refreshToken(),
    internetChecker: checker,
  )
  .addRequestTimeOut(receiveTimeOutSeconds: 15, requestTimeOutSeconds: 5)
  .build();
```

Build pre-made basic Dio instance with only logger and internet interceptors: 

```dart
final safeClient = DioBuilderFactory.clientBasic(
    baseUrl: "https://roselino.nebx.my.id/dummy",
    internetChecker: checker,
  )
  .build();
```


Build Dio instance manually with requirements:

1. disabled dio auto decoding into json
2. define your request content type into json
3. add request timeout
4. add internet checker interceptor

```dart
final checker = InternetCheckerImplementation();
final internetInterceptor = InternetInterceptor(checker: checker);

final safeClient = DioBuilder()
                    .addDisableAutoDecoding()
                    .addRequestContentType(type: HttpContentType.json)
                    .addRequestTimeOut(receiveTimeOutSeconds: 15, requestTimeOutSeconds: 5)
                    .addInterceptor(interceptor: (client) => internetInterceptor)
                    .addInterceptor(interceptor: (client) => anotherInterceptor)
                    .build();
```

Custom Internet Checker implementation: 
```dart
class YourOwnImplementation implements IInternetChecker {
    YourOwnImplementation() {
        // ... your implementation here.
    }
    
    @override
    Future<bool> get hasInternetAccess {
        // ... return the boolean here 
    }
}
```