import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PhotoHelper {
  static final ImagePicker _picker = ImagePicker();

  // Galeriden fotoğraf seç
  static Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        // Fotoğrafı assets/photos klasörüne kopyala
        final String? savedPath = await _saveImageToAssets(image.path);
        return savedPath;
      }
      return null;
    } catch (e) {
      print('Fotoğraf seçilirken hata: $e');
      return null;
    }
  }

  // Kameradan fotoğraf çek
  static Future<String?> takePhotoWithCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final String? savedPath = await _saveImageToAssets(image.path);
        return savedPath;
      }
      return null;
    } catch (e) {
      print('Fotoğraf çekilirken hata: $e');
      return null;
    }
  }

  // Fotoğrafı assets/photos klasörüne kaydet
  static Future<String?> _saveImageToAssets(String imagePath) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String photosDir = path.join(appDocDir.path, 'photos');
      
      // Klasör yoksa oluştur
      final Directory photosDirectory = Directory(photosDir);
      if (!await photosDirectory.exists()) {
        await photosDirectory.create(recursive: true);
      }

      // Dosya adını oluştur
      final String fileName = path.basename(imagePath);
      final String newPath = path.join(photosDir, fileName);

      // Dosyayı kopyala
      final File sourceFile = File(imagePath);
      final File newFile = await sourceFile.copy(newPath);

      // assets/photos/ ile başlayan yol döndür (uygulama içinde kullanım için)
      return 'assets/photos/$fileName';
    } catch (e) {
      print('Fotoğraf kaydedilirken hata: $e');
      return null;
    }
  }

  // Fotoğraf seçme dialog'u göster
  static Future<String?> showImagePickerDialog() async {
    // Bu fonksiyon UI context gerektirir, bu yüzden ekranda kullanılmalı
    // Örnek kullanım için bir widget oluşturulabilir
    return null;
  }
}

