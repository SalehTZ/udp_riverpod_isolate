import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../application/providers/device_id_provider.dart';
import '../../application/providers/socket_provider.dart';
import '../../domain/models/messages_model.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late AsyncValue<String?> deviceIdAsync;
  late String? deviceId;
  String? udpMessage;
  UdpSocketNotifier? udpMessageProvider;
  List<Map<String, dynamic>> messages = [
    {'userId': 'user1', 'message': 'Hello1!'},
    {'userId': 'user1', 'message': 'Hello2!'},
    {'userId': 'user2', 'message': 'Hi there!'},
    {'userId': 'user1', 'message': 'How are you?'},
    {'userId': 'user2', 'message': 'I am good, thanks!'},
    // Add more messages as needed
  ];
  final Box<MessageModel> messagesBox = Hive.box<MessageModel>('messagesBox');
  final _messageTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    deviceIdAsync = ref.watch(getDeviceIdProvider);
    udpMessage = ref.watch(udpSocketProvider);
    udpMessageProvider = ref.watch(udpSocketProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          deviceIdAsync.when(
            data: (data) {
              deviceId = data;
              return Text('deviceId: $data');
            },
            error: (error, stackTrace) => Text(error.toString()),
            loading: () => const Text('Loading device id...'),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ValueListenableBuilder(
                valueListenable: messagesBox.listenable(),
                builder: (context, Box<MessageModel> box, _) {
                  // if there was no message
                  if (box.values.isEmpty) {
                    return const Center(child: Text('No messages'));
                  }

                  return ListView.builder(
                    itemCount: box.values.length,
                    itemBuilder: (context, index) {
                      final message = box.getAt(index);

                      bool isSender = message!.userId == deviceId;

                      bool hasTail = false;
                      if (index == messages.length - 1) {
                        // Last message in the list
                        hasTail = true;
                      } else if (messages[index]['userId'] !=
                          messages[index + 1]['userId']) {
                        // Last message of the current user
                        hasTail = true;
                      }

                      return BubbleSpecialThree(
                        text: messages[index]['message'],
                        tail: hasTail,
                        color: isSender
                            ? const Color(0xFFE8E8EE)
                            : const Color(0xFF1B97F3),
                        isSender: isSender,
                        textStyle:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      );
                    },
                  );
                }),
          ),

          // * chat input
          TextField(
            controller: _messageTextController,
            onSubmitted: (text) {
              // udpMessageProvider?.sendMessage(text);

              _addMessage();

              _messageTextController.clear();
              setState(() {});
            },
            decoration: const InputDecoration(
              labelText: 'Write message ... ',
            ),
          ),
        ],
      ),
    );
  }

  void _addMessage() {
    final message = MessageModel(
      userId: deviceId!,
      message: _messageTextController.text,
      timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    messagesBox.add(message);
    _messageTextController.clear();
  }
}
