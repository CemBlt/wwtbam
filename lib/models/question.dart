class Question {
  final int id;
  final String question;
  final List<String> options;
  final int correctAnswer; // 0-3 arası index
  final bool hasAudio; // Sesli soru mu?
  final String? audioPath; // Ses dosyası yolu
  final String? imagePath; // Soru için fotoğraf

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.hasAudio = false,
    this.audioPath,
    this.imagePath,
  });

  // JSON'dan Question oluştur
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswer: json['correctAnswer'] as int,
      hasAudio: json['hasAudio'] as bool? ?? false,
      audioPath: json['audioPath'] as String?,
      imagePath: json['imagePath'] as String?,
    );
  }

  // Question'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'hasAudio': hasAudio,
      'audioPath': audioPath,
      'imagePath': imagePath,
    };
  }
}

