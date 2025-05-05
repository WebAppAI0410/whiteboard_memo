// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sticky_note.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StickyNoteAdapter extends TypeAdapter<StickyNote> {
  @override
  final int typeId = 1;

  @override
  StickyNote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StickyNote(
      id: fields[0] as String?,
      text: fields[1] as String,
      color: fields[2] as Color,
      x: fields[3] as double,
      y: fields[4] as double,
      width: fields[5] as double,
      height: fields[6] as double,
      rotation: fields[7] as double,
      scale: fields[8] as double,
      shape: fields[9] as StickyNoteShape,
    );
  }

  @override
  void write(BinaryWriter writer, StickyNote obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.color)
      ..writeByte(3)
      ..write(obj.x)
      ..writeByte(4)
      ..write(obj.y)
      ..writeByte(5)
      ..write(obj.width)
      ..writeByte(6)
      ..write(obj.height)
      ..writeByte(7)
      ..write(obj.rotation)
      ..writeByte(8)
      ..write(obj.scale)
      ..writeByte(9)
      ..write(obj.shape);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StickyNoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
