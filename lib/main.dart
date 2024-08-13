import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:udp_ws_riverpod_isolate/domain/models/messages_model.dart';

import 'application/providers/device_id_provider.dart';
import 'presentation/screen/home_screen.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(MessageModelAdapter());
  await Hive.openBox<MessageModel>('messagesBox');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(getDeviceIdProvider);

    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
