// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ImageItemAdapter extends TypeAdapter<ImageItem> {
  @override
  final int typeId = 3;

  @override
  ImageItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ImageItem(
      id: fields[0] as String?,
      imagePath: fields[1] as String,
      x: fields[2] as double,
      y: fields[3] as double,
      width: fields[4] as double,
      height: fields[5] as double,
      rotation: fields[6] as double,
      scale: fields[7] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ImageItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.x)
      ..writeByte(3)
      ..write(obj.y)
      ..writeByte(4)
      ..write(obj.width)
      ..writeByte(5)
      ..write(obj.height)
      ..writeByte(6)
      ..write(obj.rotation)
      ..writeByte(7)
      ..write(obj.scale);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
