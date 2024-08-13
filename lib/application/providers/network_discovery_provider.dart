import 'package:network_discovery/network_discovery.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_discovery_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<NetworkAddress> networkDiscovery(NetworkDiscoveryRef ref) {
  return NetworkDiscovery.discoverMultiplePorts('192.168.1', [2234]);
}

// void testin() {
//   const List<int> ports = [2234];
//   final stream = NetworkDiscovery.discoverMultiplePorts('192.168.1', ports);

//   int found = 0;
//   stream.listen((NetworkAddress addr) {
//     found++;
//     print('Found device: ${addr.ip}:$port');
//   }).onDone(() => print('Finish. Found $found device(s)'));
// }
