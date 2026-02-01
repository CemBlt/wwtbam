import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/game_state.dart';
import '../models/joker.dart';
import '../services/audio_service.dart';
import '../utils/theme.dart';
import '../widgets/confetti_animation.dart';
import 'prize_screen.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  final GameState gameState;

  const GameScreen({super.key, required this.gameState});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState _gameState;
  int? _selectedAnswer;
  bool _showResult = false;
  bool _isCorrect = false;
  bool _showConfetti = false;
  List<int> _disabledOptions = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _gameState = widget.gameState;
    _playQuestionAudio();
  }

  void _playQuestionAudio() {
    final question = _gameState.currentQuestion;
    if (question != null && question.hasAudio && question.audioPath != null) {
      AudioService().playQuestionAudio(question.audioPath);
    }
  }

  void _selectAnswer(int index) {
    if (_isProcessing || _showResult) return;

    setState(() {
      _selectedAnswer = index;
    });
    AudioService().playClick();
  }

  Future<void> _submitAnswer() async {
    if (_selectedAnswer == null || _isProcessing) return;

    _isProcessing = true;
    final question = _gameState.currentQuestion!;
    final isCorrect = _selectedAnswer == question.correctAnswer;

    setState(() {
      _showResult = true;
      _isCorrect = isCorrect;
    });

    if (isCorrect) {
      // Doğru cevap sesini çal
      await AudioService().playCorrect();
      setState(() {
        _showConfetti = true;
      });

      await Future.delayed(const Duration(seconds: 4));

      // Ödül sorusu mu kontrol et
      if (_gameState.isPrizeQuestion) {
        final prizeNumber = _gameState.prizeNumber;
        if (!mounted) return;

        // Ödül ekranına git (ödül sesi orada çalınacak)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PrizeScreen(
              prizeNumber: prizeNumber,
              onContinue: () async {
                // Ödül ekranından çıkarken sesi durdur
                AudioService().stop();
                Navigator.pop(context);
                // Kısa bir gecikme ekle
                await Future.delayed(const Duration(milliseconds: 300));
                _nextQuestion();
              },
            ),
          ),
        );
      } else {
        _nextQuestion();
      }
    } else {
      await AudioService().playWrong();
      await Future.delayed(const Duration(seconds: 14));
      _gameOver();
    }
  }

  void _nextQuestion() {
    setState(() {
      _gameState.nextQuestion();
      _selectedAnswer = null;
      _showResult = false;
      _isCorrect = false;
      _showConfetti = false;
      _disabledOptions = [];
      _isProcessing = false;
    });

    if (_gameState.isGameOver) {
      _gameWon();
    } else {
      _playQuestionAudio();
    }
  }

  void _gameOver() {
    setState(() {
      _gameState.gameOver();
    });
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ResultScreen(gameState: _gameState, hasWon: false),
      ),
    );
  }

  void _gameWon() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(gameState: _gameState, hasWon: true),
      ),
    );
  }

  void _useJoker(JokerType type) {
    if (_isProcessing || _showResult) return;

    final question = _gameState.currentQuestion!;
    AudioService().playJoker();

    setState(() {
      _gameState.useJoker(type);

      switch (type) {
        case JokerType.fiftyFifty:
          // İki yanlış şıkkı kaldır
          final wrongOptions = List.generate(
            4,
            (i) => i,
          ).where((i) => i != question.correctAnswer).toList();
          wrongOptions.shuffle();
          _disabledOptions = wrongOptions.take(2).toList();
          break;

        case JokerType.audience:
          // Seyirci jokeri - en çok oy alan şıkkı göster (rastgele, doğruya yakın)
          _showAudienceResult();
          break;

        case JokerType.phone:
          // Telefon jokeri - ipucu göster
          _showPhoneHint();
          break;

        case JokerType.doubleAnswer:
          // Çift cevap - iki şık işaretlenir
          _showDoubleAnswer();
          break;
      }
    });
  }

  void _showAudienceResult() {
    // Seyirci sonucunu göster (dialog)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seyirci Sonucu'),
        content: Text(
          'Seyirciler en çok "${_gameState.currentQuestion!.options[_gameState.currentQuestion!.correctAnswer]}" şıkkını seçti!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showPhoneHint() {
    // Telefon ipucu göster
    final question = _gameState.currentQuestion!;
    final correctAnswer = question.options[question.correctAnswer];
    
    // Farklı mesaj varyasyonları - hepsi cevabı içeriyor
    final hints = [
      'Bence doğru cevap... $correctAnswer',
      'Kesinlikle $correctAnswer olmalı!',
      'Doğru cevap $correctAnswer bence.',
      '$correctAnswer şıkkı doğru gibi görünüyor.',
    ];
    
    final hint = hints[math.Random().nextInt(hints.length)];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Telefon Jokeri'),
        content: Text(hint),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showDoubleAnswer() {
    // Çift cevap - doğru cevap + bir yanlış
    final question = _gameState.currentQuestion!;
    final wrongOptions = List.generate(
      4,
      (i) => i,
    ).where((i) => i != question.correctAnswer).toList();
    wrongOptions.shuffle();

    setState(() {
      _selectedAnswer = question.correctAnswer;
      // İkinci şık olarak yanlış bir şık göster (görsel olarak)
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tek şık işaretlendi.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _gameState.currentQuestion;
    if (question == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          // Arka plan
          Container(
            decoration: const BoxDecoration(
              gradient: LoveTheme.lightPinkGradient,
            ),
          ),

          // Konfeti
          if (_showConfetti) const ConfettiAnimation(isActive: true),

          SafeArea(
            child: Column(
              children: [
                // Üst bar - soru numarası ve jokerler
                _buildTopBar(),

                // Soru alanı
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Soru numarası
                        Text(
                          'Soru ${_gameState.currentQuestionIndex + 1}/10',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 24),

                        // Soru fotoğrafı (varsa)
                        if (question.imagePath != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                question.imagePath!,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                        // Soru metni
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Text(
                                  question.question,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
                                  textAlign: TextAlign.center,
                                ),
                                // Sesli soru için tekrar dinleme butonu
                                if (question.hasAudio &&
                                    question.audioPath != null) ...[
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: _isProcessing || _showResult
                                        ? null
                                        : () {
                                            AudioService().playClick();
                                            _playQuestionAudio();
                                          },
                                    icon: const Icon(Icons.replay),
                                    label: const Text('Şarkıyı Tekrar Dinle'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: LoveTheme.primaryPink,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Şıklar
                        ...List.generate(4, (index) {
                          final isDisabled = _disabledOptions.contains(index);
                          final isSelected = _selectedAnswer == index;
                          final isCorrect =
                              _showResult && index == question.correctAnswer;
                          final isWrong =
                              _showResult && isSelected && !_isCorrect;

                          Color? backgroundColor;
                          if (isDisabled) {
                            backgroundColor = Colors.grey.shade300;
                          } else if (isCorrect) {
                            backgroundColor = Colors.green.shade300;
                          } else if (isWrong) {
                            backgroundColor = Colors.red.shade300;
                          } else if (isSelected) {
                            backgroundColor = LoveTheme.lightPink;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: InkWell(
                              onTap: isDisabled || _isProcessing || _showResult
                                  ? null
                                  : () => _selectAnswer(index),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: backgroundColor ?? Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? LoveTheme.primaryPink
                                        : Colors.grey.shade300,
                                    width: isSelected ? 3 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? LoveTheme.primaryPink
                                            : Colors.grey.shade200,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          String.fromCharCode(
                                            65 + index,
                                          ), // A, B, C, D
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black87,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        question.options[index],
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge,
                                      ),
                                    ),
                                    if (isCorrect)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 28,
                                      ),
                                    if (isWrong)
                                      const Icon(
                                        Icons.cancel,
                                        color: Colors.red,
                                        size: 28,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 24),

                        // Cevap ver butonu
                        if (!_showResult)
                          ElevatedButton(
                            onPressed: _selectedAnswer != null && !_isProcessing
                                ? _submitAnswer
                                : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 16,
                              ),
                            ),
                            child: const Text('Cevabı Onayla'),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LoveTheme.pinkGradient,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5),
        ],
      ),
      child: Column(
        children: [
          // Jokerler
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _gameState.jokers.map((joker) {
              return InkWell(
                onTap: joker.isUsed || _isProcessing || _showResult
                    ? null
                    : () => _useJoker(joker.type),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: joker.isUsed
                        ? Colors.grey.shade400
                        : Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: joker.isUsed ? Colors.grey : LoveTheme.primaryPink,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getJokerIcon(joker.type),
                        color: joker.isUsed
                            ? Colors.grey
                            : LoveTheme.primaryPink,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        joker.name,
                        style: TextStyle(
                          fontSize: 10,
                          color: joker.isUsed
                              ? Colors.grey
                              : LoveTheme.darkPink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  IconData _getJokerIcon(JokerType type) {
    switch (type) {
      case JokerType.fiftyFifty:
        return Icons.horizontal_split;
      case JokerType.audience:
        return Icons.people;
      case JokerType.phone:
        return Icons.phone;
      case JokerType.doubleAnswer:
        return Icons.check_box;
    }
  }
}
