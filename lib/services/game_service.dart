import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question.dart';
import '../models/game_state.dart';

class GameService {
  static final GameService _instance = GameService._internal();
  factory GameService() => _instance;
  GameService._internal();

  // Soruları yükle (JSON dosyasından veya varsayılan olarak)
  Future<List<Question>> loadQuestions() async {
    try {
      // Önce assets'ten yüklemeyi dene
      final String jsonString = await rootBundle.loadString('assets/questions.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      return jsonData.map((json) => Question.fromJson(json)).toList();
    } catch (e) {
      // Eğer dosya yoksa, örnek sorular döndür
      print('Sorular yüklenemedi, örnek sorular kullanılıyor: $e');
      return _getDefaultQuestions();
    }
  }

  // Varsayılan örnek sorular (kullanıcı kendi sorularını ekleyecek)
  List<Question> _getDefaultQuestions() {
    return [
      Question(
        id: 1,
        question: 'Örnek Soru 1: Flutter hangi programlama dili ile yazılmıştır?',
        options: ['Dart', 'Java', 'Kotlin', 'Swift'],
        correctAnswer: 0,
      ),
      Question(
        id: 2,
        question: 'Örnek Soru 2: Türkiye\'nin başkenti neresidir?',
        options: ['İstanbul', 'Ankara', 'İzmir', 'Bursa'],
        correctAnswer: 1,
      ),
      Question(
        id: 3,
        question: 'Örnek Soru 3: Hangi gezegen güneş sisteminin en büyük gezegenidir?',
        options: ['Satürn', 'Jüpiter', 'Neptün', 'Uranüs'],
        correctAnswer: 1,
      ),
      Question(
        id: 4,
        question: 'Örnek Soru 4: İnsan vücudunda kaç kemik vardır?',
        options: ['186', '206', '226', '246'],
        correctAnswer: 1,
      ),
      Question(
        id: 5,
        question: 'Örnek Soru 5: Hangi element periyodik tabloda "Au" sembolü ile gösterilir?',
        options: ['Gümüş', 'Altın', 'Alüminyum', 'Argon'],
        correctAnswer: 1,
      ),
      Question(
        id: 6,
        question: 'Örnek Soru 6: Dünya\'nın en uzun nehri hangisidir?',
        options: ['Amazon', 'Nil', 'Mississippi', 'Yangtze'],
        correctAnswer: 1,
      ),
      Question(
        id: 7,
        question: 'Örnek Soru 7: Hangi yıl İstanbul fethedilmiştir?',
        options: ['1451', '1453', '1455', '1457'],
        correctAnswer: 1,
      ),
      Question(
        id: 8,
        question: 'Örnek Soru 8: Hangi hayvan dünyanın en hızlı kara hayvanıdır?',
        options: ['Aslan', 'Çita', 'Leopar', 'Kaplan'],
        correctAnswer: 1,
      ),
      Question(
        id: 9,
        question: 'Örnek Soru 9: Hangi gezegen "Kırmızı Gezegen" olarak bilinir?',
        options: ['Venüs', 'Mars', 'Jüpiter', 'Satürn'],
        correctAnswer: 1,
      ),
      Question(
        id: 10,
        question: 'Örnek Soru 10: Hangi ülke Eiffel Kulesi\'ne ev sahipliği yapar?',
        options: ['İngiltere', 'Fransa', 'Almanya', 'İtalya'],
        correctAnswer: 1,
      ),
    ];
  }

  // Yeni oyun başlat
  Future<GameState> startNewGame() async {
    final questions = await loadQuestions();
    return GameState(questions: questions);
  }
}

