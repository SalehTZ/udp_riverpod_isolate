import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../udp_communication.dart';

class UdpSocketNotifier extends StateNotifier<String> {
  final UdpSocketService _udpSocketService;

  UdpSocketNotifier(this._udpSocketService) : super('') {
    _initialize();
  }

  Future<void> _initialize() async {
    await _udpSocketService.initialize();
  }

  void sendMessage(String message) {
    _udpSocketService.sendMessage(message);
  }

  void receiveMessage(String message) {
    state = message;
  }

  @override
  void dispose() {
    _udpSocketService.close();
    super.dispose();
  }
}

final udpSocketProvider =
    StateNotifierProvider<UdpSocketNotifier, String>((ref) {
  final udpSocketService = UdpSocketService(address: '127.0.0.1', port: 12345);
  return UdpSocketNotifier(udpSocketService);
});
