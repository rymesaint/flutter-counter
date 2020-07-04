import 'dart:async';

import 'package:flutter_counter/src/utils/network.dart';

class ConnectionChecker {
  Timer _timer;
  StreamController<bool> _network = StreamController();
  bool isOnline = false;
  Duration _duration = Duration(minutes: 1);

  ConnectionChecker({Duration duration}) {
    _duration = duration;
  }

  void run() {
    this.createStream();
    this.checkConnection();
  }

  void checkConnection() async {
    this.ping();
    _timer = Timer.periodic(_duration, (timer) async {
      this.ping();
    });
  }

  void createStream() {
    _network.stream.listen((bool isConnected) {
      isOnline = isConnected;
    });
  }

  void ping() async {
    if (_network.hasListener) {
      _network.add(await Network().isServerUp());
    }
  }

  void dispose() {
    _timer?.cancel();
    _network?.close();
  }
}
