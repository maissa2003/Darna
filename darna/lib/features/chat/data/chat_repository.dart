import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/box_names.dart';
import '../models/chat_message.dart';

class ChatRepository {
  static Box<ChatMessage> get _box =>
      Hive.box<ChatMessage>(BoxNames.chatMessages);

  static String conversationId({
    required String propertyId,
    required String studentId,
    required String ownerId,
  }) => '$propertyId:$studentId:$ownerId';

  static List<ChatMessage> messages(String conversationId) =>
      _box.values
          .where((message) => message.conversationId == conversationId)
          .toList()
        ..sort((a, b) => a.sentAt.compareTo(b.sentAt));

  static List<ChatMessage> forUser(String userId) =>
      _box.values
          .where(
            (message) =>
                message.studentId == userId || message.ownerId == userId,
          )
          .toList()
        ..sort((a, b) => b.sentAt.compareTo(a.sentAt));

  static Future<ChatMessage> send({
    required String propertyId,
    required String studentId,
    required String ownerId,
    required String senderId,
    required String text,
  }) async {
    final message = ChatMessage(
      id: const Uuid().v4(),
      conversationId: conversationId(
        propertyId: propertyId,
        studentId: studentId,
        ownerId: ownerId,
      ),
      propertyId: propertyId,
      studentId: studentId,
      ownerId: ownerId,
      senderId: senderId,
      text: text.trim(),
      sentAt: DateTime.now(),
    );
    await _box.put(message.id, message);
    return message;
  }

  static Future<void> markRead(String conversationId, String userId) async {
    for (final message in messages(
      conversationId,
    ).where((item) => item.senderId != userId && !item.isRead)) {
      message.isRead = true;
      await message.save();
    }
  }
}
