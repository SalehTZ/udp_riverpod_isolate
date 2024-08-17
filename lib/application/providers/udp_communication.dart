import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/messages_model.dart';
import '../core/udp_client.dart';

part 'udp_communication.g.dart';

@Riverpod(keepAlive: true)
class UdpCommunicationWorker extends _$UdpCommunication {
  // late Isolate serverIsolate;
  // late UdpServer _udpServer;
  // final serverReceivePort = ReceivePort();

  late UdpClient _udpClient;
  late SendPort _sendPort;
  final Completer<void> _isolateReady = Completer.sync();
  final Box<MessageModel> messagesBox = Hive.box<MessageModel>('messagesBox');

  @override
  FutureOr<void> build() async {
    const AsyncLoading();
    await _initializeCommunication();
    const AsyncData(null);
    return;
  }

  Future<void> _spawnIsolate() async {
    final receivePort = ReceivePort();
    receivePort.listen(_handleResponsesFromIsolate);
    await Isolate.spawn(_startServer, receivePort.sendPort);
  }

  static void _startServer(SendPort port) async {
    const serverPort = 2233;
    final List<InternetAddress> addresses = List.empty(growable: true);
    final receivePort = ReceivePort();

    RawDatagramSocket server =
        await RawDatagramSocket.bind(InternetAddress.anyIPv4, serverPort);
    log('UDP Server listening on port $serverPort');

    // Notify the main isolate that the server is ready
    port.send(receivePort.sendPort);

    server.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        final datagram = server.receive();
        if (datagram != null) {
          final message = utf8.decode(datagram.data);
          log('Received broadcast: $message from ${datagram.address.address}:${datagram.port}');

          if (message != 'Device') {
            port.send(MessageModel(
              userId: datagram.address.address,
              message: message,
              timestamp: DateTime.now().toString(),
            ));
          }

          addresses.add(datagram.address);

          // Respond to the broadcast with device details
          final response =
              utf8.encode('Device at ${InternetAddress.anyIPv4.address}');
          server.send(response, datagram.address, datagram.port);
        }
      }
    });
  }

  void _handleResponsesFromIsolate(dynamic message) {
    if (message is SendPort) {
      _sendPort = message;
      _isolateReady.complete();
      debugPrint('isolate is ready!');
    } else if (message is MessageModel) {
      debugPrint(
          'MessageModel -> message: ${message.message} from ${message.userId} on ${message.timestamp}');
      messagesBox.add(message);
    }
  }

  Future<void> _initializeCommunication() async {
    // _udpServer = UdpServer();
    // serverIsolate = await Isolate.spawn(
    //     UdpServer().startServer, serverReceivePort.sendPort);

    // Start the UDP server in a separate isolate
    _spawnIsolate();

    // Wait for the server to be ready
    // await serverReceivePort.first;

    // Start the UDP client in the main isolate
    _udpClient = UdpClient();
  }

  // List<InternetAddress> get getClientsAddresses => _udpServer.addresses;

  void sendMessage(String message, String address) {
    _udpClient.sendMessage(message, InternetAddress(address));
  }

  void listenForMessages(Function(String) onMessageReceived) {}
}
