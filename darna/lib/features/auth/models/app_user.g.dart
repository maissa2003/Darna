// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppUserAdapter extends TypeAdapter<AppUser> {
  @override
  final typeId = 0;

  @override
  AppUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppUser(
      id: fields[0] as String,
      fullName: fields[1] as String,
      email: fields[2] as String,
      phone: fields[3] as String,
      passwordHash: fields[4] as String,
      role: fields[5] as String,
      gender: fields[6] as String,
      universityId: fields[7] as String?,
      avatarPath: fields[8] as String?,
      createdAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AppUser obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.passwordHash)
      ..writeByte(5)
      ..write(obj.role)
      ..writeByte(6)
      ..write(obj.gender)
      ..writeByte(7)
      ..write(obj.universityId)
      ..writeByte(8)
      ..write(obj.avatarPath)
      ..writeByte(9)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
