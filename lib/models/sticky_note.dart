import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'sticky_note.g.dart';

enum StickyNoteShape {
  rectangle,
  square,
}

@HiveType(typeId: 1)
class StickyNote extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String text;

  @HiveField(2)
  Color color;

  @HiveField(3)
  double x;

  @HiveField(4)
  double y;

  @HiveField(5)
  double width;

  @HiveField(6)
  double height;

  @HiveField(7)
  double rotation;

  @HiveField(8)
  double scale;

  @HiveField(9)
  StickyNoteShape shape;

  StickyNote({
    String? id,
    this.text = '',
    this.color = Colors.yellow,
    this.x = 0.0,
    this.y = 0.0,
    this.width = 150.0,
    this.height = 150.0,
    this.rotation = 0.0,
    this.scale = 1.0,
    this.shape = StickyNoteShape.rectangle,
  }) : id = id ?? const Uuid().v4();

  StickyNote copyWith({
    String? id,
    String? text,
    Color? color,
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
    double? scale,
    StickyNoteShape? shape,
  }) {
    return StickyNote(
      id: id ?? this.id,
      text: text ?? this.text,
      color: color ?? this.color,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
      shape: shape ?? this.shape,
    );
  }
}

// Custom adapter for Color since it's not natively supported by Hive
class ColorAdapter extends TypeAdapter<Color> {
  @override
  final int typeId = 10;

  @override
  Color read(BinaryReader reader) {
    final colorValue = reader.readInt();
    return Color(colorValue);
  }

  @override
  void write(BinaryWriter writer, Color obj) {
    writer.writeInt(obj.value);
  }
}

// Custom adapter for StickyNoteShape enum
class StickyNoteShapeAdapter extends TypeAdapter<StickyNoteShape> {
  @override
  final int typeId = 11;

  @override
  StickyNoteShape read(BinaryReader reader) {
    final index = reader.readInt();
    return StickyNoteShape.values[index];
  }

  @override
  void write(BinaryWriter writer, StickyNoteShape obj) {
    writer.writeInt(obj.index);
  }
}
