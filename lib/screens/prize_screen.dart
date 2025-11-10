import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/confetti_animation.dart';
import '../services/audio_service.dart';

class PrizeScreen extends StatefulWidget {
  final int prizeNumber;
  final Future<void> Function() onContinue;

  const PrizeScreen({
    super.key,
    required this.prizeNumber,
    required this.onContinue,
  });

  @override
  State<PrizeScreen> createState() => _PrizeScreenState();
}

class _PrizeScreenState extends State<PrizeScreen> {
  String get _prizeMessage {
    switch (widget.prizeNumber) {
      case 1:
        return AppConstants.prizeMessage1;
      case 2:
        return AppConstants.prizeMessage2;
      case 3:
        return AppConstants.prizeMessage3;
      default:
        return 'Şimdi ödül zamanı!';
    }
  }

  @override
  void initState() {
    super.initState();
    // Ödül sesini çal
    AudioService().playPrize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arka plan gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LoveTheme.goldGradient,
            ),
          ),
          
          // Konfeti animasyonu
          const ConfettiAnimation(
            isActive: true,
            color: LoveTheme.gold,
          ),
          
          // Ana içerik
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hediye kutusu ikonu
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
                      child: const Icon(
                        Icons.card_giftcard,
                        size: 100,
                        color: LoveTheme.primaryPink,
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Ödül mesajı
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
                            '🎁 ÖDÜL ZAMANI! 🎁',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  color: LoveTheme.darkPink,
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _prizeMessage,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.black87,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Devam et butonu
                    ElevatedButton(
                      onPressed: () async {
                        AudioService().playClick();
                        await widget.onContinue();
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
                      child: const Text('Devam Et 💕'),
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

