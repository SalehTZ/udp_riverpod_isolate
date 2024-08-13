import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

class UdpServer {
  late RawDatagramSocket server;
  final serverPort = 2233;
  final List<InternetAddress> addresses = List.empty(growable: true);

  // final SendPort sendPort;

  UdpServer();

  void startServer(SendPort sendPort) async {
    server = await RawDatagramSocket.bind(InternetAddress.anyIPv4, serverPort);
    log('UDP Server listening on port $serverPort');

    // Notify the main isolate that the server is ready
    sendPort.send(null);

    server.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        final datagram = server.receive();
        if (datagram != null) {
          final message = utf8.decode(datagram.data);
          log('Received broadcast: $message from ${datagram.address.address}:${datagram.port}');

          addresses.add(datagram.address);
          // Respond to the broadcast with device details
          final response =
              utf8.encode('Device at ${InternetAddress.anyIPv4.address}');
          server.send(response, datagram.address, datagram.port);
        }
      }
    });
  }
}
