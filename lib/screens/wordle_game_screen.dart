import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import '../services/audio_service.dart';
import '../utils/theme.dart';
import 'mystery_box_screen.dart';

class WordleGameScreen extends StatefulWidget {
  final int? openedBoxIndex; // 1. turda açılan kutu indeksi

  const WordleGameScreen({
    super.key,
    this.openedBoxIndex,
  });

  @override
  State<WordleGameScreen> createState() => _WordleGameScreenState();
}

class _WordleGameScreenState extends State<WordleGameScreen> {
  // Oyun verileri
  Map<String, String>? _wordleData;
  int _currentLevel = 1;
  String _currentWord = '';
  List<String> _guesses = [];
  String _currentGuess = '';
  bool _gameWon = false;
  bool _gameLost = false;
  bool _isLoading = true;

  // Sistem klavyesi için
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWordleData();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_gameWon || _gameLost) return;

    final text = _textController.text.toUpperCase();
    
    // Sadece harfleri al (sayı ve özel karakterleri filtrele)
    final filteredText = text.replaceAll(RegExp(r'[^A-ZÇĞİÖŞÜ]'), '');
    
    // Maksimum uzunluğu kontrol et
    String finalText = filteredText;
    if (filteredText.length > _currentWord.length) {
      finalText = filteredText.substring(0, _currentWord.length);
    }
    
    // Eğer değişiklik varsa güncelle
    if (_currentGuess != finalText) {
      setState(() {
        _currentGuess = finalText;
      });
      
      // TextField'ı güncelle (sadece harfleri göster) - listener'ı geçici olarak kaldır
      if (_textController.text != finalText) {
        _textController.removeListener(_onTextChanged);
        _textController.value = TextEditingValue(
          text: finalText,
          selection: TextSelection.collapsed(offset: finalText.length),
        );
        _textController.addListener(_onTextChanged);
      }
    }
  }

  Future<void> _loadWordleData() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/wordle_data.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      setState(() {
        _wordleData = Map<String, String>.from(jsonData);
        _currentWord = _wordleData!['seviye1']!.toUpperCase();
        _isLoading = false;
      });
    } catch (e) {
      print('Wordle verisi yüklenemedi: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }


  void _submitGuess() {
    if (_currentGuess.length != _currentWord.length) return;
    if (_guesses.length >= 6) return;

    final guessToAdd = _currentGuess;
    
    setState(() {
      _guesses.add(guessToAdd);
      _currentGuess = '';
      _textController.clear();
    });

    // Klavyeyi kapat
    _focusNode.unfocus();

    // Kazanma kontrolü
    if (guessToAdd == _currentWord) {
      setState(() {
        _gameWon = true;
      });
      AudioService().playCorrect();
    } else if (_guesses.length >= 6) {
      setState(() {
        _gameLost = true;
      });
      AudioService().playWrong();
    }
  }

  void _nextLevel() {
    if (_currentLevel < 3) {
      setState(() {
        _currentLevel++;
        _currentWord = _wordleData!['seviye$_currentLevel']!.toUpperCase();
        _guesses = [];
        _currentGuess = '';
        _gameWon = false;
        _gameLost = false;
        _textController.clear();
      });
      AudioService().playClick();
      // Yeni seviyede klavyeyi aç
      Future.delayed(const Duration(milliseconds: 300), () {
        _focusNode.requestFocus();
      });
    }
  }

  void _returnToMysteryBox() {
    AudioService().playClick();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MysteryBoxScreen(
          openedBoxIndex: widget.openedBoxIndex,
        ),
      ),
    );
  }

  Color _getLetterColor(int rowIndex, int letterIndex) {
    if (rowIndex >= _guesses.length) return Colors.transparent;

    final guess = _guesses[rowIndex];
    final letter = guess[letterIndex];
    final correctLetter = _currentWord[letterIndex];

    // Doğru yer - Yeşil
    if (letter == correctLetter) {
      return Colors.green;
    }

    // Yanlış yer - Sarı (kelimede var ama yanlış yerde)
    if (_currentWord.contains(letter)) {
      // Aynı harfin doğru yerde kaç kez geçtiğini say
      int correctPositionCount = 0;
      for (int i = 0; i < _currentWord.length; i++) {
        if (_currentWord[i] == letter && guess[i] == letter) {
          correctPositionCount++;
        }
      }
      
      // Bu pozisyondan önce aynı harften kaç tane var
      int sameLetterBefore = 0;
      for (int i = 0; i < letterIndex; i++) {
        if (guess[i] == letter) {
          sameLetterBefore++;
        }
      }
      
      // Toplam harf sayısı
      int totalLetterCount = 0;
      for (int i = 0; i < _currentWord.length; i++) {
        if (_currentWord[i] == letter) {
          totalLetterCount++;
        }
      }
      
      // Eğer bu harf için yeterli sayıda sarı işaretlenmemişse sarı yap
      if (sameLetterBefore < totalLetterCount - correctPositionCount) {
        return Colors.amber;
      }
    }

    // Yok - Gri
    return Colors.grey.shade400;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LoveTheme.pinkGradient,
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Ana içerik
          Container(
            decoration: const BoxDecoration(
              gradient: LoveTheme.pinkGradient,
            ),
            child: SafeArea(
              child: GestureDetector(
                onTap: () {
                  // Ekrana herhangi bir yere tıklandığında klavyeyi aç
                  if (!_gameWon && !_gameLost) {
                    _focusNode.requestFocus();
                  }
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Başlık ve seviye
                      Text(
                        'WORDLE',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Seviye $_currentLevel / 3',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                      ),

                      const SizedBox(height: 40),

                      // Kelime tahmin alanı
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Tahmin edilen kelimeler
                            ...List.generate(6, (rowIndex) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(_currentWord.length, (letterIndex) {
                                    String letter = '';
                                    Color bgColor = Colors.grey.shade200;
                                    Color textColor = Colors.black;

                                    if (rowIndex < _guesses.length) {
                                      letter = _guesses[rowIndex][letterIndex];
                                      bgColor = _getLetterColor(rowIndex, letterIndex);
                                      textColor = Colors.white;
                                    } else if (rowIndex == _guesses.length &&
                                        letterIndex < _currentGuess.length) {
                                      letter = _currentGuess[letterIndex];
                                    }

                                    return Flexible(
                                      child: AspectRatio(
                                        aspectRatio: 1.0,
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 3),
                                          constraints: const BoxConstraints(
                                            maxWidth: 50,
                                            minWidth: 40,
                                          ),
                                          decoration: BoxDecoration(
                                            color: bgColor,
                                            border: Border.all(
                                              color: Colors.grey.shade400,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                letter,
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: textColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Sonuç mesajları ve butonlar
                      if (_gameWon)
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '🎉 Tebrikler! Seviye $_currentLevel tamamlandı! 🎉',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (_currentLevel < 3)
                              ElevatedButton(
                                onPressed: _nextLevel,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 48,
                                    vertical: 20,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  backgroundColor: LoveTheme.gold,
                                  foregroundColor: LoveTheme.darkPink,
                                ),
                                child: const Text('Sonraki Seviye ➡️'),
                              )
                            else
                              ElevatedButton(
                                onPressed: _returnToMysteryBox,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 48,
                                    vertical: 20,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  backgroundColor: LoveTheme.gold,
                                  foregroundColor: LoveTheme.darkPink,
                                ),
                                child: const Text('Büyük Ödül İçin Geri Dön 🎁'),
                              ),
                          ],
                        ),

                      if (_gameLost)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Maalesef kaybettin! 😢',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Doğru kelime: $_currentWord',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.white,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _guesses = [];
                                    _currentGuess = '';
                                    _gameWon = false;
                                    _gameLost = false;
                                    _textController.clear();
                                  });
                                  // Klavyeyi aç
                                  Future.delayed(const Duration(milliseconds: 300), () {
                                    _focusNode.requestFocus();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: LoveTheme.darkPink,
                                ),
                                child: const Text('Tekrar Dene'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Görünmez TextField (sistem klavyesi için) - Stack'in en üstünde
          Positioned(
            left: -1000, // Ekran dışına taşı
            top: -1000,
            child: Opacity(
              opacity: 0,
              child: SizedBox(
                width: 1,
                height: 1,
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  autofocus: false,
                  autocorrect: false,
                  enableSuggestions: false,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: _currentWord.length,
                  style: const TextStyle(color: Colors.transparent, fontSize: 1),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-ZÇĞİÖŞÜa-zçğıöşü]')),
                    LengthLimitingTextInputFormatter(10), // Maksimum kelime uzunluğu
                  ],
                  onSubmitted: (_) => _submitGuess(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
