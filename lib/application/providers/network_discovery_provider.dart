import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:network_discovery/network_discovery.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_discovery_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<List<InternetAddress>?> networkDiscovery(
    NetworkDiscoveryRef ref) async* {
  var discovery = NetworkDiscovery.discover('192.168.1', 2233);

  var allClients = const <InternetAddress>[];
  await for (final client
      in discovery.map((address) => InternetAddress(address.ip))) {
    debugPrint(client.toString());
    if (!allClients.contains(client)) {
      allClients = [...allClients, client];
    }
    yield allClients;
  }
}
