class Todo {
  String title;
  DateTime time;
  Todo({required this.title, required this.time});

  String toFileString() {
    return "$title|${time.toIso8601String()}";
  }

  static Todo fromString(String line) {
    final parts = line.split("|");
    return Todo(title: parts[0], time: DateTime.parse(parts[1]));
  }
}
