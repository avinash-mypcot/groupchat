import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkService {
  // static ConnectivityResult? result;

  // static void observeNetwork() async {
  //   bool isConnected = await InternetConnectionChecker().hasConnection;
  //   Connectivity()
  //       .onConnectivityChanged
  //       .forEach((List<ConnectivityResult> results) {
  //     final ConnectivityResult result = results.first;

  //     if (result == ConnectivityResult.none) {
  //       NetworkBloc().add(NetworkNotify());
  //     } else {
  //       if (isConnected) {
  //         NetworkBloc().add(NetworkNotify(isConnected: true));
  //       }
  //     }
  //   });
  // }

  static Stream<bool> observeNetwork() {
    
    return Connectivity()
        .onConnectivityChanged
        .asyncMap((List<ConnectivityResult> results) async {
      final ConnectivityResult result = results.first;
      return result != ConnectivityResult.none &&
          await InternetConnection().hasInternetAccess;
    });
  }

  // static Stream<bool> observeNetwork() {
  //   return Connectivity()
  //       .onConnectivityChanged
  //       .asyncMap((List<ConnectivityResult> results) async {
  //     ConnectivityResult result = results.first;
  //     print("Network op: $result");

  //     // Use a completer to wait for the internet connection status
  //     final completer = Completer<bool>();

  //     InternetConnection().onStatusChange.listen((InternetStatus status) {
  //       switch (status) {
  //         case InternetStatus.connected:
  //           print("Internet Connected");
  //           completer.complete(result != ConnectivityResult.none);
  //         case InternetStatus.disconnected:
  //           print("Internet Not Connected");
  //           completer.complete(false);
  //       }
  //     });

  //     // Wait for the completer to resolve
  //     return completer.future;
  //   });
  // }
}
