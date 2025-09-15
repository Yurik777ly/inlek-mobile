import 'package:inlek/core/connectivity_service.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final ConnectivityService connectivityService;

  NetworkInfoImpl(this.connectivityService);

  @override
  Future<bool> get isConnected async {
    return await connectivityService.hasInternetConnection();
  }
}
