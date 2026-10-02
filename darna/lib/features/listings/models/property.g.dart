// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property.dart';

class PropertyAdapter extends TypeAdapter<Property> {
  @override
  final typeId = 1;

  @override
  Property read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Property(
      id: fields[0] as String,
      ownerId: fields[1] as String,
      title: fields[2] as String,
      description: fields[3] as String,
      type: fields[4] as String,
      pricePerMonth: (fields[5] as num).toDouble(),
      governorate: fields[6] as String,
      city: fields[7] as String,
      address: fields[8] as String,
      lat: (fields[9] as num).toDouble(),
      lng: (fields[10] as num).toDouble(),
      rooms: fields[11] as int,
      surface: (fields[12] as num).toDouble(),
      furnished: fields[13] as bool,
      availableFrom: fields[14] as DateTime,
      status: fields[15] as String,
      imageUrls: (fields[16] as List).cast<String>(),
      amenities: (fields[17] as List).cast<String>(),
      createdAt: fields[18] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Property obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.ownerId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.pricePerMonth)
      ..writeByte(6)
      ..write(obj.governorate)
      ..writeByte(7)
      ..write(obj.city)
      ..writeByte(8)
      ..write(obj.address)
      ..writeByte(9)
      ..write(obj.lat)
      ..writeByte(10)
      ..write(obj.lng)
      ..writeByte(11)
      ..write(obj.rooms)
      ..writeByte(12)
      ..write(obj.surface)
      ..writeByte(13)
      ..write(obj.furnished)
      ..writeByte(14)
      ..write(obj.availableFrom)
      ..writeByte(15)
      ..write(obj.status)
      ..writeByte(16)
      ..write(obj.imageUrls)
      ..writeByte(17)
      ..write(obj.amenities)
      ..writeByte(18)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PropertyAdapter && other.typeId == typeId;
}
