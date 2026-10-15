class Todo {
  final String title;
  final DateTime time;
  bool completed;

  Todo({
    required this.title,
    required this.time,
    this.completed = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'time': time.toIso8601String(),
      'completed': completed,
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      title: json['title'],
      time: DateTime.parse(json['time']),
      completed: json['completed'] ?? false,
    );
  }
}
