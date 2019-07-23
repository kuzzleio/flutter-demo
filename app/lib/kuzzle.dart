import 'package:kuzzle/kuzzle.dart';

final kuzzle = Kuzzle(
  WebSocketProtocol('10.35.251.242', port: 7512),
  offlineMode: OfflineMode.auto,
);