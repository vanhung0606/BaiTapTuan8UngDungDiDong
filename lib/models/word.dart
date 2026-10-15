class Word {
  final String word;
  final String meaning;
  bool reminderShown;

  Word({
    required this.word,
    required this.meaning,
    this.reminderShown = false,
  });

  Map<String, dynamic> toJson() => {
        'word': word,
        'meaning': meaning,
        'reminderShown': reminderShown,
      };

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      word: json['word'],
      meaning: json['meaning'],
      reminderShown: json['reminderShown'] ?? false,
    );
  }
}