import 'package:flutter/material.dart';

import '../services/game_service.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/heart_animation.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showHearts = true;

  @override
  void initState() {
    super.initState();
    // Kalp animasyonunu bir süre göster
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showHearts = false;
        });
      }
    });
  }

  Future<void> _startGame() async {
    final gameService = GameService();
    final gameState = await gameService.startNewGame();

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GameScreen(gameState: gameState)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arka plan gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LoveTheme.lightPinkGradient,
            ),
          ),

          // Kalp animasyonu
          if (_showHearts)
            const HeartAnimation(
              heartCount: 15,
              duration: Duration(seconds: 3),
            ),

          // Ana içerik
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Kalp ikonu
                    const Icon(
                      Icons.favorite,
                      size: 80,
                      color: LoveTheme.primaryPink,
                    ),
                    const SizedBox(height: 24),

                    // Başlık
                    Text(
                      'Merhaba ${AppConstants.playerName} 💕',
                      style: Theme.of(context).textTheme.displayLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Alt başlık
                    Text(
                      "Kim 14 Kasım'da Doğmak İster",
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Özel mesaj alanı (şu an boş)
                    if (AppConstants.welcomeMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          AppConstants.welcomeMessage,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: 48),

                    // Başla butonu
                    ElevatedButton(
                      onPressed: _startGame,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 20,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('Oyuna Başla 💖'),
                    ),

                    const SizedBox(height: 24),

                    // Bilgi metni
                    Text(
                      '10 soru, 4 joker ve 3 ödül seni bekliyor!',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                      textAlign: TextAlign.center,
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
