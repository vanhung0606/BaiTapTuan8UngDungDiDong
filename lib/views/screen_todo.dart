import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/todo.dart';
import '../services/file_services.dart';

class ScreenTodo extends StatefulWidget {
  @override
  State<ScreenTodo> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<ScreenTodo> {
  final TextEditingController controller = TextEditingController();
  final FileService fileService = FileService();

  List<Todo> todos = [];
  DateTime? selectedTime;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    todos = await fileService.loadTodos();
    setState(() {});
  }

  void addTodo() async {
    if (controller.text.isEmpty || selectedTime == null) return;

    final todo = Todo(title: controller.text, time: selectedTime!);

    todos.add(todo);
    await fileService.saveTodos(todos);

    controller.clear();
    selectedTime = null;

    setState(() {});
  }

  // CHỌN NGÀY + GIỜ
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
                      leading: Icon(Icons.task, color: getTextColor(bgColor)),
                      title: Text(
                        t.title,
                        style: TextStyle(
                          color: getTextColor(bgColor),

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        formatTime(t.time),
                        style: TextStyle(
                          color: getTextColor(bgColor).withValues(alpha: 0.7),
                        ),
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
