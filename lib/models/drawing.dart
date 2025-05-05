import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'drawing.g.dart';

enum DrawingType {
  freehand,
  line,
  rectangle,
  circle,
}

@HiveType(typeId: 2)
class Drawing extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  List<Offset> points;

  @HiveField(2)
  Color color;

  @HiveField(3)
  double strokeWidth;

  @HiveField(4)
  DrawingType type;

  @HiveField(5)
  Offset? startPoint;

  @HiveField(6)
  Offset? endPoint;

  Drawing({
    String? id,
    List<Offset>? points,
    this.color = Colors.black,
    this.strokeWidth = 3.0,
    this.type = DrawingType.freehand,
    this.startPoint,
    this.endPoint,
  })  : id = id ?? const Uuid().v4(),
        points = points ?? [];

  Drawing copyWith({
    String? id,
    List<Offset>? points,
    Color? color,
    double? strokeWidth,
    DrawingType? type,
    Offset? startPoint,
    Offset? endPoint,
  }) {
    return Drawing(
      id: id ?? this.id,
      points: points ?? List<Offset>.from(this.points),
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      type: type ?? this.type,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
    );
  }
}

// Custom adapter for Offset since it's not natively supported by Hive
class OffsetAdapter extends TypeAdapter<Offset> {
  @override
  final int typeId = 12;

  @override
  Offset read(BinaryReader reader) {
    final dx = reader.readDouble();
    final dy = reader.readDouble();
    return Offset(dx, dy);
  }

  @override
  void write(BinaryWriter writer, Offset obj) {
    writer.writeDouble(obj.dx);
    writer.writeDouble(obj.dy);
  }
}

// Custom adapter for DrawingType enum
class DrawingTypeAdapter extends TypeAdapter<DrawingType> {
  @override
  final int typeId = 13;

  @override
  DrawingType read(BinaryReader reader) {
    final index = reader.readInt();
    return DrawingType.values[index];
  }

  @override
  void write(BinaryWriter writer, DrawingType obj) {
    writer.writeInt(obj.index);
  }
}
