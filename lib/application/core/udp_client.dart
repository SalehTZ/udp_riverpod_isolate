import 'dart:convert';
import 'dart:developer';
import 'dart:io';

class UdpClient {
  late RawDatagramSocket client;
  final broadcastAddress = InternetAddress('255.255.255.255');
  final serverPort = 2233;
  final clientPort = 2234;

  UdpClient() {
    _initialize();
  }

  void _initialize() async {
    // Delay to ensure the server is up and running
    await Future.delayed(const Duration(seconds: 1));

    // Create a UDP socket
    client = await RawDatagramSocket.bind(InternetAddress.anyIPv4, clientPort);
    client.broadcastEnabled = true;

    // Send a broadcast message
    final message = utf8.encode('Device');
    client.send(message, broadcastAddress, serverPort);
    log('Broadcast message sent');

    // Listen for responses from the server
    client.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        final datagram = client.receive();
        if (datagram != null) {
          final response = utf8.decode(datagram.data);
          log('Client Received response: $response from ${datagram.address.address}:${datagram.port}');
        }
      }
    });
  }

  void sendMessage(String message, InternetAddress address) {
    final data = utf8.encode(message);
    client.send(data, address, serverPort);
    log('Message sent to ${address.address}:$serverPort');
  }
}
