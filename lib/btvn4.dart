import 'package:flutter/material.dart';
import 'views/screen_todo_btvn4.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VocabularyApp());
}

class VocabularyApp extends StatelessWidget {
  const VocabularyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Học từ vựng',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home:ScreenTodo(),
    );
  }
}