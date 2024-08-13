import 'dart:developer';
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
  late UdpCommunication udpProviderNotifier;
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

    return udpProvider.when(
      data: (value) {
        clients = udpProviderNotifier.getClientsAddresses;
        for (var client in clients!) {
          debugPrint(client.address);
        }
        if (clients != null) {
          if (clients!.isEmpty) {
            return const Center(child: Text('No clients connected'));
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(clients![index].address),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatScreen(),
                    ),
                  ),
                );
              },
            ),
          );
        }
        return const Center(child: Text('No clients connected'));
      },
      error: (error, stackTrace) {
        log(error.toString(), stackTrace: stackTrace);
        return Center(child: Text(error.toString()));
      },
      loading: () {
        log('Loading...');
        return const Center(child: Text('Loading...'));
      },
    );
  }
}
