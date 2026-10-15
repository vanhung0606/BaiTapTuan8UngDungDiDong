import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/word.dart';

class WordFileService {
  Future<File> get file async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/words.json');
  }

  Future<List<Word>> loadWords() async {
    final f = await file;

    if (!await f.exists()) {
      return [];
    }

    final content = await f.readAsString();
    if (content.isEmpty) return [];

    final List data = jsonDecode(content);
    return data.map((item) => Word.fromJson(item)).toList();
  }

  Future<void> saveWords(List<Word> words) async {
    final f = await file;
    final content = jsonEncode(
      words.map((word) => word.toJson()).toList(),
    );
    await f.writeAsString(content);
  }
}