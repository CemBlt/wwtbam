import 'question.dart';
import 'joker.dart';

class GameState {
  final List<Question> questions;
  int currentQuestionIndex;
  int score;
  final List<Joker> jokers;
  bool isGameOver;
  bool hasWon;
  final List<int> prizeQuestions; // Ödül soruları (2, 5, 10)
  int currentPrizeNumber; // Şu anki ödül numarası (1, 2, 3)

  GameState({
    required this.questions,
    this.currentQuestionIndex = 0,
    this.score = 0,
    List<Joker>? jokers,
    this.isGameOver = false,
    this.hasWon = false,
    List<int>? prizeQuestions,
    this.currentPrizeNumber = 0,
  })  : jokers = jokers ?? Joker.createAllJokers(),
        prizeQuestions = prizeQuestions ?? [2, 5, 10];

  Question? get currentQuestion {
    if (currentQuestionIndex < questions.length) {
      return questions[currentQuestionIndex];
    }
    return null;
  }

  bool get isPrizeQuestion {
    final questionNumber = currentQuestionIndex + 1;
    return prizeQuestions.contains(questionNumber);
  }

  int get prizeNumber {
    if (isPrizeQuestion) {
      return prizeQuestions.indexOf(currentQuestionIndex + 1) + 1;
    }
    return 0;
  }

  bool get canUseJoker {
    return jokers.any((joker) => !joker.isUsed);
  }

  void useJoker(JokerType type) {
    final joker = jokers.firstWhere((j) => j.type == type);
    joker.isUsed = true;
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      currentQuestionIndex++;
    } else {
      isGameOver = true;
      hasWon = true;
    }
  }

  void gameOver() {
    isGameOver = true;
    hasWon = false;
  }

  GameState copyWith({
    List<Question>? questions,
    int? currentQuestionIndex,
    int? score,
    List<Joker>? jokers,
    bool? isGameOver,
    bool? hasWon,
    List<int>? prizeQuestions,
    int? currentPrizeNumber,
  }) {
    return GameState(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      score: score ?? this.score,
      jokers: jokers ?? this.jokers,
      isGameOver: isGameOver ?? this.isGameOver,
      hasWon: hasWon ?? this.hasWon,
      prizeQuestions: prizeQuestions ?? this.prizeQuestions,
      currentPrizeNumber: currentPrizeNumber ?? this.currentPrizeNumber,
    );
  }
}

