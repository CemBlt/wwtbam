import 'package:audioplayers/audioplayers.dart';
import '../utils/constants.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isEnabled = true;

  bool get isEnabled => _isEnabled;
  void setEnabled(bool enabled) => _isEnabled = enabled;

  Future<void> playSound(String path) async {
    if (!_isEnabled) return;
    try {
      // Önce çalan sesi durdur
      await _player.stop();
      
      // AssetSource için path'ten "assets/" kısmını kaldır
      // Örnek: "assets/sounds/correct.mp3" -> "sounds/correct.mp3"
      String soundPath = path;
      if (soundPath.startsWith('assets/')) {
        soundPath = soundPath.substring(7); // "assets/" kısmını kaldır (7 karakter)
      }
      
      // Debug için path'i yazdır
      print('Ses çalınıyor: $soundPath');
      
      // Release mode'u ayarla - ses bitince otomatik serbest bırak
      await _player.setReleaseMode(ReleaseMode.stop);
      
      await _player.play(AssetSource(soundPath));
    } catch (e) {
      // Ses dosyası yoksa sessizce geç
      print('Ses çalınamadı: $path - Hata: $e');
    }
  }

  Future<void> playCorrect() async => playSound('assets/sounds/correct.mp3');
  Future<void> playWrong() async => playSound('assets/sounds/wrong.mp3');
  Future<void> playClick() async => playSound('assets/sounds/click.mp3');
  Future<void> playJoker() async => playSound('assets/sounds/joker.mp3');
  Future<void> playPrize() async => playSound('assets/sounds/prize.mp3');
  Future<void> playWin() async => playSound('assets/sounds/win.mp3');
  Future<void> playLose() async => playSound('assets/sounds/lose.mp3');

  Future<void> playQuestionAudio(String? audioPath) async {
    if (!_isEnabled || audioPath == null) return;
    try {
      // AssetSource için path'ten "assets/" kısmını kaldır
      String path = audioPath;
      if (path.startsWith('assets/')) {
        path = path.substring(7); // "assets/" kısmını kaldır
      }
      await _player.play(AssetSource(path));
    } catch (e) {
      print('Soru sesi çalınamadı: $audioPath - Hata: $e');
    }
  }

  void stop() {
    _player.stop();
  }

  void dispose() {
    _player.dispose();
  }
}

