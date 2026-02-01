import 'package:flutter/material.dart';

import '../services/audio_service.dart';
import '../utils/theme.dart';
import 'home_screen.dart';
import 'wordle_game_screen.dart';

class MysteryBoxScreen extends StatefulWidget {
  final int? openedBoxIndex; // 1. turda açılan kutu indeksi (null ise 1. tur)

  const MysteryBoxScreen({super.key, this.openedBoxIndex});

  @override
  State<MysteryBoxScreen> createState() => _MysteryBoxScreenState();
}

class _MysteryBoxScreenState extends State<MysteryBoxScreen>
    with SingleTickerProviderStateMixin {
  // Ödüller listesi
  final List<String> _oduller = [
    'Yemek',
    'Sinema Bileti',
    'Kahve ',
    'Lego',
    'Küpe',
    'Tatlı',
  ];

  // 1. turdan gelen, zaten kazanılmış kutu indeksi (sadece görsel için)
  int? _previousWonIndex;
  
  // Bu turda (Round 2) kullanıcının yeni seçeceği kutu
  int? _currentSelectedIndex;
  
  bool _isBoxOpened = false; // Bu turda kutu açıldı mı?
  bool _showContinueButton = false; // Devam et butonu gösterilsin mi?
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animasyon kontrolcüsü
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    // Eğer 1. turda bir kutu açıldıysa, onu previousWonIndex olarak kaydet
    // Ama currentSelectedIndex null kalmalı (yeni seçim yapılabilmeli)
    if (widget.openedBoxIndex != null) {
      _previousWonIndex = widget.openedBoxIndex;
      // _currentSelectedIndex başlangıçta null kalır
      // _isBoxOpened false kalır (yeni seçim yapılabilmeli)
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _openBox(int index) {
    // Eğer bu turda zaten bir kutu seçildiyse, yeni seçim yapma
    if (_isBoxOpened) return;
    
    // Eğer önceki turdan açılmış bir kutuya tıklanırsa, hiçbir şey yapma
    if (index == _previousWonIndex) return;

    setState(() {
      _currentSelectedIndex = index;
      _isBoxOpened = true;
    });

    AudioService().playClick();
    _animationController.forward();

    // Kısa bir gecikme sonrası devam et butonunu göster
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showContinueButton = true;
        });
      }
    });
  }

  void _navigateToWordle() {
    AudioService().playClick();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WordleGameScreen(openedBoxIndex: _currentSelectedIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSecondTurn = widget.openedBoxIndex != null;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LoveTheme.pinkGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Başlık
                Text(
                  isSecondTurn
                      ? '🎁 İkinci Ödülünü Seç! 🎁'
                      : '🎁 Gizemli Kutu 🎁',
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
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                Text(
                  isSecondTurn
                      ? 'Kalan kutulardan birini seç ve ikinci ödülünü kazan!'
                      : '6 kutudan birini seç ve ödülünü keşfet!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Kutu ızgarası (Grid)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    // Bu turda seçilen kutu mu?
                    final isCurrentSelected = _currentSelectedIndex == index;
                    
                    // Önceki turdan açılmış kutu mu?
                    final isPreviouslyOpened = _previousWonIndex == index;
                    
                    // Bu turda başka bir kutu seçildi mi? (bu kutu disabled olmalı)
                    final isDisabled = _isBoxOpened && _currentSelectedIndex != null && _currentSelectedIndex != index;

                    return GestureDetector(
                      onTap: () {
                        // Önceki turdan açılmış kutuya tıklanırsa hiçbir şey yapma
                        if (isPreviouslyOpened) return;
                        
                        // Bu turda zaten bir kutu seçildiyse, yeni seçim yapma
                        if (_isBoxOpened) return;
                        
                        // Yeni seçim yap
                        _openBox(index);
                      },
                      child: AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: isCurrentSelected
                                ? _scaleAnimation.value
                                : 1.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isCurrentSelected || isPreviouslyOpened
                                    ? LoveTheme.gold
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                                border: Border.all(
                                  color: isCurrentSelected || isPreviouslyOpened
                                      ? LoveTheme.darkPink
                                      : LoveTheme.primaryPink,
                                  width: 3,
                                ),
                              ),
                              child: Opacity(
                                // Önceki turdan açılmış kutu biraz soluk görünsün
                                opacity: isPreviouslyOpened && !isCurrentSelected ? 0.7 : 1.0,
                                child: Center(
                                  child: isCurrentSelected || isPreviouslyOpened
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.card_giftcard,
                                              size: 40,
                                              color: LoveTheme.darkPink,
                                            ),
                                            const SizedBox(height: 8),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0,
                                              ),
                                              child: Text(
                                                _oduller[index],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: LoveTheme.darkPink,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        )
                                      : const Icon(
                                          Icons.inventory_2,
                                          size: 50,
                                          color: LoveTheme.primaryPink,
                                        ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Devam et butonu (sadece 1. turda ve kutu açıldıktan sonra)
                if (_showContinueButton && !isSecondTurn)
                  ElevatedButton(
                    onPressed: _navigateToWordle,
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
                    child: const Text(
                      'İkinci Bir Ödül Şansı İçin Oyuna Devam Et 🎮',
                    ),
                  ),

                // Büyük ödül için geri dön butonu (2. turda ve kutu açıldıktan sonra)
                if (_showContinueButton && isSecondTurn)
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
                      backgroundColor: LoveTheme.gold,
                      foregroundColor: LoveTheme.darkPink,
                    ),
                    child: const Text('Tebrikler! Tüm Ödüllerini Kazandın! 🎉'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
