import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'image_item.g.dart';

@HiveType(typeId: 3)
class ImageItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String imagePath;

  @HiveField(2)
  double x;

  @HiveField(3)
  double y;

  @HiveField(4)
  double width;

  @HiveField(5)
  double height;

  @HiveField(6)
  double rotation;

  @HiveField(7)
  double scale;

  ImageItem({
    String? id,
    required this.imagePath,
    this.x = 0.0,
    this.y = 0.0,
    this.width = 200.0,
    this.height = 200.0,
    this.rotation = 0.0,
    this.scale = 1.0,
  }) : id = id ?? const Uuid().v4();

  ImageItem copyWith({
    String? id,
    String? imagePath,
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
    double? scale,
  }) {
    return ImageItem(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      scale: scale ?? this.scale,
    );
  }
}
