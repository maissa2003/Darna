import 'package:hive_ce/hive.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 2)
class ChatMessage extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String conversationId;
  @HiveField(2)
  String propertyId;
  @HiveField(3)
  String studentId;
  @HiveField(4)
  String ownerId;
  @HiveField(5)
  String senderId;
  @HiveField(6)
  String text;
  @HiveField(7)
  DateTime sentAt;
  @HiveField(8)
  bool isRead;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.propertyId,
    required this.studentId,
    required this.ownerId,
    required this.senderId,
    required this.text,
    required this.sentAt,
    this.isRead = false,
  });
}
