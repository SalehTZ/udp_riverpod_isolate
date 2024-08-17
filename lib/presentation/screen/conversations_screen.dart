import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/udp_communication.dart';
import 'chat_screen.dart';

class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  late UdpCommunicationWorker udpProviderNotifier;
  late AsyncValue<void> udpProvider;

  List<InternetAddress>? clients;

  @override
  void initState() {
    super.initState();

    // ref.read(udpCommunicationProvider);
  }

  @override
  Widget build(BuildContext context) {
    udpProvider = ref.watch(udpCommunicationProvider);
    udpProviderNotifier = ref.watch(udpCommunicationProvider.notifier);

    return Center(
      child: Card(
        child: TextField(
          onSubmitted: (clientAddress) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                clientAddress: clientAddress,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
