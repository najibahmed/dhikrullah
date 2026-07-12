// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dhikir_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DhikirProgressAdapter extends TypeAdapter<DhikirProgress> {
  @override
  final int typeId = 0;

  @override
  DhikirProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DhikirProgress(
      dhikirId: fields[0] as String,
      completedDates: (fields[1] as List).cast<String>(),
      dailyCounts: (fields[2] as Map).cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, DhikirProgress obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.dhikirId)
      ..writeByte(1)
      ..write(obj.completedDates)
      ..writeByte(2)
      ..write(obj.dailyCounts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DhikirProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
