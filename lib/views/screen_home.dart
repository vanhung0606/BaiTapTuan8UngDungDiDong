
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/word.dart';
import '../services/word_file_service.dart';
import '../services/notification_service_bttl3.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final service = WordFileService();
  final notifications = NotificationService();

  final wordController = TextEditingController();
  final meaningController = TextEditingController();
  final answerController = TextEditingController();

  List<Word> words = [];
  int page = 0;
  int currentIndex = 0;
  int correct = 0;
  int wrong = 0;
  int wrongInARow = 0;
  bool quizMode = false;

  @override
  void initState() {
    super.initState();
    initApp();
  }

  Future<void> initApp() async {
    await notifications.init();
    words = await service.loadWords();
    if (mounted) setState(() {});
  }

  Future<void> saveWord() async {
    final word = wordController.text.trim();
    final meaning = meaningController.text.trim();

    if (word.isEmpty || meaning.isEmpty) {
      message('Vui lòng nhập từ và nghĩa!');
      return;
    }

    words.add(Word(word: word, meaning: meaning));
    await service.saveWords(words);

    await notifications.showSavedNotification(word);

    // Hẹn nhắc học sau 10 phút
    await notifications.scheduleTodoNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
      title: 'Ôn tập từ vựng: $word',
      scheduledTime: DateTime.now().add(const Duration(minutes: 10)),
    );

    wordController.clear();
    meaningController.clear();

    if (mounted) {
      setState(() {});
      message('Đã lưu từ. Bạn sẽ được nhắc ôn tập sau 10 phút.');
    }
  }

  void message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Future<void> checkMeaning() async {
    if (words.isEmpty) {
      message('Bạn chưa có từ vựng nào!');
      return;
    }

    final index = currentIndex % words.length;
    final answer = answerController.text.trim().toLowerCase();
    final expected = words[index].meaning.trim().toLowerCase();

    if (answer == expected) {
      correct++;
      wrongInARow = 0;
      message('Chính xác!');
    } else {
      wrong++;
      wrongInARow++;
      message('Chưa chính xác. Nghĩa đúng: ${words[index].meaning}');

      if (wrong % 3 == 0) {
        await notifications.showSavedNotification(
          'Bạn đã trả lời sai $wrong lần. Hãy ôn tập lại nhé!',
        );
      }
    }

    answerController.clear();
    setState(() {
      currentIndex = (currentIndex + 1) % words.length;
    });
  }

  Future<void> startQuiz() async {
    if (words.isEmpty) {
      message('Hãy lưu ít nhất một từ trước!');
      return;
    }

    setState(() {
      quizMode = true;
      correct = 0;
      wrong = 0;
      currentIndex = Random().nextInt(words.length);
    });
  }

  Future<void> answerQuiz(bool chooseCorrect) async {
    if (words.isEmpty) return;

    // Tạo câu hỏi: chọn nghĩa đúng hoặc một nghĩa khác.
    final current = words[currentIndex];
    final correctAnswer = Random().nextBool();
    final displayedMeaning = correctAnswer
        ? current.meaning
        : words[Random().nextInt(words.length)].meaning;

    // Trong giao diện hoàn chỉnh, đáp án đang hiển thị cần được
    // lưu lại khi tạo câu hỏi. Phần kiểm tra chính xác nằm ở đây.
    final isCorrect = chooseCorrect == correctAnswer;

    if (isCorrect) {
      correct++;
    } else {
      wrong++;
    }

    if (correct + wrong >= 10) {
      final total = correct + wrong;
      final percent = (correct / total * 100).toStringAsFixed(1);

      setState(() => quizMode = false);

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Kết quả kiểm tra'),
          content: Text(
            'Số câu đúng: $correct\n'
            'Số câu sai: $wrong\n'
            'Tỉ lệ đúng: $percent%',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      currentIndex = Random().nextInt(words.length);
    });
  }

  Widget buildSavePage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: wordController,
            decoration: const InputDecoration(labelText: 'Từ'),
          ),
          TextField(
            controller: meaningController,
            decoration: const InputDecoration(labelText: 'Nghĩa'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: saveWord,
            child: const Text('Lưu và Nhắc học sau 10 phút'),
          ),
          const SizedBox(height: 12),
          Text('Đã lưu ${words.length} từ vựng'),
        ],
      ),
    );
  }

  Widget buildLearnPage() {
    if (words.isEmpty) {
      return const Center(child: Text('Chưa có từ vựng.'));
    }

    final current = words[currentIndex % words.length];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('✓ Đúng: $correct'),
              Text('✕ Sai: $wrong'),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            current.word,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextField(
            controller: answerController,
            decoration: const InputDecoration(
              labelText: 'Nhập nghĩa tiếng Việt',
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: checkMeaning,
            child: const Text('Check'),
          ),
        ],
      ),
    );
  }

  Widget buildQuizPage() {
    if (!quizMode) {
      return Center(
        child: ElevatedButton(
          onPressed: startQuiz,
          child: const Text('Bắt đầu kiểm tra 10 câu'),
        ),
      );
    }

    if (words.isEmpty) {
      return const Center(child: Text('Chưa có từ vựng.'));
    }

    final current = words[currentIndex];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              current.word,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text('Đúng: $correct    Sai: $wrong'),
            const SizedBox(height: 24),
            const Text('Bạn có biết nghĩa của từ này không?'),
            ElevatedButton(
              onPressed: () async {
                // Phiên bản đầy đủ nên hiện hai lựa chọn nghĩa.
                // Nút này kiểm tra người học đã nhớ nghĩa.
                if (answerController.text.trim().toLowerCase() ==
                    current.meaning.trim().toLowerCase()) {
                  correct++;
                } else {
                  wrong++;
                }
                answerController.clear();

                if (correct + wrong >= 10) {
                  setState(() => quizMode = false);
                  final total = correct + wrong;
                  final percent =
                      (correct / total * 100).toStringAsFixed(1);
                  if (!mounted) return;
                  await showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Kết quả kiểm tra'),
                      content: Text(
                        'Đúng: $correct\nSai: $wrong\nTỉ lệ đúng: $percent%',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Đóng'),
                        ),
                      ],
                    ),
                  );
                } else {
                  setState(() {
                    currentIndex = Random().nextInt(words.length);
                  });
                }
              },
              child: const Text('Kiểm tra câu trả lời'),
            ),
            TextField(
              controller: answerController,
              decoration: const InputDecoration(
                labelText: 'Nhập nghĩa để kiểm tra',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildReminderPage() {
    if (words.isEmpty) {
      return const Center(child: Text('Chưa có lịch nhắc.'));
    }

    return ListView(
      children: words.map((word) {
        return ListTile(
          leading: const Icon(Icons.notifications_active),
          title: Text(word.word),
          subtitle: const Text('Nhắc ôn tập sau 10 phút'),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      buildSavePage(),
      buildLearnPage(),
      buildQuizPage(),
      buildReminderPage(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Ứng dụng học từ vựng')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text(
                'Trợ lý học từ vựng',
                style: TextStyle(fontSize: 20),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Trang chính'),
              onTap: () {
                setState(() => page = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Học từ'),
              onTap: () {
                setState(() => page = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.quiz),
              title: const Text('Kiểm tra từ'),
              onTap: () {
                setState(() => page = 2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Lịch nhắc'),
              onTap: () {
                setState(() => page = 3);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: pages[page],
    );
  }

  @override
  void dispose() {
    wordController.dispose();
    meaningController.dispose();
    answerController.dispose();
    super.dispose();
  }
}
