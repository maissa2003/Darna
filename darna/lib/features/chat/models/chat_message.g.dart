// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

class ChatMessageAdapter extends TypeAdapter<ChatMessage> {
  @override
  final typeId = 2;

  @override
  ChatMessage read(BinaryReader reader) {
    final count = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < count; i++) reader.readByte(): reader.read(),
    };
    return ChatMessage(
      id: fields[0] as String,
      conversationId: fields[1] as String,
      propertyId: fields[2] as String,
      studentId: fields[3] as String,
      ownerId: fields[4] as String,
      senderId: fields[5] as String,
      text: fields[6] as String,
      sentAt: fields[7] as DateTime,
      isRead: fields[8] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, ChatMessage obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.conversationId)
      ..writeByte(2)
      ..write(obj.propertyId)
      ..writeByte(3)
      ..write(obj.studentId)
      ..writeByte(4)
      ..write(obj.ownerId)
      ..writeByte(5)
      ..write(obj.senderId)
      ..writeByte(6)
      ..write(obj.text)
      ..writeByte(7)
      ..write(obj.sentAt)
      ..writeByte(8)
      ..write(obj.isRead);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageAdapter && other.typeId == typeId;
}
