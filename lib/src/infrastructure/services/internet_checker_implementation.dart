import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract interface class IInternetChecker {
  Future<bool> get hasInternetAccess;
}

class InternetCheckerImplementation implements IInternetChecker {
  late final InternetConnection _connection;

  InternetCheckerImplementation() {
    _connection = InternetConnection.createInstance(
      checkInterval: const Duration(seconds: 5),
      customCheckOptions: [
        InternetCheckOption(uri: Uri.parse('https://one.one.one.one')),
      ],
    );
  }

  @override
  Future<bool> get hasInternetAccess async =>
      await _connection.hasInternetAccess;
}