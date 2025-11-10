import 'package:flutter/material.dart';

import '../models/game_state.dart';
import '../services/audio_service.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/confetti_animation.dart';
import '../widgets/heart_animation.dart';
import 'home_screen.dart';

class ResultScreen extends StatefulWidget {
  final GameState gameState;
  final bool hasWon;

  const ResultScreen({
    super.key,
    required this.gameState,
    required this.hasWon,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _showHearts = false;

  @override
  void initState() {
    super.initState();
    if (widget.hasWon) {
      AudioService().playWin();
      setState(() {
        _showHearts = true;
      });
    } else {
      AudioService().playLose();
    }
  }

  String get _resultMessage {
    if (widget.hasWon) {
      return AppConstants.winMessage.isNotEmpty
          ? AppConstants.winMessage
          : 'Tebrikler ${AppConstants.playerName} 🎉\nTüm soruları doğru cevapladın!';
    } else {
      return AppConstants.loseMessage.isNotEmpty
          ? AppConstants.loseMessage
          : 'Maalesef yanlış cevap verdin.\nAma yine de harika bir denemeydi! 💕';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arka plan
          Container(
            decoration: BoxDecoration(
              gradient: widget.hasWon
                  ? LoveTheme.pinkGradient
                  : LoveTheme.lightPinkGradient,
            ),
          ),

          // Konfeti (kazanma durumunda)
          if (widget.hasWon) const ConfettiAnimation(isActive: true),

          // Kalp animasyonu (kazanma durumunda)
          if (widget.hasWon && _showHearts)
            const HeartAnimation(
              heartCount: 30,
              duration: Duration(seconds: 4),
            ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Sonuç ikonu
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.hasWon ? Icons.celebration : Icons.favorite,
                        size: 100,
                        color: widget.hasWon
                            ? LoveTheme.gold
                            : LoveTheme.primaryPink,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Sonuç mesajı
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            widget.hasWon ? '🎉 KAZANDIN! 🎉' : '💕',
                            style: Theme.of(context).textTheme.displayMedium
                                ?.copyWith(
                                  color: widget.hasWon
                                      ? LoveTheme.darkPink
                                      : LoveTheme.primaryPink,
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _resultMessage,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // İstatistikler
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: LoveTheme.rose,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Doğru Cevap: ${widget.gameState.currentQuestionIndex}/10',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Kullanılan Joker: ${widget.gameState.jokers.where((j) => j.isUsed).length}/4',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Ana menüye dön butonu
                    ElevatedButton(
                      onPressed: () {
                        AudioService().playClick();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 20,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('Ana Menüye Dön 💖'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
