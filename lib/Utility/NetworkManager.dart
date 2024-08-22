import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
class NetworkManager {
  // Singleton instance
  static final NetworkManager _instance = NetworkManager._internal();

  factory NetworkManager() {
    return _instance;
  }
  Future<bool> checkconnectionstatus() async {
    final url = Uri.parse('https://www.google.com');

    try {
      final response = await http.get(url);

      return response.statusCode == 200;
    } catch (e) {
      print('Error checking Google status: $e');
      return false;
    }
  }
  NetworkManager._internal();

  // Check if device is connected to the internet
  Future<bool> isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Listen to connectivity changes
  Stream<ConnectivityResult> get connectivityStream {
    return Connectivity().onConnectivityChanged;
  }

}