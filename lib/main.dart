import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/storage_service.dart';
import 'screens/board_list_screen.dart';
import 'constants/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('Starting WhiteboardMemo app initialization');
  
  try {
    // Initialize Hive and storage service
    await StorageService.init();
    print('Storage service initialized successfully');
  } catch (e) {
    print('Error initializing storage service: $e');
  }
  
  runApp(
    const ProviderScope(
      child: WhiteboardMemoApp(),
    ),
  );
}

class WhiteboardMemoApp extends ConsumerWidget {
  const WhiteboardMemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'WhiteboardMemo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Automatically use dark mode based on system settings
      home: const BoardListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
