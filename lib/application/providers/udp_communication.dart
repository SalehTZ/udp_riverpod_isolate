import 'dart:io';
import 'dart:isolate';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/udp_client.dart';
import '../core/udp_server.dart';

part 'udp_communication.g.dart';

@Riverpod(keepAlive: true)
class UdpCommunication extends _$UdpCommunication {
  late Isolate serverIsolate;
  late UdpServer _udpServer;
  late UdpClient _udpClient;
  final serverReceivePort = ReceivePort();

  @override
  FutureOr<void> build() async {
    const AsyncLoading();
    await _initializeCommunication();
    const AsyncData(null);
    return;
  }

  // static void _udpServerEntryPoint(SendPort sendPort) {
  //   _udpServer = UdpServer(sendPort: sendPort);
  //   _udpServer.startServer();
  // }

  Future<void> _initializeCommunication() async {
    _udpServer = UdpServer();
    // Start the UDP server in a separate isolate
    serverIsolate = await Isolate.spawn(
        UdpServer().startServer, serverReceivePort.sendPort);

    // Wait for the server to be ready
    await serverReceivePort.first;

    // Start the UDP client in the main isolate
    _udpClient = UdpClient();
  }

  List<InternetAddress> get getClientsAddresses => _udpServer.addresses;

  void sendMessage(String message, String address) {
    _udpClient.sendMessage(message, InternetAddress.tryParse(address)!);
  }

  void listenForMessages(Function(String) onMessageReceived) {}
}
