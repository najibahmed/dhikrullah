// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_dhikir_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomDhikirItemAdapter extends TypeAdapter<CustomDhikirItem> {
  @override
  final int typeId = 1;

  @override
  CustomDhikirItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomDhikirItem(
      id: fields[0] as String,
      title: fields[1] as String,
      arabicText: fields[2] as String,
      transliteration: fields[3] as String,
      englishMeaning: fields[4] as String,
      colorHex: fields[5] as String,
      icon: fields[6] as String,
      isFavorite: fields[7] as bool,
      createdAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CustomDhikirItem obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.arabicText)
      ..writeByte(3)
      ..write(obj.transliteration)
      ..writeByte(4)
      ..write(obj.englishMeaning)
      ..writeByte(5)
      ..write(obj.colorHex)
      ..writeByte(6)
      ..write(obj.icon)
      ..writeByte(7)
      ..write(obj.isFavorite)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomDhikirItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
