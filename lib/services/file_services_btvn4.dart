
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/todo_btvn4.dart';

class FileService {
  Future<File> get _file async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/todos.json');
  }

  Future<List<Todo>> loadTodos() async {
    final file = await _file;

    if (!await file.exists()) {
      return [];
    }

    final content = await file.readAsString();
    if (content.isEmpty) return [];

    final List<dynamic> data = jsonDecode(content);

    return data.map((item) => Todo.fromJson(item)).toList();
  }

  Future<void> saveTodos(List<Todo> todos) async {
    final file = await _file;

    final content = jsonEncode(
      todos.map((todo) => todo.toJson()).toList(),
    );

    await file.writeAsString(content);
  }
}
