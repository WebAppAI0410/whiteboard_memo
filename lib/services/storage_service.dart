import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/board.dart';
import '../models/sticky_note.dart';
import '../models/drawing.dart';
import '../models/image_item.dart';

class StorageService {
  static const String boardsBoxName = 'boards';
  static const String settingsBoxName = 'settings';
  static const String premiumBoxName = 'premium';

  // Flag to track if we're using in-memory storage
  static bool _usingInMemoryStorage = false;
  
  // In-memory storage fallbacks
  static final List<Board> _inMemoryBoards = [];
  static final Map<String, dynamic> _inMemorySettings = {};
  static final Map<String, dynamic> _inMemoryPremium = {'isPremium': false};
  
  static Future<void> init() async {
    print('Initializing storage service...');
    
    // Initialize Hive for Flutter
    try {
      await Hive.initFlutter();
      print('Hive initialized successfully');
    } catch (e) {
      print('Error initializing Hive: $e');
      _usingInMemoryStorage = true;
      print('Falling back to in-memory storage');
      return; // Skip the rest of initialization if we're using in-memory storage
    }
    
    try {
      print('Registering Hive adapters...');
      // Register custom adapters first
      if (!Hive.isAdapterRegistered(10)) {
        Hive.registerAdapter(ColorAdapter());
      }
      
      if (!Hive.isAdapterRegistered(12)) {
        Hive.registerAdapter(OffsetAdapter());
      }
      
      if (!Hive.isAdapterRegistered(11)) {
        Hive.registerAdapter(StickyNoteShapeAdapter());
      }
      
      if (!Hive.isAdapterRegistered(13)) {
        Hive.registerAdapter(DrawingTypeAdapter());
      }
      
      // Then register model adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(BoardAdapter());
      }
      
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(StickyNoteAdapter());
      }
      
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(DrawingAdapter());
      }
      
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(ImageItemAdapter());
      }
      print('Hive adapters registered successfully');
    } catch (e) {
      print('Error registering Hive adapters: $e');
      _usingInMemoryStorage = true;
      print('Falling back to in-memory storage');
      return; // Skip the rest of initialization if we're using in-memory storage
    }

    // Open boxes with error handling
    try {
      print('Opening Hive boxes...');
      await Hive.openBox<Board>(boardsBoxName);
      print('Opened boards box successfully');
      await Hive.openBox(settingsBoxName);
      print('Opened settings box successfully');
      await Hive.openBox(premiumBoxName);
      print('Opened premium box successfully');
    } catch (e) {
      print('Error opening Hive boxes: $e');
      _usingInMemoryStorage = true;
      print('Falling back to in-memory storage');
    }
  }

  // Board operations
  static Box<Board>? _boardsBox;
  
  static Box<Board>? getBoardsBox() {
    if (_usingInMemoryStorage) {
      return null;
    }
    
    _boardsBox ??= Hive.box<Board>(boardsBoxName);
    return _boardsBox;
  }

  static List<Board> getAllBoards() {
    if (_usingInMemoryStorage) {
      print('Using in-memory boards: ${_inMemoryBoards.length} boards');
      return List.from(_inMemoryBoards);
    }
    
    final box = getBoardsBox();
    if (box == null) {
      print('Box is null, using in-memory boards');
      return List.from(_inMemoryBoards);
    }
    
    try {
      return box.values.toList();
    } catch (e) {
      print('Error getting all boards: $e');
      return List.from(_inMemoryBoards);
    }
  }

  static Future<void> saveBoard(Board board) async {
    if (_usingInMemoryStorage) {
      print('Saving board to in-memory storage: ${board.id}');
      final index = _inMemoryBoards.indexWhere((b) => b.id == board.id);
      if (index >= 0) {
        _inMemoryBoards[index] = board;
      } else {
        _inMemoryBoards.add(board);
      }
      return;
    }
    
    final box = getBoardsBox();
    if (box == null) {
      print('Box is null, saving board to in-memory storage: ${board.id}');
      final index = _inMemoryBoards.indexWhere((b) => b.id == board.id);
      if (index >= 0) {
        _inMemoryBoards[index] = board;
      } else {
        _inMemoryBoards.add(board);
      }
      return;
    }
    
    try {
      await box.put(board.id, board);
    } catch (e) {
      print('Error saving board: $e');
      // Fallback to in-memory storage
      final index = _inMemoryBoards.indexWhere((b) => b.id == board.id);
      if (index >= 0) {
        _inMemoryBoards[index] = board;
      } else {
        _inMemoryBoards.add(board);
      }
    }
  }

  static Future<void> deleteBoard(String boardId) async {
    if (_usingInMemoryStorage) {
      print('Deleting board from in-memory storage: $boardId');
      _inMemoryBoards.removeWhere((b) => b.id == boardId);
      return;
    }
    
    final box = getBoardsBox();
    if (box == null) {
      print('Box is null, deleting board from in-memory storage: $boardId');
      _inMemoryBoards.removeWhere((b) => b.id == boardId);
      return;
    }
    
    try {
      await box.delete(boardId);
    } catch (e) {
      print('Error deleting board: $e');
      // Fallback to in-memory storage
      _inMemoryBoards.removeWhere((b) => b.id == boardId);
    }
  }

  static Board? getBoard(String boardId) {
    if (_usingInMemoryStorage) {
      print('Getting board from in-memory storage: $boardId');
      return _inMemoryBoards.firstWhere((b) => b.id == boardId, orElse: () => null as Board);
    }
    
    final box = getBoardsBox();
    if (box == null) {
      print('Box is null, getting board from in-memory storage: $boardId');
      return _inMemoryBoards.firstWhere((b) => b.id == boardId, orElse: () => null as Board);
    }
    
    try {
      return box.get(boardId);
    } catch (e) {
      print('Error getting board: $e');
      return _inMemoryBoards.firstWhere((b) => b.id == boardId, orElse: () => null as Board);
    }
  }

  // Settings operations
  static Box? _settingsBox;
  
  static Box? getSettingsBox() {
    if (_usingInMemoryStorage) {
      return null;
    }
    
    _settingsBox ??= Hive.box(settingsBoxName);
    return _settingsBox;
  }

  static Future<void> saveSetting(String key, dynamic value) async {
    if (_usingInMemoryStorage) {
      print('Saving setting to in-memory storage: $key');
      _inMemorySettings[key] = value;
      return;
    }
    
    final box = getSettingsBox();
    if (box == null) {
      print('Box is null, saving setting to in-memory storage: $key');
      _inMemorySettings[key] = value;
      return;
    }
    
    try {
      await box.put(key, value);
    } catch (e) {
      print('Error saving setting: $e');
      _inMemorySettings[key] = value;
    }
  }

  static dynamic getSetting(String key, {dynamic defaultValue}) {
    if (_usingInMemoryStorage) {
      print('Getting setting from in-memory storage: $key');
      return _inMemorySettings[key] ?? defaultValue;
    }
    
    final box = getSettingsBox();
    if (box == null) {
      print('Box is null, getting setting from in-memory storage: $key');
      return _inMemorySettings[key] ?? defaultValue;
    }
    
    try {
      return box.get(key, defaultValue: defaultValue);
    } catch (e) {
      print('Error getting setting: $e');
      return _inMemorySettings[key] ?? defaultValue;
    }
  }

  // Premium features
  static Box? _premiumBox;
  
  static Box? getPremiumBox() {
    if (_usingInMemoryStorage) {
      return null;
    }
    
    _premiumBox ??= Hive.box(premiumBoxName);
    return _premiumBox;
  }

  static bool isPremiumUser() {
    if (_usingInMemoryStorage) {
      print('Getting premium status from in-memory storage');
      return _inMemoryPremium['isPremium'] ?? false;
    }
    
    final box = getPremiumBox();
    if (box == null) {
      print('Box is null, getting premium status from in-memory storage');
      return _inMemoryPremium['isPremium'] ?? false;
    }
    
    try {
      return box.get('isPremium', defaultValue: false);
    } catch (e) {
      print('Error getting premium status: $e');
      return _inMemoryPremium['isPremium'] ?? false;
    }
  }

  static Future<void> setPremiumStatus(bool isPremium) async {
    if (_usingInMemoryStorage) {
      print('Setting premium status in in-memory storage: $isPremium');
      _inMemoryPremium['isPremium'] = isPremium;
      return;
    }
    
    final box = getPremiumBox();
    if (box == null) {
      print('Box is null, setting premium status in in-memory storage: $isPremium');
      _inMemoryPremium['isPremium'] = isPremium;
      return;
    }
    
    try {
      await box.put('isPremium', isPremium);
    } catch (e) {
      print('Error setting premium status: $e');
      _inMemoryPremium['isPremium'] = isPremium;
    }
  }

  static DateTime? getPremiumExpiryDate() {
    if (_usingInMemoryStorage) {
      print('Getting premium expiry date from in-memory storage');
      final timestamp = _inMemoryPremium['expiryDate'];
      return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
    }
    
    final box = getPremiumBox();
    if (box == null) {
      print('Box is null, getting premium expiry date from in-memory storage');
      final timestamp = _inMemoryPremium['expiryDate'];
      return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
    }
    
    try {
      final timestamp = box.get('expiryDate');
      return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
    } catch (e) {
      print('Error getting premium expiry date: $e');
      final timestamp = _inMemoryPremium['expiryDate'];
      return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
    }
  }

  static Future<void> setPremiumExpiryDate(DateTime expiryDate) async {
    if (_usingInMemoryStorage) {
      print('Setting premium expiry date in in-memory storage');
      _inMemoryPremium['expiryDate'] = expiryDate.millisecondsSinceEpoch;
      return;
    }
    
    final box = getPremiumBox();
    if (box == null) {
      print('Box is null, setting premium expiry date in in-memory storage');
      _inMemoryPremium['expiryDate'] = expiryDate.millisecondsSinceEpoch;
      return;
    }
    
    try {
      await box.put('expiryDate', expiryDate.millisecondsSinceEpoch);
    } catch (e) {
      print('Error setting premium expiry date: $e');
      _inMemoryPremium['expiryDate'] = expiryDate.millisecondsSinceEpoch;
    }
  }
}
