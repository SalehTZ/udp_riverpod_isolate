import 'package:hive/hive.dart';

part 'messages_model.g.dart';

@HiveType(typeId: 0)
class MessageModel extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  String message;

  @HiveField(2)
  String timestamp;

  MessageModel({
    required this.userId,
    required this.message,
    required this.timestamp,
  });
}
