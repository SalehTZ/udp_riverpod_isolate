import 'package:flutter/material.dart';

import 'conversations_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UDP Socket Example'),
      ),
      body: const ConversationsScreen(),
    );
  }
}
