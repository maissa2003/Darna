// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roommate_offer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoommateOfferAdapter extends TypeAdapter<RoommateOffer> {
  @override
  final typeId = 3;

  @override
  RoommateOffer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoommateOffer(
      id: fields[0] as String,
      userId: fields[1] as String,
      type: fields[2] as String,
      city: fields[3] as String,
      area: fields[4] as String,
      rentShare: (fields[5] as num).toDouble(),
      placesAvailable: (fields[6] as num).toInt(),
      roomType: fields[7] as String,
      availableFrom: fields[8] as DateTime,
      smokingAllowed: fields[9] as bool,
      petsAllowed: fields[10] as bool,
      description: fields[11] as String,
      status: fields[12] as String,
      createdAt: fields[13] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, RoommateOffer obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.city)
      ..writeByte(4)
      ..write(obj.area)
      ..writeByte(5)
      ..write(obj.rentShare)
      ..writeByte(6)
      ..write(obj.placesAvailable)
      ..writeByte(7)
      ..write(obj.roomType)
      ..writeByte(8)
      ..write(obj.availableFrom)
      ..writeByte(9)
      ..write(obj.smokingAllowed)
      ..writeByte(10)
      ..write(obj.petsAllowed)
      ..writeByte(11)
      ..write(obj.description)
      ..writeByte(12)
      ..write(obj.status)
      ..writeByte(13)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoommateOfferAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
