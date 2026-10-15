import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/todo_btvn4.dart';
import '../services/notification_service_bttl3.dart';
import '../services/file_services_btvn4.dart';

class ScreenTodo extends StatefulWidget {
  @override
  State<ScreenTodo> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<ScreenTodo> {
  final TextEditingController controller = TextEditingController();
  final FileService fileService = FileService();
  final NotificationService notificationService = NotificationService();

  List<Todo> todos = [];
  DateTime? selectedTime;

  @override
  void initState() {
    super.initState();
    initNotification();
    loadData();
  }

  Future<void> completeTodo(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text(
          'Bạn có xác nhận nhiệm vụ này đã hoàn thành không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Có'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      todos[index].completed = true;
    });

    await fileService.saveTodos(todos);

    final completedCount = todos.where((todo) => todo.completed).length;

    await notificationService.showCompletedCount(completedCount);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã hoàn thành $completedCount nhiệm vụ!')),
    );
  }

  Future<void> initNotification() async {
    await notificationService.init();
  }

  void loadData() async {
    todos = await fileService.loadTodos();
    setState(() {});
  }

  Future<void> addTodo() async {
    if (controller.text.trim().isEmpty || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên và chọn thời gian!')),
      );
      return;
    }

    if (!selectedTime!.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thời gian nhắc phải ở tương lai!')),
      );
      return;
    }

    final title = controller.text.trim();
    final time = selectedTime!;

    final todo = Todo(title: title, time: time);

    todos.add(todo);
    await fileService.saveTodos(todos);

    final id = time.microsecondsSinceEpoch.remainder(2147483647);

    await notificationService.showSavedNotification(title);

    await notificationService.scheduleTodoNotification(
      id: id,
      title: title,
      scheduledTime: time,
    );

    if (!mounted) return;

    controller.clear();

    setState(() {
      selectedTime = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu công việc và thiết lập lịch nhắc!')),
    );
  }

  void pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        selectedTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        setState(() {});
      }
    }
  }

  String formatTime(DateTime time) {
    return DateFormat("dd/MM/yyyy HH:mm").format(time);
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [
      Colors.red.shade100,
      Colors.green.shade100,
      Colors.blue.shade100,
      Colors.yellow.shade100,
      Colors.purple.shade100,
    ];
    Color getTextColor(Color bg) {
      return bg.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
    }

    return Scaffold(
      appBar: AppBar(title: Text("Todo App"), centerTitle: true),

      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // nhập công việc
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: "Tên công việc",
                filled: true,
                fillColor: Colors.white, // nền trắng
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 1.5,
                  ), // viền xanh
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2,
                  ), // khi click vào
                  borderRadius: BorderRadius.circular(10),
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedTime == null
                        ? "Chưa chọn thời gian"
                        : formatTime(selectedTime!),
                  ),
                ),
                ElevatedButton(
                  onPressed: pickDateTime,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    side: BorderSide(color: Colors.blue, width: 1.5),

                    elevation: 0, // flat modern style
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    "Chọn thời gian",

                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),
            // lưu
            ElevatedButton(
              onPressed: addTodo,

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.blue, width: 1.5),
                elevation: 0, // flat modern style
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text("Lưu"),
            ),
            SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final t = todos[index];

                  final Color bgColor = colors[index % colors.length];

                  return Card(
                    color: bgColor,
                    child: ListTile(
                      leading: Checkbox(
                        value: t.completed,
                        onChanged: t.completed
                            ? null
                            : (_) => completeTodo(index),
                      ),
                      title: Text(
                        t.title,
                        style: TextStyle(
                          color: getTextColor(bgColor),
                          fontWeight: FontWeight.bold,
                          decoration: t.completed
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      subtitle: Text(formatTime(t.time)),
                      trailing: IconButton(
                        icon: const Icon(Icons.notifications_active_outlined),
                        tooltip: 'Chọn thời gian nhắc',
                        onPressed: pickDateTime,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
