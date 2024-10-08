// // import 'dart:io';
// // import 'dart:isolate';

// // import 'application/core/udp_client.dart';
// import 'application/core/udp_server.dart';

// class UdpSocketService {
//   final String address;
//   final int port;
//   RawDatagramSocket? _socket;
//   late Isolate _isolate;
//   late ReceivePort _receivePort;

//   UdpSocketService({required this.address, required this.port});

//   Future<void> initialize() async {
//     _receivePort = ReceivePort();
//     _isolate = await Isolate.spawn(_isolateEntry, _receivePort.sendPort);

//     _receivePort.listen((message) {
//       if (message is String) {
//         // Handle received message
//         print('Received: $message');
//       }
//     });

//     _sendToIsolate({'command': 'initialize', 'address': address, 'port': port});
//   }

//   void sendMessage(String message) {
//     _sendToIsolate({'command': 'send', 'message': message});
//   }

//   void close() {
//     _sendToIsolate({'command': 'close'});
//     _isolate.kill(priority: Isolate.immediate);
//   }

//   void _sendToIsolate(Map<String, dynamic> message) {
//     _receivePort.sendPort.send(message);
//   }

//   static void _isolateEntry(SendPort sendPort) async {
//     final receivePort = ReceivePort();
//     sendPort.send(receivePort.sendPort);

//     RawDatagramSocket? socket;
//     await for (var message in receivePort) {
//       if (message is Map<String, dynamic>) {
//         switch (message['command']) {
//           case 'initialize':
//             socket = await RawDatagramSocket.bind(
//                 InternetAddress.anyIPv4, message['port']);
//             socket.listen((RawSocketEvent event) {
//               if (event == RawSocketEvent.read) {
//                 Datagram? datagram = socket?.receive();
//                 if (datagram != null) {
//                   String receivedMessage = String.fromCharCodes(datagram.data);
//                   sendPort.send(receivedMessage);
//                 }
//               }
//             });
//             break;
//           case 'send':
//             if (socket != null) {
//               socket.send(message['message'].codeUnits,
//                   InternetAddress(message['address']), message['port']);
//             }
//             break;
//           case 'close':
//             socket?.close();
//             break;
//         }
//       }
//     }
//   }
// }

// class UdpCommunication {
//   late Isolate serverIsolate;
//   late UdpServer _udpServer;
//   late UdpClient _udpClient;

//   UdpCommunication() {
//     initializeCommunication();
//   }

//   void _udpServerEntryPoint(SendPort sendPort) {
//     _udpServer = UdpServer(sendPort: sendPort);
//     _udpServer.startServer();
//   }

//   Future<void> initializeCommunication() async {
//     final serverReceivePort = ReceivePort();

//     // Start the UDP server in a separate isolate
//     serverIsolate =
//         await Isolate.spawn(_udpServerEntryPoint, serverReceivePort.sendPort);

//     // Wait for the server to be ready
//     await serverReceivePort.first;

//     // Start the UDP client in the main isolate
//     _udpClient = UdpClient();
//     _udpClient.start();
//   }

//   void sendMessage(String message, InternetAddress address) {
//     _udpClient.sendMessage(message, address);
//   }

//   void listenForMessages(Function(String) onMessageReceived) {}
// }
