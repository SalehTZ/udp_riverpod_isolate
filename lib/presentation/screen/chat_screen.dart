import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../application/providers/device_id_provider.dart';
import '../../application/providers/udp_communication.dart';
import '../../domain/models/messages_model.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String clientAddress;
  const ChatScreen({
    super.key,
    required this.clientAddress,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late AsyncValue<String?> deviceIdAsync;
  String? deviceId;
  String? udpMessage;
  final Box<MessageModel> messagesBox = Hive.box<MessageModel>('messagesBox');
  final _messageTextController = TextEditingController();
  late UdpCommunicationWorker udpCom;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ref.read(udpCommunicationProvider);
  }

  @override
  Widget build(BuildContext context) {
    deviceIdAsync = ref.watch(getDeviceIdProvider);
    ref.watch(udpCommunicationProvider);
    udpCom = ref.watch(udpCommunicationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clientAddress),
      ),
      body: Padding(
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
              child: ValueListenableBuilder<Box<MessageModel>>(
                  valueListenable: messagesBox.listenable(),
                  builder: (context, Box<MessageModel> box, _) {
                    final messages = box.values.toList();

                    // if there was no message
                    if (messages.isEmpty) {
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
                        } else if (messages[index].userId !=
                            messages[index + 1].userId) {
                          // Last message of the current user
                          hasTail = true;
                        }

                        return BubbleSpecialThree(
                          text: message.message,
                          tail: hasTail,
                          color: isSender
                              ? const Color(0xFF1B97F3)
                              : const Color(0xFFE8E8EE),
                          isSender: isSender,
                          textStyle: TextStyle(
                              color: isSender ? Colors.white : Colors.black,
                              fontSize: 16),
                        );
                      },
                    );
                  }),
            ),

            // * chat input
            TextField(
              controller: _messageTextController,
              onSubmitted: (text) {
                udpCom.sendMessage(text, widget.clientAddress);

                _addMessage();

                // _messageTextController.clear();
                setState(() {});
              },
              decoration: const InputDecoration(
                labelText: 'Write message ... ',
              ),
            ),
          ],
        ),
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
