import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityService {
  static const _hosts = [
    'google.com',
    'cloudflare.com',
    'apple.com',
    'microsoft.com',
    'yahoo.com',
  ];

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription _subscription;
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectionController.stream;

  ConnectivityService() {
    _subscription = _connectivity.onConnectivityChanged.listen((result) async {
      bool hasConnection = await _evaluateConnection(result);
      _connectionController.add(hasConnection);
    });
  }

  void dispose() {
    print('[ConnectivityService] Disposing subscription');
    _subscription.cancel();
    _connectionController.close();
  }

  Future<bool> _evaluateConnection(List<ConnectivityResult> result) async {
    bool hasWifiOrData = result.any((e) =>
        [ConnectivityResult.wifi, ConnectivityResult.mobile].contains(e));

    print('[ConnectivityService] Connectivity result: $result');
    print('[ConnectivityService] hasWifiOrData: $hasWifiOrData');

    if (!hasWifiOrData) {
      bool internet = await checkInternetAccess();
      print('[ConnectivityService] Internet access: $internet');
      return internet;
    }

    return true;
  }

  Future<bool> hasInternetConnection() async {
    final connectivity = await _connectivity.checkConnectivity();
    return _evaluateConnection(connectivity);
  }

  Future<bool> checkInternetAccess() async {
    for (var host in _hosts) {
      try {
        print('[ConnectivityService] Trying host: $host');
        final result =
            await InternetAddress.lookup(host).timeout(Duration(seconds: 3));
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          print('[ConnectivityService] Host reachable: $host');
          return true;
        }
      } catch (e) {
        print('[ConnectivityService] Host failed: $host, error: $e');
      }
    }

    print('[ConnectivityService] Fallback to InternetConnectionChecker');
    bool internet = await InternetConnectionChecker.instance.hasConnection;
    print('[ConnectivityService] InternetConnectionChecker: $internet');
    return internet;
  }
}
