// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drawing.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DrawingAdapter extends TypeAdapter<Drawing> {
  @override
  final int typeId = 2;

  @override
  Drawing read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Drawing(
      id: fields[0] as String?,
      points: (fields[1] as List?)?.cast<Offset>(),
      color: fields[2] as Color,
      strokeWidth: fields[3] as double,
      type: fields[4] as DrawingType,
      startPoint: fields[5] as Offset?,
      endPoint: fields[6] as Offset?,
    );
  }

  @override
  void write(BinaryWriter writer, Drawing obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.points)
      ..writeByte(2)
      ..write(obj.color)
      ..writeByte(3)
      ..write(obj.strokeWidth)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.startPoint)
      ..writeByte(6)
      ..write(obj.endPoint);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
