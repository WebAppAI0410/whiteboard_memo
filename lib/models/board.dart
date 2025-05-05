import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'sticky_note.dart';
import 'drawing.dart';
import 'image_item.dart';

part 'board.g.dart';

@HiveType(typeId: 0)
class Board extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  DateTime updatedAt;

  @HiveField(4)
  List<StickyNote> stickyNotes;

  @HiveField(5)
  List<Drawing> drawings;

  @HiveField(6)
  List<ImageItem> images;

  Board({
    String? id,
    required this.name,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<StickyNote>? stickyNotes,
    List<Drawing>? drawings,
    List<ImageItem>? images,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        stickyNotes = stickyNotes ?? [],
        drawings = drawings ?? [],
        images = images ?? [];

  // Clone board with new ID (for board copy functionality)
  Board copyBoard({required String newName}) {
    return Board(
      name: newName,
      stickyNotes: stickyNotes.map((note) => note.copyWith()).toList(),
      drawings: drawings.map((drawing) => drawing.copyWith()).toList(),
      images: images.map((image) => image.copyWith()).toList(),
    );
  }

  void addStickyNote(StickyNote note) {
    stickyNotes.add(note);
    updatedAt = DateTime.now();
    save();
  }

  void updateStickyNote(StickyNote updatedNote) {
    final index = stickyNotes.indexWhere((note) => note.id == updatedNote.id);
    if (index != -1) {
      stickyNotes[index] = updatedNote;
      updatedAt = DateTime.now();
      save();
    }
  }

  void removeStickyNote(String noteId) {
    stickyNotes.removeWhere((note) => note.id == noteId);
    updatedAt = DateTime.now();
    save();
  }

  void addDrawing(Drawing drawing) {
    drawings.add(drawing);
    updatedAt = DateTime.now();
    save();
  }

  void updateDrawing(Drawing updatedDrawing) {
    final index = drawings.indexWhere((drawing) => drawing.id == updatedDrawing.id);
    if (index != -1) {
      drawings[index] = updatedDrawing;
      updatedAt = DateTime.now();
      save();
    }
  }

  void removeDrawing(String drawingId) {
    drawings.removeWhere((drawing) => drawing.id == drawingId);
    updatedAt = DateTime.now();
    save();
  }

  void addImage(ImageItem image) {
    images.add(image);
    updatedAt = DateTime.now();
    save();
  }

  void updateImage(ImageItem updatedImage) {
    final index = images.indexWhere((image) => image.id == updatedImage.id);
    if (index != -1) {
      images[index] = updatedImage;
      updatedAt = DateTime.now();
      save();
    }
  }

  void removeImage(String imageId) {
    images.removeWhere((image) => image.id == imageId);
    updatedAt = DateTime.now();
    save();
  }
}
